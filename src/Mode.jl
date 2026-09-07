#=
For each mode, the first letter h or d specifies whether the matrix
data (and subsequent linear solver algorithms) will run on the host or
device. The second D or F specifies the precision (double or float) of
any Vector (including right-hand-side or unknown vectors). The third D or F
specifies the precision of the Matrix data. The last I specifies
that 32-bit int types are used for all indices. Future versions of AMGX may
support additional precisions or mixed precision modes
=#

"""
    Mode

Selects where AMGX runs and at what precision. The available modes are `hDDI`,
`hDFI`, `hFFI`, `dDDI`, `dDFI` and `dFFI`, read as four characters:

| position | meaning |
|:--|:--|
| 1 | `h` on the host, `d` on the device |
| 2 | precision of vectors — `D` for `Float64`, `F` for `Float32` |
| 3 | precision of matrix coefficients — `D` or `F` |
| 4 | `I`, 32-bit integer indices (`Cint`) |

So `dDDI` runs on the GPU with `Float64` throughout, while `dDFI` keeps `Float64`
vectors alongside `Float32` matrix coefficients.

Julia arrays passed to [`upload!`](@ref) must match the precision the mode
declares. Use [`vector_type`](@ref) and [`matrix_type`](@ref) to obtain them.

!!! note
    Upstream AMGX does not support mixed-precision GPU *solves* on CUDA 10.1 or
    later. Use `dDDI` or `dFFI` for solving; `dDFI` still supports uploads and
    downloads.
"""
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

"""
    vector_type(m::Mode)

The Julia element type AMGX expects for vectors in mode `m`, e.g. `Float64` for
`dDDI`.
"""
vector_type(m::Mode) = _type(string(m)[2])

"""
    matrix_type(m::Mode)

The Julia element type AMGX expects for matrix coefficients in mode `m`, e.g.
`Float32` for `dDFI`.
"""
matrix_type(m::Mode) = _type(string(m)[3])
