"""
    run_lnfl(work_dir, ν_s, ν_e, skipped)

Run LNFL in `work_dir`. The wavenumber range is from `ν_s` to `ν_e`, and the species in `skipped` are skipped.
"""

function run_lnfl(work_dir::String, ν_s, ν_e, skipped::Array{String,1}=[])
    ν_s -= 25
    ν_e += 25
    
    @info "Entering $(pwd()) ..."
    cd(work_dir)
    @info "Entered."

    @info "Checking system links..."
    requirements = ["lnfl", "TAPE1", "co2_co2_brd_param", "co2_h2o_brd_param", "o2_h2o_brd_param",
                    "o2_uv_brd_param", "spd_dep_param", "wv_co2_brd_param"]
    for link in requirements
        @assert(islink(link) || isfile(link), "$link does not exist.")
    end
    @info "System links OK."

    @info "Removing last run's files..."
    rm("TAPE3", force=true)
    rm("TAPE5", force=true)
    rm("TAPE6", force=true)
    rm("TAPE7", force=true)
    rm("TAPE8", force=true)
    rm("TAPE10", force=true)
    @info "Removed."

    species = repeat(["1"], length(LBLRTM_GAS_INDEX))
    for i in skipped
        species[LBLRTM_GAS_INDEX[i]] = "0"
    end
    species = join(species)

    # Both borders are extended according to the manual.
    @info "Writing TAPE5..."
    open("TAPE5", "w") do tape5
        write(tape5, @sprintf("\$ f100 format\n%10.3f%10.3f\n", ν_s, ν_e))
        write(tape5, @sprintf("%s    LNOUT EXBRD\n", species))
        write(tape5, "%%%%%%%%%%%%%%%%%%\n")
        write(tape5, "12345678901234567890123456789012345678901234567890123456789012345678901234567890")
    end
    @info "TAPE5 OK."

    # Run LNFL
    @info "Running LNFL..."
    @time run(`./lnfl`)
    @info "LNFL completed."
end
