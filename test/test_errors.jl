module TestErrors

using AMGX, Test

@test AMGX.error_string(AMGX.API.AMGX_RC_BAD_PARAMETERS) == "Incorrect parameters for amgx call."

end
