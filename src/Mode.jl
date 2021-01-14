#=
For each mode, the first letter h or d specifies whether the matrix
data (and subsequent linear solver algorithms) will run on the host or
device. The second D or F specifies the precision (double or float) of
the Matrix data. The third D or F specifies the precision (double or float) of
any Vector (including right-handside or unknown vectors). The last I specifies
that 32-bit int types are used for all indices. Future versions of AMGX may
support additional precisions or mixed precision modes
=#

@enum Mode begin
    hDDI = Int(API.AMGX_mode_hDDI)
    hDFI = Int(API.AMGX_mode_hDFI)
    hFFI = Int(API.AMGX_mode_hFFI)
    dDDI = Int(API.AMGX_mode_dDDI)
    dDFI = Int(API.AMGX_mode_dDFI)
    dFFI = Int(API.AMGX_mode_dFFI)
    # TODO: Add support for theses:
    #=
    hIDI = Int(API.AMGX_mode_hIDI)
    hIFI = Int(API.AMGX_mode_hIFI)
    dIDI = Int(API.AMGX_mode_dIDI)
    dIFI = Int(API.AMGX_mode_dIFI)
    hZZI = Int(API.AMGX_mode_hZZI)
    hZCI = Int(API.AMGX_mode_hZCI)
    hCCI = Int(API.AMGX_mode_hCCI)
    dZZI = Int(API.AMGX_mode_dZZI)
    dZCI = Int(API.AMGX_mode_dZCI)
    dCCI = Int(API.AMGX_mode_dCCI)  
    =#
end

function _type(c::Char)
    c == 'D' ? Float64 :
    c == 'F' ? Float32 :
    c == 'I' ? Cint :
    c == 'Z' ? ComplexF64 :
    c == 'C' ? ComplexF32 :
    error("unexpected char '$c'")
end

vector_type(m::Mode) = _type(string(m)[3])
matrix_type(m::Mode) = _type(string(m)[2])

