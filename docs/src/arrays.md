# Vectors and matrices

## `AMGXVector`

An [`AMGX.AMGXVector`](@ref) is created from a `Resources` and a `Mode`:

```julia
v = AMGX.AMGXVector(resources, AMGX.dDDI)
```

Fill it with [`AMGX.upload!`](@ref):

```julia
AMGX.upload!(v, [1.0, 2.0, 3.0])
```

For block systems, give the block dimension:

```julia
v_block = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.upload!(v_block, [1.0, 2.0, 3.0, 4.0]; block_dim=2)
```

Read the data back with `Vector`, `Array` or `CuVector`:

```julia
v_h = Vector(v)
```

or into a preallocated buffer with `copy!`, avoiding an allocation:

```julia
v_h_buffer = zeros(3)
copy!(v_h_buffer, v)
```

Data can be uploaded from and downloaded to arrays that already live on the GPU:

```julia
using CUDA
v_cu = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.upload!(v_cu, CuVector([1.0, 2.0, 3.0]))

cu_buffer = CUDA.zeros(Float64, 3)
copy!(cu_buffer, v_cu)
```

A vector can be sized and zeroed in one step, which is how solution vectors are
usually prepared:

```julia
AMGX.set_zero!(v, 5)
```

## `AMGXMatrix`

Matrices are stored in **CSR** format. Julia's `SparseMatrixCSC` is CSC, so a
conversion is needed when coming from `SparseArrays`.

```julia
matrix = AMGX.AMGXMatrix(resources, AMGX.dDDI)
```

The simplest route is to upload a `CuSparseMatrixCSR` directly:

```julia
using CUDA
AMGX.upload!(matrix, CUDA.CUSPARSE.CuSparseMatrixCSR(A))
```

The three CSR arrays can also be given explicitly. Note that `row_ptrs` and
`col_indices` are **zero-based**, as AMGX expects — not Julia's one-based
indexing:

```julia
AMGX.upload!(matrix,
    Cint[0, 1, 3],   # row_ptrs
    Cint[1, 0, 1],   # col_indices
    [1.0, 2.0, 3.0]  # values
)
```

These arrays may live on the host or on the device.

### Replacing coefficients

If the sparsity structure is fixed and only the values change, replace them
rather than rebuilding the matrix:

```julia
AMGX.replace_coefficients!(matrix, [3.0, 2.0, 1.0])
```

Follow this with [`AMGX.resetup!`](@ref) rather than a full
[`AMGX.setup!`](@ref); see [Solving](@ref).

### Separate diagonals

`upload!` and `replace_coefficients!` accept a `diag_data` argument holding the
diagonal separately from the CSR arrays, with `n * block_dimx * block_dimy`
entries in AoS layout. Pass `nothing` — the default — when the diagonal is part
of the matrix itself.
