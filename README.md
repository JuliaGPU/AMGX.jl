# AMGX.jl 

[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaComputing.github.io/AMGX.jl/stable)
[![Build Status](https://github.com/JuliaComputing/AMGX.jl/workflows/CI/badge.svg)](https://github.com/JuliaComputing/AMGX.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaComputing/AMGX.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaComputing/AMGX.jl)

The AMGX.jl package provides an interface for using NVIDIA's [AMGX](https://github.com/NVIDIA/AMGX) library from the Julia language.

For installation instructions, overview and examples, see the
[documentation](https://JuliaComputing.github.io/AMGX.jl/stable).

TODO:

- "The modes that were used to create obj and mtx objects must match, otherwise a run-time error will be generated. Similarly, they must all be bound to the same Resources object." test these runtime errors.
- Check if runtime errors occur in matrix_replace_coefficients if the wrong size
is passed in.

Issues:

- `!!! detected some memory leaks in the code: trying to free non-empty
temporary device pool !!!` while running tests

