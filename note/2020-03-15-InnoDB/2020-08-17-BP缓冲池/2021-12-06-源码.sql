/** Resize the buffer pool based on srv_buf_pool_size from
srv_buf_pool_old_size. */
void
buf_pool_resize()
{
	buf_pool_t*	buf_pool;
	ulint		new_instance_size;
	bool		warning = false;

	NUMA_MEMPOLICY_INTERLEAVE_IN_SCOPE;

	ut_ad(!buf_pool_resizing);
	ut_ad(!buf_pool_withdrawing);
	ut_ad(srv_buf_pool_chunk_unit > 0);

	new_instance_size = srv_buf_pool_size / srv_buf_pool_instances;
	new_instance_size /= UNIV_PAGE_SIZE;

	buf_resize_status("Resizing buffer pool from " ULINTPF " to "
			  ULINTPF " (unit=" ULINTPF ").",
			  srv_buf_pool_old_size, srv_buf_pool_size,
			  srv_buf_pool_chunk_unit);
	
	-- 为所有缓冲池设置新的限制以调整大小
	/* set new limit for all buffer pool for resizing */
	for (ulint i = 0; i < srv_buf_pool_instances; i++) {
		buf_pool = buf_pool_from_array(i);
		
		buf_pool_mutex_enter(buf_pool);

		ut_ad(buf_pool->curr_size == buf_pool->old_size);
		ut_ad(buf_pool->n_chunks_new == buf_pool->n_chunks);
		ut_ad(UT_LIST_GET_LEN(buf_pool->withdraw) == 0);
		ut_ad(buf_pool->flush_rbt == NULL);

		buf_pool->curr_size = new_instance_size;

		buf_pool->n_chunks_new = new_instance_size * UNIV_PAGE_SIZE
			/ srv_buf_pool_chunk_unit;

		buf_pool_mutex_exit(buf_pool);
	}
	
	-- 禁用AHI
	/* disable AHI if needed */
	bool	btr_search_disabled = false;

	buf_resize_status("Disabling adaptive hash index.");

	btr_search_s_lock_all();
	if (btr_search_enabled) {
		btr_search_s_unlock_all();
		btr_search_disabled = true;
	} else {
		btr_search_s_unlock_all();
	}

	btr_search_disable(true);

	if (btr_search_disabled) {
		ib::info() << "disabled adaptive hash index.";
	}

	/* set withdraw target */
	for (ulint i = 0; i < srv_buf_pool_instances; i++) {
		buf_pool = buf_pool_from_array(i);
		if (buf_pool->curr_size < buf_pool->old_size) {
			ulint	withdraw_target = 0;

			const buf_chunk_t*	chunk
				= buf_pool->chunks + buf_pool->n_chunks_new;
			const buf_chunk_t*	echunk
				= buf_pool->chunks + buf_pool->n_chunks;

			while (chunk < echunk) {
				withdraw_target += chunk->size;
				++chunk;
			}

			ut_ad(buf_pool->withdraw_target == 0);
			buf_pool->withdraw_target = withdraw_target;
			buf_pool_withdrawing = true;
		}
	}

	buf_resize_status("Withdrawing blocks to be shrunken.");

	ib_time_t	withdraw_started = ut_time();
	ulint		message_interval = 60;
	ulint		retry_interval = 1;

withdraw_retry:
	bool	should_retry_withdraw = false;

	/* wait for the number of blocks fit to the new size (if needed)*/
	for (ulint i = 0; i < srv_buf_pool_instances; i++) {
		buf_pool = buf_pool_from_array(i);
		if (buf_pool->curr_size < buf_pool->old_size) {

			should_retry_withdraw |=
				buf_pool_withdraw_blocks(buf_pool);
		}
	}

	if (srv_shutdown_state != SRV_SHUTDOWN_NONE) {
		/* abort to resize for shutdown. */
		buf_pool_withdrawing = false;
		return;
	}

	/* abort buffer pool load */
	buf_load_abort();

	if (should_retry_withdraw
	    && ut_difftime(ut_time(), withdraw_started) >= message_interval) {

		if (message_interval > 900) {
			message_interval = 1800;
		} else {
			message_interval *= 2;
		}

		lock_mutex_enter();
		trx_sys_mutex_enter();
		bool	found = false;
		for (trx_t* trx = UT_LIST_GET_FIRST(trx_sys->mysql_trx_list);
		     trx != NULL;
		     trx = UT_LIST_GET_NEXT(mysql_trx_list, trx)) {
			if (trx->state != TRX_STATE_NOT_STARTED
			    && trx->mysql_thd != NULL
			    && ut_difftime(withdraw_started,
					   trx->start_time) > 0) {
				if (!found) {
					ib::warn() <<
						"The following trx might hold"
						" the blocks in buffer pool to"
					        " be withdrawn. Buffer pool"
						" resizing can complete only"
						" after all the transactions"
						" below release the blocks.";
					found = true;
				}

				lock_trx_print_wait_and_mvcc_state(
					stderr, trx);
			}
		}
		trx_sys_mutex_exit();
		lock_mutex_exit();

		withdraw_started = ut_time();
	}

	if (should_retry_withdraw) {
		ib::info() << "Will retry to withdraw " << retry_interval
			<< " seconds later.";
		os_thread_sleep(retry_interval * 1000000);

		if (retry_interval > 5) {
			retry_interval = 10;
		} else {
			retry_interval *= 2;
		}

		goto withdraw_retry;
	}

	buf_pool_withdrawing = false;

	buf_resize_status("Latching whole of buffer pool.");

#ifndef DBUG_OFF
	{
		bool	should_wait = true;

		while (should_wait) {
			should_wait = false;
			DBUG_EXECUTE_IF(
				"ib_buf_pool_resize_wait_before_resize",
				should_wait = true; os_thread_sleep(10000););
		}
	}
#endif /* !DBUG_OFF */

	if (srv_shutdown_state != SRV_SHUTDOWN_NONE) {
		return;
	}

	/* Indicate critical path */
	buf_pool_resizing = true;

	/* Acquire all buf_pool_mutex/hash_lock */
	for (ulint i = 0; i < srv_buf_pool_instances; ++i) {
		buf_pool_t*	buf_pool = buf_pool_from_array(i);

		buf_pool_mutex_enter(buf_pool);
	}
	for (ulint i = 0; i < srv_buf_pool_instances; ++i) {
		buf_pool_t*	buf_pool = buf_pool_from_array(i);

		hash_lock_x_all(buf_pool->page_hash);
	}

	buf_chunk_map_reg = UT_NEW_NOKEY(buf_pool_chunk_map_t());

	/* add/delete chunks */
	for (ulint i = 0; i < srv_buf_pool_instances; ++i) {
		buf_pool_t*	buf_pool = buf_pool_from_array(i);
		buf_chunk_t*	chunk;
		buf_chunk_t*	echunk;

		buf_resize_status("buffer pool %lu :"
			" resizing with chunks %lu to %lu.",
			i, buf_pool->n_chunks, buf_pool->n_chunks_new);

		if (buf_pool->n_chunks_new < buf_pool->n_chunks) {
			/* delete chunks */
			chunk = buf_pool->chunks
				+ buf_pool->n_chunks_new;
			echunk = buf_pool->chunks + buf_pool->n_chunks;

			ulint	sum_freed = 0;

			while (chunk < echunk) {
				buf_block_t*	block = chunk->blocks;

				for (ulint j = chunk->size;
				     j--; block++) {
					mutex_free(&block->mutex);
					rw_lock_free(&block->lock);

					ut_d(rw_lock_free(
						&block->debug_latch));
				}

				buf_pool->allocator.deallocate_large(
					chunk->mem, &chunk->mem_pfx);

				sum_freed += chunk->size;

				++chunk;
			}

			/* discard withdraw list */
			UT_LIST_INIT(buf_pool->withdraw,
				     &buf_page_t::list);
			buf_pool->withdraw_target = 0;

			ib::info() << "buffer pool " << i << " : "
				<< buf_pool->n_chunks - buf_pool->n_chunks_new
				<< " chunks (" << sum_freed
				<< " blocks) were freed.";

			buf_pool->n_chunks = buf_pool->n_chunks_new;
		}

		{
			/* reallocate buf_pool->chunks */
			const ulint	new_chunks_size
				= buf_pool->n_chunks_new * sizeof(*chunk);

			buf_chunk_t*	new_chunks
				= reinterpret_cast<buf_chunk_t*>(
					ut_zalloc_nokey_nofatal(new_chunks_size));

			DBUG_EXECUTE_IF("buf_pool_resize_chunk_null",
				buf_pool_resize_chunk_make_null(&new_chunks););

			if (new_chunks == NULL) {
				ib::error() << "buffer pool " << i
					<< " : failed to allocate"
					" the chunk array.";
				buf_pool->n_chunks_new
					= buf_pool->n_chunks;
				warning = true;
				buf_pool->chunks_old = NULL;
				for (ulint j = 0; j < buf_pool->n_chunks_new; j++) {
					buf_pool_register_chunk(&(buf_pool->chunks[j]));
				}
				goto calc_buf_pool_size;
			}

			ulint	n_chunks_copy = ut_min(buf_pool->n_chunks_new,
						       buf_pool->n_chunks);

			memcpy(new_chunks, buf_pool->chunks,
			       n_chunks_copy * sizeof(*chunk));

			for (ulint j = 0; j < n_chunks_copy; j++) {
				buf_pool_register_chunk(&new_chunks[j]);
			}

			buf_pool->chunks_old = buf_pool->chunks;
			buf_pool->chunks = new_chunks;
		}


		if (buf_pool->n_chunks_new > buf_pool->n_chunks) {
			/* add chunks */
			chunk = buf_pool->chunks + buf_pool->n_chunks;
			echunk = buf_pool->chunks
				+ buf_pool->n_chunks_new;

			ulint	sum_added = 0;
			ulint	n_chunks = buf_pool->n_chunks;

			while (chunk < echunk) {
				ulong	unit = srv_buf_pool_chunk_unit;

				if (!buf_chunk_init(buf_pool, chunk, unit)) {

					ib::error() << "buffer pool " << i
						<< " : failed to allocate"
						" new memory.";

					warning = true;

					buf_pool->n_chunks_new
						= n_chunks;

					break;
				}

				sum_added += chunk->size;

				++n_chunks;
				++chunk;
			}

			ib::info() << "buffer pool " << i << " : "
				<< buf_pool->n_chunks_new - buf_pool->n_chunks
				<< " chunks (" << sum_added
				<< " blocks) were added.";

			buf_pool->n_chunks = n_chunks;
		}
calc_buf_pool_size:

		/* recalc buf_pool->curr_size */
		ulint	new_size = 0;

		chunk = buf_pool->chunks;
		do {
			new_size += chunk->size;
		} while (++chunk < buf_pool->chunks
				   + buf_pool->n_chunks);

		buf_pool->curr_size = new_size;
		buf_pool->n_chunks_new = buf_pool->n_chunks;

		if (buf_pool->chunks_old) {
			ut_free(buf_pool->chunks_old);
			buf_pool->chunks_old = NULL;
		}
	}

	buf_pool_chunk_map_t*	chunk_map_old = buf_chunk_map_ref;
	buf_chunk_map_ref = buf_chunk_map_reg;

	/* set instance sizes */
	{
		ulint	curr_size = 0;

		for (ulint i = 0; i < srv_buf_pool_instances; i++) {
			buf_pool = buf_pool_from_array(i);

			ut_ad(UT_LIST_GET_LEN(buf_pool->withdraw) == 0);

			buf_pool->read_ahead_area =
				ut_min(BUF_READ_AHEAD_PAGES,
				       ut_2_power_up(buf_pool->curr_size /
						      BUF_READ_AHEAD_PORTION));
			buf_pool->curr_pool_size
				= buf_pool->curr_size * UNIV_PAGE_SIZE;
			curr_size += buf_pool->curr_pool_size;
			buf_pool->old_size = buf_pool->curr_size;
		}
		srv_buf_pool_curr_size = curr_size;
		innodb_set_buf_pool_size(buf_pool_size_align(curr_size));
	}

	const bool	new_size_too_diff
		= srv_buf_pool_base_size > srv_buf_pool_size * 2
			|| srv_buf_pool_base_size * 2 < srv_buf_pool_size;

	/* Normalize page_hash and zip_hash,
	if the new size is too different */
	if (!warning && new_size_too_diff) {

		buf_resize_status("Resizing hash tables.");

		for (ulint i = 0; i < srv_buf_pool_instances; ++i) {
			buf_pool_t*	buf_pool = buf_pool_from_array(i);

			buf_pool_resize_hash(buf_pool);

			ib::info() << "buffer pool " << i
				<< " : hash tables were resized.";
		}
	}

	/* Release all buf_pool_mutex/page_hash */
	for (ulint i = 0; i < srv_buf_pool_instances; ++i) {
		buf_pool_t*	buf_pool = buf_pool_from_array(i);

		hash_unlock_x_all(buf_pool->page_hash);
		buf_pool_mutex_exit(buf_pool);

		if (buf_pool->page_hash_old != NULL) {
			hash_table_free(buf_pool->page_hash_old);
			buf_pool->page_hash_old = NULL;
		}
	}

	UT_DELETE(chunk_map_old);

	buf_pool_resizing = false;

	/* Normalize other components, if the new size is too different */
	if (!warning && new_size_too_diff) {
		srv_buf_pool_base_size = srv_buf_pool_size;

		buf_resize_status("Resizing also other hash tables.");

		/* normalize lock_sys */
		srv_lock_table_size = 5 * (srv_buf_pool_size / UNIV_PAGE_SIZE);
		lock_sys_resize(srv_lock_table_size);

		/* normalize btr_search_sys */
		btr_search_sys_resize(
			buf_pool_get_curr_size() / sizeof(void*) / 64);

		/* normalize dict_sys */
		dict_resize();

		ib::info() << "Resized hash tables at lock_sys,"
			" adaptive hash index, dictionary.";
	}

	/* normalize ibuf->max_size */
	ibuf_max_size_update(srv_change_buffer_max_size);

	if (srv_buf_pool_old_size != srv_buf_pool_size) {

		ib::info() << "Completed to resize buffer pool from "
			<< srv_buf_pool_old_size
			<< " to " << srv_buf_pool_size << ".";
		srv_buf_pool_old_size = srv_buf_pool_size;
	}

	/* enable AHI if needed */
	if (btr_search_disabled) {
		btr_search_enable();
		ib::info() << "Re-enabled adaptive hash index.";
	}

	char	now[32];

	ut_sprintf_timestamp(now);
	if (!warning) {
		buf_resize_status("Completed resizing buffer pool at %s.",
			now);
	} else {
		buf_resize_status("Resizing buffer pool failed,"
			" finished resizing at %s.", now);
	}

#if defined UNIV_DEBUG || defined UNIV_BUF_DEBUG
	ut_a(buf_validate());
#endif /* UNIV_DEBUG || UNIV_BUF_DEBUG */

	return;
}