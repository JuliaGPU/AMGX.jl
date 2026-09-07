module TestClose

using AMGX, Test

# Exercise destruction errors without allocating native resources.
mutable struct TestObject <: AMGX.AMGXObject
    handle::Ptr{Cvoid}
    parent::Union{AMGX.Config, Nothing}
end

const fail_destroy = Ref(true)
const destroy_calls = Ref(0)
function destroy_test_object(handle)
    destroy_calls[] += 1
    return fail_destroy[] ? AMGX.API.AMGX_RC_BAD_PARAMETERS : AMGX.API.AMGX_RC_OK
end
AMGX.get_api_destroy_call(::Type{TestObject}) = destroy_test_object
function AMGX.dec_refcount_parents(object::TestObject)
    AMGX.dec_refcount!(object.parent)
    object.parent = nothing
    return nothing
end

@testset "Failed close preserves ownership" begin
    parent = AMGX.Config()
    AMGX.inc_refcount!(parent)
    handle = Ptr{Cvoid}(1)
    object = TestObject(handle, parent)

    @test_throws AMGX.AMGXException close(object)
    @test destroy_calls[] == 1
    @test object.handle == handle
    @test object.parent === parent
    @test parent.ref_count[] == 1

    fail_destroy[] = false
    @test close(object) === nothing
    @test destroy_calls[] == 2
    @test object.handle == C_NULL
    @test object.parent === nothing
    @test parent.ref_count[] == 0

    @test close(object) === nothing
    @test destroy_calls[] == 2
    @test parent.ref_count[] == 0
end

end # module
