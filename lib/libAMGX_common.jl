# Automatically generated using Clang.jl


# Skipping MacroDefinition: AMGX_API __attribute__ ( ( visibility ( "default" ) ) )
# Skipping MacroDefinition: AMGX_SAFE_CALL ( rc ) \
#{ AMGX_RC err ; char msg [ 4096 ] ; switch ( err = ( rc ) ) { case AMGX_RC_OK : break ; default : fprintf ( stderr , "AMGX ERROR: file %s line %6d\n" , __FILE__ , __LINE__ ) ; AMGX_get_error_string ( err , msg , 4096 ) ; fprintf ( stderr , "AMGX ERROR: %s\n" , msg ) ; AMGX_abort ( NULL , 1 ) ; break ; } \
#}

@cenum AMGX_FLAGS::UInt32 begin
    SOLVE_STATS = 1
    GRID_STATS = 2
    CONFIG = 4
    PROFILE_STATS = 8
    VISDATA = 16
    RESIDUAL_HISTORY = 32
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


const AMGX_print_callback = Ptr{Cvoid}

struct AMGX_config_handle_struct
    AMGX_config_handle_dummy::UInt8
end

const AMGX_config_handle = Ptr{AMGX_config_handle_struct}

struct AMGX_resources_handle_struct
    AMGX_resources_handle_dummy::UInt8
end

const AMGX_resources_handle = Ptr{AMGX_resources_handle_struct}

struct AMGX_matrix_handle_struct
    AMGX_matrix_handle_dummy::UInt8
end

const AMGX_matrix_handle = Ptr{AMGX_matrix_handle_struct}

struct AMGX_vector_handle_struct
    AMGX_vector_handle_dummy::UInt8
end

const AMGX_vector_handle = Ptr{AMGX_vector_handle_struct}

struct AMGX_solver_handle_struct
    AMGX_solver_handle_dummy::UInt8
end

const AMGX_solver_handle = Ptr{AMGX_solver_handle_struct}

struct AMGX_distribution_handle_struct
    AMGX_distribution_handle_dummy::UInt8
end

const AMGX_distribution_handle = Ptr{AMGX_distribution_handle_struct}

# Skipping MacroDefinition: AMGX_ASSEMBLE_MODE ( memSpace , vecPrec , matPrec , indPrec ) \
#( memSpace * AMGX_MemorySpaceBase + vecPrec * AMGX_VecPrecisionBase + matPrec * AMGX_MatPrecisionBase + indPrec * AMGX_IndPrecisionBase \
#)
# Skipping MacroDefinition: AMGX_GET_MODE_VAL ( type , mode ) ( ( type ) ( ( ( mode ) / type ## Base ) % type ## Size ) )
# Skipping MacroDefinition: AMGX_SET_MODE_VAL ( type , mode , value ) ( ( AMGX_Mode ) ( ( mode ) + ( ( value ) - AMGX_GET_MODE_VAL ( type , mode ) ) * type ## Base ) )
# Skipping MacroDefinition: AMGX_FORALL_BUILDS_HOST ( codeLineMacro ) codeLineMacro ( AMGX_mode_hDDI ) codeLineMacro ( AMGX_mode_hDFI ) codeLineMacro ( AMGX_mode_hFFI )
# Skipping MacroDefinition: AMGX_FORINTVEC_BUILDS_HOST ( codeLineMacro ) codeLineMacro ( AMGX_mode_hIDI ) codeLineMacro ( AMGX_mode_hIFI )
# Skipping MacroDefinition: AMGX_FORALL_BUILDS_DEVICE ( codeLineMacro ) codeLineMacro ( AMGX_mode_dDDI ) codeLineMacro ( AMGX_mode_dDFI ) codeLineMacro ( AMGX_mode_dFFI )
# Skipping MacroDefinition: AMGX_FORINTVEC_BUILDS_DEVICE ( codeLineMacro ) codeLineMacro ( AMGX_mode_dIDI ) codeLineMacro ( AMGX_mode_dIFI )
# Skipping MacroDefinition: AMGX_FORCOMPLEX_BUILDS_DEVICE ( codeLineMacro ) codeLineMacro ( AMGX_mode_dZZI ) codeLineMacro ( AMGX_mode_dZCI ) codeLineMacro ( AMGX_mode_dCCI )
# Skipping MacroDefinition: AMGX_FORCOMPLEX_BUILDS_HOST ( codeLineMacro ) codeLineMacro ( AMGX_mode_hZZI ) codeLineMacro ( AMGX_mode_hZCI ) codeLineMacro ( AMGX_mode_hCCI )
# Skipping MacroDefinition: AMGX_FORALL_BUILDS ( codeLineMacro ) AMGX_FORALL_BUILDS_HOST ( codeLineMacro ) AMGX_FORALL_BUILDS_DEVICE ( codeLineMacro )
# Skipping MacroDefinition: AMGX_FORCOMPLEX_BUILDS ( codeLineMacro ) AMGX_FORCOMPLEX_BUILDS_DEVICE ( codeLineMacro ) AMGX_FORCOMPLEX_BUILDS_HOST ( codeLineMacro )
# Skipping MacroDefinition: AMGX_FORINTVEC_BUILDS ( codeLineMacro ) AMGX_FORINTVEC_BUILDS_HOST ( codeLineMacro ) AMGX_FORINTVEC_BUILDS_DEVICE ( codeLineMacro )

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

