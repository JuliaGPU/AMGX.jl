# Julia wrapper for header: amgx_c.h
# Automatically generated using Clang.jl


function AMGX_get_api_version(major, minor)
    @runtime_ccall((:AMGX_get_api_version, libAMGX), AMGX_RC, (Ptr{Cint}, Ptr{Cint}), major, minor)
end

function AMGX_get_build_info_strings(version, date, time)
    @runtime_ccall((:AMGX_get_build_info_strings, libAMGX), AMGX_RC, (Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}), version, date, time)
end

function AMGX_get_error_string(err, buf, buf_len)
    @runtime_ccall((:AMGX_get_error_string, libAMGX), AMGX_RC, (AMGX_RC, Cstring, Cint), err, buf, buf_len)
end

function AMGX_initialize()
    @runtime_ccall((:AMGX_initialize, libAMGX), AMGX_RC, ())
end

function AMGX_initialize_plugins()
    @runtime_ccall((:AMGX_initialize_plugins, libAMGX), AMGX_RC, ())
end

function AMGX_finalize()
    @runtime_ccall((:AMGX_finalize, libAMGX), AMGX_RC, ())
end

function AMGX_finalize_plugins()
    @runtime_ccall((:AMGX_finalize_plugins, libAMGX), AMGX_RC, ())
end

function AMGX_abort(rsrc, err)
    @runtime_ccall((:AMGX_abort, libAMGX), Cvoid, (AMGX_resources_handle, Cint), rsrc, err)
end

function AMGX_pin_memory(ptr, bytes)
    @runtime_ccall((:AMGX_pin_memory, libAMGX), AMGX_RC, (Ptr{Cvoid}, UInt32), ptr, bytes)
end

function AMGX_unpin_memory(ptr)
    @runtime_ccall((:AMGX_unpin_memory, libAMGX), AMGX_RC, (Ptr{Cvoid},), ptr)
end

function AMGX_install_signal_handler()
    @runtime_ccall((:AMGX_install_signal_handler, libAMGX), AMGX_RC, ())
end

function AMGX_reset_signal_handler()
    @runtime_ccall((:AMGX_reset_signal_handler, libAMGX), AMGX_RC, ())
end

function AMGX_register_print_callback(func)
    @runtime_ccall((:AMGX_register_print_callback, libAMGX), AMGX_RC, (AMGX_print_callback,), func)
end

function AMGX_config_create(cfg, options)
    @runtime_ccall((:AMGX_config_create, libAMGX), AMGX_RC, (Ptr{AMGX_config_handle}, Cstring), cfg, options)
end

function AMGX_config_add_parameters(cfg, options)
    @runtime_ccall((:AMGX_config_add_parameters, libAMGX), AMGX_RC, (Ptr{AMGX_config_handle}, Cstring), cfg, options)
end

function AMGX_config_create_from_file(cfg, param_file)
    @runtime_ccall((:AMGX_config_create_from_file, libAMGX), AMGX_RC, (Ptr{AMGX_config_handle}, Cstring), cfg, param_file)
end

function AMGX_config_create_from_file_and_string(cfg, param_file, options)
    @runtime_ccall((:AMGX_config_create_from_file_and_string, libAMGX), AMGX_RC, (Ptr{AMGX_config_handle}, Cstring, Cstring), cfg, param_file, options)
end

function AMGX_config_get_default_number_of_rings(cfg, num_import_rings)
    @runtime_ccall((:AMGX_config_get_default_number_of_rings, libAMGX), AMGX_RC, (AMGX_config_handle, Ptr{Cint}), cfg, num_import_rings)
end

function AMGX_config_destroy(cfg)
    @runtime_ccall((:AMGX_config_destroy, libAMGX), AMGX_RC, (AMGX_config_handle,), cfg)
end

function AMGX_resources_create(rsc, cfg, comm, device_num, devices)
    @runtime_ccall((:AMGX_resources_create, libAMGX), AMGX_RC, (Ptr{AMGX_resources_handle}, AMGX_config_handle, Ptr{Cvoid}, Cint, Ptr{Cint}), rsc, cfg, comm, device_num, devices)
end

function AMGX_resources_create_simple(rsc, cfg)
    @runtime_ccall((:AMGX_resources_create_simple, libAMGX), AMGX_RC, (Ptr{AMGX_resources_handle}, AMGX_config_handle), rsc, cfg)
end

function AMGX_resources_destroy(rsc)
    @runtime_ccall((:AMGX_resources_destroy, libAMGX), AMGX_RC, (AMGX_resources_handle,), rsc)
end

function AMGX_distribution_create(dist, cfg)
    @runtime_ccall((:AMGX_distribution_create, libAMGX), AMGX_RC, (Ptr{AMGX_distribution_handle}, AMGX_config_handle), dist, cfg)
end

function AMGX_distribution_destroy(dist)
    @runtime_ccall((:AMGX_distribution_destroy, libAMGX), AMGX_RC, (AMGX_distribution_handle,), dist)
end

function AMGX_distribution_set_partition_data(dist, info, partition_data)
    @runtime_ccall((:AMGX_distribution_set_partition_data, libAMGX), AMGX_RC, (AMGX_distribution_handle, AMGX_DIST_PARTITION_INFO, Ptr{Cvoid}), dist, info, partition_data)
end

function AMGX_distribution_set_32bit_colindices(dist, use32bit)
    @runtime_ccall((:AMGX_distribution_set_32bit_colindices, libAMGX), AMGX_RC, (AMGX_distribution_handle, Cint), dist, use32bit)
end

function AMGX_matrix_create(mtx, rsc, mode)
    @runtime_ccall((:AMGX_matrix_create, libAMGX), AMGX_RC, (Ptr{AMGX_matrix_handle}, AMGX_resources_handle, AMGX_Mode), mtx, rsc, mode)
end

function AMGX_matrix_destroy(mtx)
    @runtime_ccall((:AMGX_matrix_destroy, libAMGX), AMGX_RC, (AMGX_matrix_handle,), mtx)
end

function AMGX_matrix_upload_all(mtx, n, nnz, block_dimx, block_dimy, row_ptrs, col_indices, data, diag_data)
    @runtime_ccall((:AMGX_matrix_upload_all, libAMGX), AMGX_RC, (AMGX_matrix_handle, Cint, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cvoid}, Ptr{Cvoid}), mtx, n, nnz, block_dimx, block_dimy, row_ptrs, col_indices, data, diag_data)
end

function AMGX_matrix_replace_coefficients(mtx, n, nnz, data, diag_data)
    @runtime_ccall((:AMGX_matrix_replace_coefficients, libAMGX), AMGX_RC, (AMGX_matrix_handle, Cint, Cint, Ptr{Cvoid}, Ptr{Cvoid}), mtx, n, nnz, data, diag_data)
end

function AMGX_matrix_get_size(mtx, n, block_dimx, block_dimy)
    @runtime_ccall((:AMGX_matrix_get_size, libAMGX), AMGX_RC, (AMGX_matrix_handle, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), mtx, n, block_dimx, block_dimy)
end

function AMGX_matrix_get_nnz(mtx, nnz)
    @runtime_ccall((:AMGX_matrix_get_nnz, libAMGX), AMGX_RC, (AMGX_matrix_handle, Ptr{Cint}), mtx, nnz)
end

function AMGX_matrix_download_all(mtx, row_ptrs, col_indices, data, diag_data)
    @runtime_ccall((:AMGX_matrix_download_all, libAMGX), AMGX_RC, (AMGX_matrix_handle, Ptr{Cint}, Ptr{Cint}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), mtx, row_ptrs, col_indices, data, diag_data)
end

function AMGX_matrix_vector_multiply(mtx, x, y)
    @runtime_ccall((:AMGX_matrix_vector_multiply, libAMGX), AMGX_RC, (AMGX_matrix_handle, AMGX_vector_handle, AMGX_vector_handle), mtx, x, y)
end

function AMGX_matrix_set_boundary_separation(mtx, boundary_separation)
    @runtime_ccall((:AMGX_matrix_set_boundary_separation, libAMGX), AMGX_RC, (AMGX_matrix_handle, Cint), mtx, boundary_separation)
end

function AMGX_matrix_comm_from_maps(mtx, allocated_halo_depth, num_import_rings, max_num_neighbors, neighbors, send_ptrs, send_maps, recv_ptrs, recv_maps)
    @runtime_ccall((:AMGX_matrix_comm_from_maps, libAMGX), AMGX_RC, (AMGX_matrix_handle, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), mtx, allocated_halo_depth, num_import_rings, max_num_neighbors, neighbors, send_ptrs, send_maps, recv_ptrs, recv_maps)
end

function AMGX_matrix_comm_from_maps_one_ring(mtx, allocated_halo_depth, num_neighbors, neighbors, send_sizes, send_maps, recv_sizes, recv_maps)
    @runtime_ccall((:AMGX_matrix_comm_from_maps_one_ring, libAMGX), AMGX_RC, (AMGX_matrix_handle, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Ptr{Cint}}, Ptr{Cint}, Ptr{Ptr{Cint}}), mtx, allocated_halo_depth, num_neighbors, neighbors, send_sizes, send_maps, recv_sizes, recv_maps)
end

function AMGX_vector_create(vec, rsc, mode)
    @runtime_ccall((:AMGX_vector_create, libAMGX), AMGX_RC, (Ptr{AMGX_vector_handle}, AMGX_resources_handle, AMGX_Mode), vec, rsc, mode)
end

function AMGX_vector_destroy(vec)
    @runtime_ccall((:AMGX_vector_destroy, libAMGX), AMGX_RC, (AMGX_vector_handle,), vec)
end

function AMGX_vector_upload(vec, n, block_dim, data)
    @runtime_ccall((:AMGX_vector_upload, libAMGX), AMGX_RC, (AMGX_vector_handle, Cint, Cint, Ptr{Cvoid}), vec, n, block_dim, data)
end

function AMGX_vector_set_zero(vec, n, block_dim)
    @runtime_ccall((:AMGX_vector_set_zero, libAMGX), AMGX_RC, (AMGX_vector_handle, Cint, Cint), vec, n, block_dim)
end

function AMGX_vector_set_random(vec, n)
    @runtime_ccall((:AMGX_vector_set_random, libAMGX), AMGX_RC, (AMGX_vector_handle, Cint), vec, n)
end

function AMGX_vector_download(vec, data)
    @runtime_ccall((:AMGX_vector_download, libAMGX), AMGX_RC, (AMGX_vector_handle, Ptr{Cvoid}), vec, data)
end

function AMGX_vector_get_size(vec, n, block_dim)
    @runtime_ccall((:AMGX_vector_get_size, libAMGX), AMGX_RC, (AMGX_vector_handle, Ptr{Cint}, Ptr{Cint}), vec, n, block_dim)
end

function AMGX_vector_bind(vec, mtx)
    @runtime_ccall((:AMGX_vector_bind, libAMGX), AMGX_RC, (AMGX_vector_handle, AMGX_matrix_handle), vec, mtx)
end

function AMGX_solver_create(slv, rsc, mode, cfg_solver)
    @runtime_ccall((:AMGX_solver_create, libAMGX), AMGX_RC, (Ptr{AMGX_solver_handle}, AMGX_resources_handle, AMGX_Mode, AMGX_config_handle), slv, rsc, mode, cfg_solver)
end

function AMGX_solver_destroy(slv)
    @runtime_ccall((:AMGX_solver_destroy, libAMGX), AMGX_RC, (AMGX_solver_handle,), slv)
end

function AMGX_solver_setup(slv, mtx)
    @runtime_ccall((:AMGX_solver_setup, libAMGX), AMGX_RC, (AMGX_solver_handle, AMGX_matrix_handle), slv, mtx)
end

function AMGX_solver_solve(slv, rhs, sol)
    @runtime_ccall((:AMGX_solver_solve, libAMGX), AMGX_RC, (AMGX_solver_handle, AMGX_vector_handle, AMGX_vector_handle), slv, rhs, sol)
end

function AMGX_solver_solve_with_0_initial_guess(slv, rhs, sol)
    @runtime_ccall((:AMGX_solver_solve_with_0_initial_guess, libAMGX), AMGX_RC, (AMGX_solver_handle, AMGX_vector_handle, AMGX_vector_handle), slv, rhs, sol)
end

function AMGX_solver_get_iterations_number(slv, n)
    @runtime_ccall((:AMGX_solver_get_iterations_number, libAMGX), AMGX_RC, (AMGX_solver_handle, Ptr{Cint}), slv, n)
end

function AMGX_solver_get_iteration_residual(slv, it, idx, res)
    @runtime_ccall((:AMGX_solver_get_iteration_residual, libAMGX), AMGX_RC, (AMGX_solver_handle, Cint, Cint, Ptr{Cdouble}), slv, it, idx, res)
end

function AMGX_solver_get_status(slv, st)
    @runtime_ccall((:AMGX_solver_get_status, libAMGX), AMGX_RC, (AMGX_solver_handle, Ptr{AMGX_SOLVE_STATUS}), slv, st)
end

function AMGX_solver_calculate_residual_norm(solver, mtx, rhs, x, norm_vector)
    @runtime_ccall((:AMGX_solver_calculate_residual_norm, libAMGX), AMGX_RC, (AMGX_solver_handle, AMGX_matrix_handle, AMGX_vector_handle, AMGX_vector_handle, Ptr{Cvoid}), solver, mtx, rhs, x, norm_vector)
end

function AMGX_write_system(mtx, rhs, sol, filename)
    @runtime_ccall((:AMGX_write_system, libAMGX), AMGX_RC, (AMGX_matrix_handle, AMGX_vector_handle, AMGX_vector_handle, Cstring), mtx, rhs, sol, filename)
end

function AMGX_write_system_distributed(mtx, rhs, sol, filename, allocated_halo_depth, num_partitions, partition_sizes, partition_vector_size, partition_vector)
    @runtime_ccall((:AMGX_write_system_distributed, libAMGX), AMGX_RC, (AMGX_matrix_handle, AMGX_vector_handle, AMGX_vector_handle, Cstring, Cint, Cint, Ptr{Cint}, Cint, Ptr{Cint}), mtx, rhs, sol, filename, allocated_halo_depth, num_partitions, partition_sizes, partition_vector_size, partition_vector)
end

function AMGX_read_system(mtx, rhs, sol, filename)
    @runtime_ccall((:AMGX_read_system, libAMGX), AMGX_RC, (AMGX_matrix_handle, AMGX_vector_handle, AMGX_vector_handle, Cstring), mtx, rhs, sol, filename)
end

function AMGX_read_system_distributed(mtx, rhs, sol, filename, allocated_halo_depth, num_partitions, partition_sizes, partition_vector_size, partition_vector)
    @runtime_ccall((:AMGX_read_system_distributed, libAMGX), AMGX_RC, (AMGX_matrix_handle, AMGX_vector_handle, AMGX_vector_handle, Cstring, Cint, Cint, Ptr{Cint}, Cint, Ptr{Cint}), mtx, rhs, sol, filename, allocated_halo_depth, num_partitions, partition_sizes, partition_vector_size, partition_vector)
end

function AMGX_read_system_maps_one_ring(n, nnz, block_dimx, block_dimy, row_ptrs, col_indices, data, diag_data, rhs, sol, num_neighbors, neighbors, send_sizes, send_maps, recv_sizes, recv_maps, rsc, mode, filename, allocated_halo_depth, num_partitions, partition_sizes, partition_vector_size, partition_vector)
    @runtime_ccall((:AMGX_read_system_maps_one_ring, libAMGX), AMGX_RC, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Ptr{Cint}}, Ptr{Ptr{Cint}}, Ptr{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}, Ptr{Cint}, Ptr{Ptr{Cint}}, Ptr{Ptr{Cint}}, Ptr{Ptr{Ptr{Cint}}}, Ptr{Ptr{Cint}}, Ptr{Ptr{Ptr{Cint}}}, AMGX_resources_handle, AMGX_Mode, Cstring, Cint, Cint, Ptr{Cint}, Cint, Ptr{Cint}), n, nnz, block_dimx, block_dimy, row_ptrs, col_indices, data, diag_data, rhs, sol, num_neighbors, neighbors, send_sizes, send_maps, recv_sizes, recv_maps, rsc, mode, filename, allocated_halo_depth, num_partitions, partition_sizes, partition_vector_size, partition_vector)
end

function AMGX_free_system_maps_one_ring(row_ptrs, col_indices, data, diag_data, rhs, sol, num_neighbors, neighbors, send_sizes, send_maps, recv_sizes, recv_maps)
    @runtime_ccall((:AMGX_free_system_maps_one_ring, libAMGX), AMGX_RC, (Ptr{Cint}, Ptr{Cint}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Ptr{Cint}}, Ptr{Cint}, Ptr{Ptr{Cint}}), row_ptrs, col_indices, data, diag_data, rhs, sol, num_neighbors, neighbors, send_sizes, send_maps, recv_sizes, recv_maps)
end

function AMGX_generate_distributed_poisson_7pt(mtx, rhs, sol, allocated_halo_depth, num_import_rings, nx, ny, nz, px, py, pz)
    @runtime_ccall((:AMGX_generate_distributed_poisson_7pt, libAMGX), AMGX_RC, (AMGX_matrix_handle, AMGX_vector_handle, AMGX_vector_handle, Cint, Cint, Cint, Cint, Cint, Cint, Cint, Cint), mtx, rhs, sol, allocated_halo_depth, num_import_rings, nx, ny, nz, px, py, pz)
end

function AMGX_write_parameters_description(filename, mode)
    @runtime_ccall((:AMGX_write_parameters_description, libAMGX), AMGX_RC, (Cstring, AMGX_GET_PARAMS_DESC_FLAG), filename, mode)
end

function AMGX_matrix_attach_coloring(mtx, row_coloring, num_rows, num_colors)
    @runtime_ccall((:AMGX_matrix_attach_coloring, libAMGX), AMGX_RC, (AMGX_matrix_handle, Ptr{Cint}, Cint, Cint), mtx, row_coloring, num_rows, num_colors)
end

function AMGX_matrix_attach_geometry(mtx, geox, geoy, geoz, n)
    @runtime_ccall((:AMGX_matrix_attach_geometry, libAMGX), AMGX_RC, (AMGX_matrix_handle, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint), mtx, geox, geoy, geoz, n)
end

function AMGX_read_system_global(n, nnz, block_dimx, block_dimy, row_ptrs, col_indices_global, data, diag_data, rhs, sol, rsc, mode, filename, allocated_halo_depth, num_partitions, partition_sizes, partition_vector_size, partition_vector)
    @runtime_ccall((:AMGX_read_system_global, libAMGX), AMGX_RC, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Ptr{Cint}}, Ptr{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}, AMGX_resources_handle, AMGX_Mode, Cstring, Cint, Cint, Ptr{Cint}, Cint, Ptr{Cint}), n, nnz, block_dimx, block_dimy, row_ptrs, col_indices_global, data, diag_data, rhs, sol, rsc, mode, filename, allocated_halo_depth, num_partitions, partition_sizes, partition_vector_size, partition_vector)
end

function AMGX_matrix_upload_all_global(mtx, n_global, n, nnz, block_dimx, block_dimy, row_ptrs, col_indices_global, data, diag_data, allocated_halo_depth, num_import_rings, partition_vector)
    @runtime_ccall((:AMGX_matrix_upload_all_global, libAMGX), AMGX_RC, (AMGX_matrix_handle, Cint, Cint, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cint, Cint, Ptr{Cint}), mtx, n_global, n, nnz, block_dimx, block_dimy, row_ptrs, col_indices_global, data, diag_data, allocated_halo_depth, num_import_rings, partition_vector)
end

function AMGX_matrix_upload_all_global_32(mtx, n_global, n, nnz, block_dimx, block_dimy, row_ptrs, col_indices_global, data, diag_data, allocated_halo_depth, num_import_rings, partition_vector)
    @runtime_ccall((:AMGX_matrix_upload_all_global_32, libAMGX), AMGX_RC, (AMGX_matrix_handle, Cint, Cint, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cint, Cint, Ptr{Cint}), mtx, n_global, n, nnz, block_dimx, block_dimy, row_ptrs, col_indices_global, data, diag_data, allocated_halo_depth, num_import_rings, partition_vector)
end

function AMGX_matrix_upload_distributed(mtx, n_global, n, nnz, block_dimx, block_dimy, row_ptrs, col_indices_global, data, diag_data, distribution)
    @runtime_ccall((:AMGX_matrix_upload_distributed, libAMGX), AMGX_RC, (AMGX_matrix_handle, Cint, Cint, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, AMGX_distribution_handle), mtx, n_global, n, nnz, block_dimx, block_dimy, row_ptrs, col_indices_global, data, diag_data, distribution)
end

function AMGX_solver_register_print_callback(func)
    @runtime_ccall((:AMGX_solver_register_print_callback, libAMGX), AMGX_RC, (AMGX_print_callback,), func)
end

function AMGX_solver_resetup(slv, mtx)
    @runtime_ccall((:AMGX_solver_resetup, libAMGX), AMGX_RC, (AMGX_solver_handle, AMGX_matrix_handle), slv, mtx)
end
# Julia wrapper for header: amgx_config.h
# Automatically generated using Clang.jl

