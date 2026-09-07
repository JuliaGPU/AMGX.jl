@cenum AMGX_Mode::Int32 begin
    AMGX_unset = -1
    AMGX_modeRange = 65536
    AMGX_mode_hDDI = 8192
    AMGX_mode_hDFI = 8448
    AMGX_mode_hFFI = 8464
    AMGX_mode_dDDI = 8193
    AMGX_mode_dDFI = 8449
    AMGX_mode_dFFI = 8465
    AMGX_mode_hIDI = 8224
    AMGX_mode_hIFI = 8480
    AMGX_mode_dIDI = 8225
    AMGX_mode_dIFI = 8481
    AMGX_mode_hZZI = 9008
    AMGX_mode_hZCI = 9264
    AMGX_mode_hCCI = 9280
    AMGX_mode_dZZI = 9009
    AMGX_mode_dZCI = 9265
    AMGX_mode_dCCI = 9281
    AMGX_modeNum = 10
    AMGX_ModeInst = 11
end

@cenum AMGX_MemorySpace::UInt32 begin
    AMGX_host = 0
    AMGX_device = 1
    AMGX_memorySpaceNum = 16
end

@cenum AMGX_ScalarPrecision::UInt32 begin
    AMGX_double = 0
    AMGX_float = 1
    AMGX_int = 2
    AMGX_doublecomplex = 3
    AMGX_complex = 4
    AMGX_usint = 5
    AMGX_uint = 6
    AMGX_uint64 = 7
    AMGX_int64 = 8
    AMGX_bool = 9
    AMGX_scalarPrecisionNum = 16
end

@cenum AMGX_VecPrecision::UInt32 begin
    AMGX_vecDouble = 0
    AMGX_vecFloat = 1
    AMGX_vecDoubleComplex = 3
    AMGX_vecComplex = 4
    AMGX_vecInt = 2
    AMGX_vecUSInt = 5
    AMGX_vecUInt = 6
    AMGX_vecUInt64 = 7
    AMGX_vecInt64 = 8
    AMGX_vecBool = 9
    AMGX_vecPrecisionNum = 16
    AMGX_VecPrecisionInst = 17
end

@cenum AMGX_MatPrecision::UInt32 begin
    AMGX_matDouble = 0
    AMGX_matFloat = 1
    AMGX_matDoubleComplex = 3
    AMGX_matComplex = 4
    AMGX_matInt = 2
    AMGX_matPrecisionNum = 16
    AMGX_MatPrecisionInst = 17
end

@cenum AMGX_IndPrecision::UInt32 begin
    AMGX_indInt = 2
    AMGX_indInt64 = 8
    AMGX_indPrecisionNum = 16
    AMGX_IndPrecisionInst = 17
end

@cenum AMGX_ModeNums::UInt32 begin
    AMGX_MemorySpaceBase = 1
    AMGX_MemorySpaceSize = 16
    AMGX_VecPrecisionBase = 16
    AMGX_VecPrecisionSize = 16
    AMGX_MatPrecisionBase = 256
    AMGX_MatPrecisionSize = 16
    AMGX_IndPrecisionBase = 4096
    AMGX_IndPrecisionSize = 16
end

@cenum AMGX_RC::UInt32 begin
    AMGX_RC_OK = 0
    AMGX_RC_BAD_PARAMETERS = 1
    AMGX_RC_UNKNOWN = 2
    AMGX_RC_NOT_SUPPORTED_TARGET = 3
    AMGX_RC_NOT_SUPPORTED_BLOCKSIZE = 4
    AMGX_RC_CUDA_FAILURE = 5
    AMGX_RC_THRUST_FAILURE = 6
    AMGX_RC_NO_MEMORY = 7
    AMGX_RC_IO_ERROR = 8
    AMGX_RC_BAD_MODE = 9
    AMGX_RC_CORE = 10
    AMGX_RC_PLUGIN = 11
    AMGX_RC_BAD_CONFIGURATION = 12
    AMGX_RC_NOT_IMPLEMENTED = 13
    AMGX_RC_LICENSE_NOT_FOUND = 14
    AMGX_RC_INTERNAL = 15
end

function AMGX_get_error_string(err, buf, buf_len)
    @ccall libAMGX.AMGX_get_error_string(err::AMGX_RC, buf::Cstring, buf_len::Cint)::AMGX_RC
end

struct AMGX_resources_handle_struct
    AMGX_resources_handle_dummy::Cchar
end

const AMGX_resources_handle = Ptr{AMGX_resources_handle_struct}

function AMGX_abort(rsrc, err)
    @ccall libAMGX.AMGX_abort(rsrc::AMGX_resources_handle, err::Cint)::Cvoid
end

@cenum AMGX_FLAGS::UInt32 begin
    SOLVE_STATS = 1
    GRID_STATS = 2
    CONFIG = 4
    PROFILE_STATS = 8
    VISDATA = 16
    RESIDUAL_HISTORY = 32
end

@cenum AMGX_SOLVE_STATUS::UInt32 begin
    AMGX_SOLVE_SUCCESS = 0
    AMGX_SOLVE_FAILED = 1
    AMGX_SOLVE_DIVERGED = 2
    AMGX_SOLVE_NOT_CONVERGED = 3
end

@cenum AMGX_GET_PARAMS_DESC_FLAG::UInt32 begin
    AMGX_GET_PARAMS_DESC_JSON_TO_FILE = 0
    AMGX_GET_PARAMS_DESC_JSON_TO_STRING = 1
    AMGX_GET_PARAMS_DESC_TEXT_TO_FILE = 2
    AMGX_GET_PARAMS_DESC_TEXT_TO_STRING = 3
end

@cenum AMGX_DIST_PARTITION_INFO::UInt32 begin
    AMGX_DIST_PARTITION_VECTOR = 0
    AMGX_DIST_PARTITION_OFFSETS = 1
end

# typedef void ( * AMGX_print_callback ) ( const char * msg , int length )
const AMGX_print_callback = Ptr{Cvoid}

struct AMGX_config_handle_struct
    AMGX_config_handle_dummy::Cchar
end

const AMGX_config_handle = Ptr{AMGX_config_handle_struct}

struct AMGX_matrix_handle_struct
    AMGX_matrix_handle_dummy::Cchar
end

const AMGX_matrix_handle = Ptr{AMGX_matrix_handle_struct}

struct AMGX_vector_handle_struct
    AMGX_vector_handle_dummy::Cchar
end

const AMGX_vector_handle = Ptr{AMGX_vector_handle_struct}

struct AMGX_solver_handle_struct
    AMGX_solver_handle_dummy::Cchar
end

const AMGX_solver_handle = Ptr{AMGX_solver_handle_struct}

struct AMGX_distribution_handle_struct
    AMGX_distribution_handle_dummy::Cchar
end

const AMGX_distribution_handle = Ptr{AMGX_distribution_handle_struct}

function AMGX_get_api_version(major, minor)
    @ccall libAMGX.AMGX_get_api_version(major::Ptr{Cint}, minor::Ptr{Cint})::AMGX_RC
end

function AMGX_get_build_info_strings(version, date, time)
    @ccall libAMGX.AMGX_get_build_info_strings(version::Ptr{Cstring}, date::Ptr{Cstring},
                                               time::Ptr{Cstring})::AMGX_RC
end

# no prototype is found for this function at amgx_c.h:165:18, please use with caution
function AMGX_initialize()
    @ccall libAMGX.AMGX_initialize()::AMGX_RC
end

# no prototype is found for this function at amgx_c.h:167:18, please use with caution
function AMGX_initialize_plugins()
    @ccall libAMGX.AMGX_initialize_plugins()::AMGX_RC
end

# no prototype is found for this function at amgx_c.h:169:18, please use with caution
function AMGX_finalize()
    @ccall libAMGX.AMGX_finalize()::AMGX_RC
end

# no prototype is found for this function at amgx_c.h:171:18, please use with caution
function AMGX_finalize_plugins()
    @ccall libAMGX.AMGX_finalize_plugins()::AMGX_RC
end

function AMGX_pin_memory(ptr, bytes)
    @ccall libAMGX.AMGX_pin_memory(ptr::Ptr{Cvoid}, bytes::Cuint)::AMGX_RC
end

function AMGX_unpin_memory(ptr)
    @ccall libAMGX.AMGX_unpin_memory(ptr::Ptr{Cvoid})::AMGX_RC
end

# no prototype is found for this function at amgx_c.h:185:18, please use with caution
function AMGX_install_signal_handler()
    @ccall libAMGX.AMGX_install_signal_handler()::AMGX_RC
end

# no prototype is found for this function at amgx_c.h:187:18, please use with caution
function AMGX_reset_signal_handler()
    @ccall libAMGX.AMGX_reset_signal_handler()::AMGX_RC
end

function AMGX_register_print_callback(func)
    @ccall libAMGX.AMGX_register_print_callback(func::AMGX_print_callback)::AMGX_RC
end

function AMGX_config_create(cfg, options)
    @ccall libAMGX.AMGX_config_create(cfg::Ptr{AMGX_config_handle},
                                      options::Cstring)::AMGX_RC
end

function AMGX_config_add_parameters(cfg, options)
    @ccall libAMGX.AMGX_config_add_parameters(cfg::Ptr{AMGX_config_handle},
                                              options::Cstring)::AMGX_RC
end

function AMGX_config_create_from_file(cfg, param_file)
    @ccall libAMGX.AMGX_config_create_from_file(cfg::Ptr{AMGX_config_handle},
                                                param_file::Cstring)::AMGX_RC
end

function AMGX_config_create_from_file_and_string(cfg, param_file, options)
    @ccall libAMGX.AMGX_config_create_from_file_and_string(cfg::Ptr{AMGX_config_handle},
                                                           param_file::Cstring,
                                                           options::Cstring)::AMGX_RC
end

function AMGX_config_get_default_number_of_rings(cfg, num_import_rings)
    @ccall libAMGX.AMGX_config_get_default_number_of_rings(cfg::AMGX_config_handle,
                                                           num_import_rings::Ptr{Cint})::AMGX_RC
end

function AMGX_config_destroy(cfg)
    @ccall libAMGX.AMGX_config_destroy(cfg::AMGX_config_handle)::AMGX_RC
end

function AMGX_resources_create(rsc, cfg, comm, device_num, devices)
    @ccall libAMGX.AMGX_resources_create(rsc::Ptr{AMGX_resources_handle},
                                         cfg::AMGX_config_handle, comm::Ptr{Cvoid},
                                         device_num::Cint, devices::Ptr{Cint})::AMGX_RC
end

function AMGX_resources_create_simple(rsc, cfg)
    @ccall libAMGX.AMGX_resources_create_simple(rsc::Ptr{AMGX_resources_handle},
                                                cfg::AMGX_config_handle)::AMGX_RC
end

function AMGX_resources_destroy(rsc)
    @ccall libAMGX.AMGX_resources_destroy(rsc::AMGX_resources_handle)::AMGX_RC
end

function AMGX_distribution_create(dist, cfg)
    @ccall libAMGX.AMGX_distribution_create(dist::Ptr{AMGX_distribution_handle},
                                            cfg::AMGX_config_handle)::AMGX_RC
end

function AMGX_distribution_destroy(dist)
    @ccall libAMGX.AMGX_distribution_destroy(dist::AMGX_distribution_handle)::AMGX_RC
end

function AMGX_distribution_set_partition_data(dist, info, partition_data)
    @ccall libAMGX.AMGX_distribution_set_partition_data(dist::AMGX_distribution_handle,
                                                        info::AMGX_DIST_PARTITION_INFO,
                                                        partition_data::Ptr{Cvoid})::AMGX_RC
end

function AMGX_distribution_set_32bit_colindices(dist, use32bit)
    @ccall libAMGX.AMGX_distribution_set_32bit_colindices(dist::AMGX_distribution_handle,
                                                          use32bit::Cint)::AMGX_RC
end

function AMGX_matrix_create(mtx, rsc, mode)
    @ccall libAMGX.AMGX_matrix_create(mtx::Ptr{AMGX_matrix_handle},
                                      rsc::AMGX_resources_handle, mode::AMGX_Mode)::AMGX_RC
end

function AMGX_matrix_destroy(mtx)
    @ccall libAMGX.AMGX_matrix_destroy(mtx::AMGX_matrix_handle)::AMGX_RC
end

function AMGX_matrix_upload_all(mtx, n, nnz, block_dimx, block_dimy, row_ptrs, col_indices,
                                data, diag_data)
    @ccall libAMGX.AMGX_matrix_upload_all(mtx::AMGX_matrix_handle, n::Cint, nnz::Cint,
                                          block_dimx::Cint, block_dimy::Cint,
                                          row_ptrs::Ptr{Cint}, col_indices::Ptr{Cint},
                                          data::Ptr{Cvoid}, diag_data::Ptr{Cvoid})::AMGX_RC
end

function AMGX_matrix_replace_coefficients(mtx, n, nnz, data, diag_data)
    @ccall libAMGX.AMGX_matrix_replace_coefficients(mtx::AMGX_matrix_handle, n::Cint,
                                                    nnz::Cint, data::Ptr{Cvoid},
                                                    diag_data::Ptr{Cvoid})::AMGX_RC
end

function AMGX_matrix_get_size(mtx, n, block_dimx, block_dimy)
    @ccall libAMGX.AMGX_matrix_get_size(mtx::AMGX_matrix_handle, n::Ptr{Cint},
                                        block_dimx::Ptr{Cint},
                                        block_dimy::Ptr{Cint})::AMGX_RC
end

function AMGX_matrix_get_nnz(mtx, nnz)
    @ccall libAMGX.AMGX_matrix_get_nnz(mtx::AMGX_matrix_handle, nnz::Ptr{Cint})::AMGX_RC
end

function AMGX_matrix_download_all(mtx, row_ptrs, col_indices, data, diag_data)
    @ccall libAMGX.AMGX_matrix_download_all(mtx::AMGX_matrix_handle, row_ptrs::Ptr{Cint},
                                            col_indices::Ptr{Cint}, data::Ptr{Cvoid},
                                            diag_data::Ptr{Ptr{Cvoid}})::AMGX_RC
end

function AMGX_matrix_vector_multiply(mtx, x, y)
    @ccall libAMGX.AMGX_matrix_vector_multiply(mtx::AMGX_matrix_handle,
                                               x::AMGX_vector_handle,
                                               y::AMGX_vector_handle)::AMGX_RC
end

function AMGX_matrix_set_boundary_separation(mtx, boundary_separation)
    @ccall libAMGX.AMGX_matrix_set_boundary_separation(mtx::AMGX_matrix_handle,
                                                       boundary_separation::Cint)::AMGX_RC
end

function AMGX_matrix_comm_from_maps(mtx, allocated_halo_depth, num_import_rings,
                                    max_num_neighbors, neighbors, send_ptrs, send_maps,
                                    recv_ptrs, recv_maps)
    @ccall libAMGX.AMGX_matrix_comm_from_maps(mtx::AMGX_matrix_handle,
                                              allocated_halo_depth::Cint,
                                              num_import_rings::Cint,
                                              max_num_neighbors::Cint, neighbors::Ptr{Cint},
                                              send_ptrs::Ptr{Cint}, send_maps::Ptr{Cint},
                                              recv_ptrs::Ptr{Cint},
                                              recv_maps::Ptr{Cint})::AMGX_RC
end

function AMGX_matrix_comm_from_maps_one_ring(mtx, allocated_halo_depth, num_neighbors,
                                             neighbors, send_sizes, send_maps, recv_sizes,
                                             recv_maps)
    @ccall libAMGX.AMGX_matrix_comm_from_maps_one_ring(mtx::AMGX_matrix_handle,
                                                       allocated_halo_depth::Cint,
                                                       num_neighbors::Cint,
                                                       neighbors::Ptr{Cint},
                                                       send_sizes::Ptr{Cint},
                                                       send_maps::Ptr{Ptr{Cint}},
                                                       recv_sizes::Ptr{Cint},
                                                       recv_maps::Ptr{Ptr{Cint}})::AMGX_RC
end

function AMGX_vector_create(vec, rsc, mode)
    @ccall libAMGX.AMGX_vector_create(vec::Ptr{AMGX_vector_handle},
                                      rsc::AMGX_resources_handle, mode::AMGX_Mode)::AMGX_RC
end

function AMGX_vector_destroy(vec)
    @ccall libAMGX.AMGX_vector_destroy(vec::AMGX_vector_handle)::AMGX_RC
end

function AMGX_vector_upload(vec, n, block_dim, data)
    @ccall libAMGX.AMGX_vector_upload(vec::AMGX_vector_handle, n::Cint, block_dim::Cint,
                                      data::Ptr{Cvoid})::AMGX_RC
end

function AMGX_vector_set_zero(vec, n, block_dim)
    @ccall libAMGX.AMGX_vector_set_zero(vec::AMGX_vector_handle, n::Cint,
                                        block_dim::Cint)::AMGX_RC
end

function AMGX_vector_set_random(vec, n)
    @ccall libAMGX.AMGX_vector_set_random(vec::AMGX_vector_handle, n::Cint)::AMGX_RC
end

function AMGX_vector_download(vec, data)
    @ccall libAMGX.AMGX_vector_download(vec::AMGX_vector_handle, data::Ptr{Cvoid})::AMGX_RC
end

function AMGX_vector_get_size(vec, n, block_dim)
    @ccall libAMGX.AMGX_vector_get_size(vec::AMGX_vector_handle, n::Ptr{Cint},
                                        block_dim::Ptr{Cint})::AMGX_RC
end

function AMGX_vector_bind(vec, mtx)
    @ccall libAMGX.AMGX_vector_bind(vec::AMGX_vector_handle,
                                    mtx::AMGX_matrix_handle)::AMGX_RC
end

function AMGX_solver_create(slv, rsc, mode, cfg_solver)
    @ccall libAMGX.AMGX_solver_create(slv::Ptr{AMGX_solver_handle},
                                      rsc::AMGX_resources_handle, mode::AMGX_Mode,
                                      cfg_solver::AMGX_config_handle)::AMGX_RC
end

function AMGX_solver_destroy(slv)
    @ccall libAMGX.AMGX_solver_destroy(slv::AMGX_solver_handle)::AMGX_RC
end

function AMGX_solver_setup(slv, mtx)
    @ccall libAMGX.AMGX_solver_setup(slv::AMGX_solver_handle,
                                     mtx::AMGX_matrix_handle)::AMGX_RC
end

function AMGX_solver_solve(slv, rhs, sol)
    @ccall libAMGX.AMGX_solver_solve(slv::AMGX_solver_handle, rhs::AMGX_vector_handle,
                                     sol::AMGX_vector_handle)::AMGX_RC
end

function AMGX_solver_solve_with_0_initial_guess(slv, rhs, sol)
    @ccall libAMGX.AMGX_solver_solve_with_0_initial_guess(slv::AMGX_solver_handle,
                                                          rhs::AMGX_vector_handle,
                                                          sol::AMGX_vector_handle)::AMGX_RC
end

function AMGX_solver_get_iterations_number(slv, n)
    @ccall libAMGX.AMGX_solver_get_iterations_number(slv::AMGX_solver_handle,
                                                     n::Ptr{Cint})::AMGX_RC
end

function AMGX_solver_get_iteration_residual(slv, it, idx, res)
    @ccall libAMGX.AMGX_solver_get_iteration_residual(slv::AMGX_solver_handle, it::Cint,
                                                      idx::Cint, res::Ptr{Cdouble})::AMGX_RC
end

function AMGX_solver_get_status(slv, st)
    @ccall libAMGX.AMGX_solver_get_status(slv::AMGX_solver_handle,
                                          st::Ptr{AMGX_SOLVE_STATUS})::AMGX_RC
end

function AMGX_solver_calculate_residual_norm(solver, mtx, rhs, x, norm_vector)
    @ccall libAMGX.AMGX_solver_calculate_residual_norm(solver::AMGX_solver_handle,
                                                       mtx::AMGX_matrix_handle,
                                                       rhs::AMGX_vector_handle,
                                                       x::AMGX_vector_handle,
                                                       norm_vector::Ptr{Cvoid})::AMGX_RC
end

function AMGX_write_system(mtx, rhs, sol, filename)
    @ccall libAMGX.AMGX_write_system(mtx::AMGX_matrix_handle, rhs::AMGX_vector_handle,
                                     sol::AMGX_vector_handle, filename::Cstring)::AMGX_RC
end

function AMGX_write_system_distributed(mtx, rhs, sol, filename, allocated_halo_depth,
                                       num_partitions, partition_sizes,
                                       partition_vector_size, partition_vector)
    @ccall libAMGX.AMGX_write_system_distributed(mtx::AMGX_matrix_handle,
                                                 rhs::AMGX_vector_handle,
                                                 sol::AMGX_vector_handle, filename::Cstring,
                                                 allocated_halo_depth::Cint,
                                                 num_partitions::Cint,
                                                 partition_sizes::Ptr{Cint},
                                                 partition_vector_size::Cint,
                                                 partition_vector::Ptr{Cint})::AMGX_RC
end

function AMGX_read_system(mtx, rhs, sol, filename)
    @ccall libAMGX.AMGX_read_system(mtx::AMGX_matrix_handle, rhs::AMGX_vector_handle,
                                    sol::AMGX_vector_handle, filename::Cstring)::AMGX_RC
end

function AMGX_read_system_distributed(mtx, rhs, sol, filename, allocated_halo_depth,
                                      num_partitions, partition_sizes,
                                      partition_vector_size, partition_vector)
    @ccall libAMGX.AMGX_read_system_distributed(mtx::AMGX_matrix_handle,
                                                rhs::AMGX_vector_handle,
                                                sol::AMGX_vector_handle, filename::Cstring,
                                                allocated_halo_depth::Cint,
                                                num_partitions::Cint,
                                                partition_sizes::Ptr{Cint},
                                                partition_vector_size::Cint,
                                                partition_vector::Ptr{Cint})::AMGX_RC
end

function AMGX_read_system_maps_one_ring(n, nnz, block_dimx, block_dimy, row_ptrs,
                                        col_indices, data, diag_data, rhs, sol,
                                        num_neighbors, neighbors, send_sizes, send_maps,
                                        recv_sizes, recv_maps, rsc, mode, filename,
                                        allocated_halo_depth, num_partitions,
                                        partition_sizes, partition_vector_size,
                                        partition_vector)
    @ccall libAMGX.AMGX_read_system_maps_one_ring(n::Ptr{Cint}, nnz::Ptr{Cint},
                                                  block_dimx::Ptr{Cint},
                                                  block_dimy::Ptr{Cint},
                                                  row_ptrs::Ptr{Ptr{Cint}},
                                                  col_indices::Ptr{Ptr{Cint}},
                                                  data::Ptr{Ptr{Cvoid}},
                                                  diag_data::Ptr{Ptr{Cvoid}},
                                                  rhs::Ptr{Ptr{Cvoid}},
                                                  sol::Ptr{Ptr{Cvoid}},
                                                  num_neighbors::Ptr{Cint},
                                                  neighbors::Ptr{Ptr{Cint}},
                                                  send_sizes::Ptr{Ptr{Cint}},
                                                  send_maps::Ptr{Ptr{Ptr{Cint}}},
                                                  recv_sizes::Ptr{Ptr{Cint}},
                                                  recv_maps::Ptr{Ptr{Ptr{Cint}}},
                                                  rsc::AMGX_resources_handle,
                                                  mode::AMGX_Mode, filename::Cstring,
                                                  allocated_halo_depth::Cint,
                                                  num_partitions::Cint,
                                                  partition_sizes::Ptr{Cint},
                                                  partition_vector_size::Cint,
                                                  partition_vector::Ptr{Cint})::AMGX_RC
end

function AMGX_free_system_maps_one_ring(row_ptrs, col_indices, data, diag_data, rhs, sol,
                                        num_neighbors, neighbors, send_sizes, send_maps,
                                        recv_sizes, recv_maps)
    @ccall libAMGX.AMGX_free_system_maps_one_ring(row_ptrs::Ptr{Cint},
                                                  col_indices::Ptr{Cint}, data::Ptr{Cvoid},
                                                  diag_data::Ptr{Cvoid}, rhs::Ptr{Cvoid},
                                                  sol::Ptr{Cvoid}, num_neighbors::Cint,
                                                  neighbors::Ptr{Cint},
                                                  send_sizes::Ptr{Cint},
                                                  send_maps::Ptr{Ptr{Cint}},
                                                  recv_sizes::Ptr{Cint},
                                                  recv_maps::Ptr{Ptr{Cint}})::AMGX_RC
end

function AMGX_generate_distributed_poisson_7pt(mtx, rhs, sol, allocated_halo_depth,
                                               num_import_rings, nx, ny, nz, px, py, pz)
    @ccall libAMGX.AMGX_generate_distributed_poisson_7pt(mtx::AMGX_matrix_handle,
                                                         rhs::AMGX_vector_handle,
                                                         sol::AMGX_vector_handle,
                                                         allocated_halo_depth::Cint,
                                                         num_import_rings::Cint, nx::Cint,
                                                         ny::Cint, nz::Cint, px::Cint,
                                                         py::Cint, pz::Cint)::AMGX_RC
end

function AMGX_write_parameters_description(filename, mode)
    @ccall libAMGX.AMGX_write_parameters_description(filename::Cstring,
                                                     mode::AMGX_GET_PARAMS_DESC_FLAG)::AMGX_RC
end

function AMGX_matrix_attach_coloring(mtx, row_coloring, num_rows, num_colors)
    @ccall libAMGX.AMGX_matrix_attach_coloring(mtx::AMGX_matrix_handle,
                                               row_coloring::Ptr{Cint}, num_rows::Cint,
                                               num_colors::Cint)::AMGX_RC
end

function AMGX_matrix_attach_geometry(mtx, geox, geoy, geoz, n)
    @ccall libAMGX.AMGX_matrix_attach_geometry(mtx::AMGX_matrix_handle, geox::Ptr{Cdouble},
                                               geoy::Ptr{Cdouble}, geoz::Ptr{Cdouble},
                                               n::Cint)::AMGX_RC
end

function AMGX_read_system_global(n, nnz, block_dimx, block_dimy, row_ptrs,
                                 col_indices_global, data, diag_data, rhs, sol, rsc, mode,
                                 filename, allocated_halo_depth, num_partitions,
                                 partition_sizes, partition_vector_size, partition_vector)
    @ccall libAMGX.AMGX_read_system_global(n::Ptr{Cint}, nnz::Ptr{Cint},
                                           block_dimx::Ptr{Cint}, block_dimy::Ptr{Cint},
                                           row_ptrs::Ptr{Ptr{Cint}},
                                           col_indices_global::Ptr{Ptr{Cvoid}},
                                           data::Ptr{Ptr{Cvoid}},
                                           diag_data::Ptr{Ptr{Cvoid}}, rhs::Ptr{Ptr{Cvoid}},
                                           sol::Ptr{Ptr{Cvoid}}, rsc::AMGX_resources_handle,
                                           mode::AMGX_Mode, filename::Cstring,
                                           allocated_halo_depth::Cint, num_partitions::Cint,
                                           partition_sizes::Ptr{Cint},
                                           partition_vector_size::Cint,
                                           partition_vector::Ptr{Cint})::AMGX_RC
end

function AMGX_matrix_upload_all_global(mtx, n_global, n, nnz, block_dimx, block_dimy,
                                       row_ptrs, col_indices_global, data, diag_data,
                                       allocated_halo_depth, num_import_rings,
                                       partition_vector)
    @ccall libAMGX.AMGX_matrix_upload_all_global(mtx::AMGX_matrix_handle, n_global::Cint,
                                                 n::Cint, nnz::Cint, block_dimx::Cint,
                                                 block_dimy::Cint, row_ptrs::Ptr{Cint},
                                                 col_indices_global::Ptr{Cvoid},
                                                 data::Ptr{Cvoid}, diag_data::Ptr{Cvoid},
                                                 allocated_halo_depth::Cint,
                                                 num_import_rings::Cint,
                                                 partition_vector::Ptr{Cint})::AMGX_RC
end

function AMGX_matrix_upload_all_global_32(mtx, n_global, n, nnz, block_dimx, block_dimy,
                                          row_ptrs, col_indices_global, data, diag_data,
                                          allocated_halo_depth, num_import_rings,
                                          partition_vector)
    @ccall libAMGX.AMGX_matrix_upload_all_global_32(mtx::AMGX_matrix_handle, n_global::Cint,
                                                    n::Cint, nnz::Cint, block_dimx::Cint,
                                                    block_dimy::Cint, row_ptrs::Ptr{Cint},
                                                    col_indices_global::Ptr{Cvoid},
                                                    data::Ptr{Cvoid}, diag_data::Ptr{Cvoid},
                                                    allocated_halo_depth::Cint,
                                                    num_import_rings::Cint,
                                                    partition_vector::Ptr{Cint})::AMGX_RC
end

function AMGX_matrix_upload_distributed(mtx, n_global, n, nnz, block_dimx, block_dimy,
                                        row_ptrs, col_indices_global, data, diag_data,
                                        distribution)
    @ccall libAMGX.AMGX_matrix_upload_distributed(mtx::AMGX_matrix_handle, n_global::Cint,
                                                  n::Cint, nnz::Cint, block_dimx::Cint,
                                                  block_dimy::Cint, row_ptrs::Ptr{Cint},
                                                  col_indices_global::Ptr{Cvoid},
                                                  data::Ptr{Cvoid}, diag_data::Ptr{Cvoid},
                                                  distribution::AMGX_distribution_handle)::AMGX_RC
end

function AMGX_matrix_check_symmetry(mtx, structurally_symmetric, symmetric)
    @ccall libAMGX.AMGX_matrix_check_symmetry(mtx::AMGX_matrix_handle,
                                              structurally_symmetric::Ptr{Cint},
                                              symmetric::Ptr{Cint})::AMGX_RC
end

function AMGX_matrix_check_diag_dominant(mtx, diag_dominant)
    @ccall libAMGX.AMGX_matrix_check_diag_dominant(mtx::AMGX_matrix_handle,
                                                   diag_dominant::Ptr{Cint})::AMGX_RC
end

function AMGX_solver_register_print_callback(func)
    @ccall libAMGX.AMGX_solver_register_print_callback(func::AMGX_print_callback)::AMGX_RC
end

function AMGX_solver_resetup(slv, mtx)
    @ccall libAMGX.AMGX_solver_resetup(slv::AMGX_solver_handle,
                                       mtx::AMGX_matrix_handle)::AMGX_RC
end

# Skipping MacroDefinition: AMGX_API __attribute__ ( ( visibility ( "default" ) ) )
