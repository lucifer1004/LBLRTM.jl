parse_float(x) = parse(Float64, x)

function run_lblrtm(work_dir::String, ν_s::Float64, ν_e::Float64)::Tuple{Array{Float64,1},Array{Float64,1}}
    ν_s -= 25
    ν_e += 25

    @info "Entering $(pwd()) ..."
    cd(work_dir)
    @info "Entered."

    @info "Checking system links..."
    requirements = ["lblrtm", "TAPE3"]
    for link in requirements
        @assert(islink(link) || isfile(link), "$link does not exist.")
    end
    @info "System links OK."

    @info "Removing last run's files..."
    rm("TAPE5", force=true)
    rm("TAPE6", force=true)
    rm("TAPE7", force=true)
    rm("TAPE8", force=true)
    rm("TAPE10", force=true)
    @info "Removed."

    IHIRAC = 1
    ILBLF4 = 2
    ICNTNM = 1
    IAERSL = 1
    IEMIT = 1
    ISCAN = 0
    IFILTR = 0
    IPLOT = 0
    ITEST = 0
    IATM = 1
    IMRG = 0
    ILAS = 0
    IOD = 1
    IXSECT = 0
    NPTS = 80
    ISOTPL = 0
    IBRD = 0

    SAMPLE = 4
    DVSET = 0.0 # Spectral resolution for calculation
    ALFAL0 = 0.04
    AVMASS = 36.0
    DPTMIN = 0.0002
    DPTFAC = 0.001
    IFNFLG = 0
    DVOUT = 0.1 # Spectral resolution for output
    
    TBOUND = 300.0 # Boundary temperature
    SREMIS = 1.0 # Emissivity coefficient - Rand 0

    MODEL = 6 # U.S.Standard
    ITYPE = 2
    IBMAX = 0
    ZERO = 0
    NOPRNT = 0

    H1 = 100.0
    H2 = 0.0
    ANGLE = 180.0
    @info "Writing TAPE5..."
    open("TAPE5", "w") do tape5
        write(tape5, "\$ LBLRTM INPUT\n") # Record 1.1
        write(tape5, " HI=$IHIRAC F4=$ILBLF4 CN=$ICNTNM AE=$IAERSL EM=$IEMIT SC=$ISCAN FI=$IFILTR PL=$IPLOT TS=$ITEST AM=$IATM MG=$IMRG LA=$ILAS OD=$IOD XS=$IXSECT   00   00\n") # Record 1.2
        write(tape5, @sprintf("%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%5d%10.3f\n", ν_s, ν_e, SAMPLE, DVSET, ALFAL0, AVMASS, DPTMIN, DPTFAC, IFNFLG, DVOUT)) # Record 1.3
        write(tape5, @sprintf("%10.3f%10.3f\n", TBOUND, SREMIS)) # Record 1.4
        write(tape5, @sprintf("%5d%5d%5d%5d%5d\n", MODEL, ITYPE, IBMAX, ZERO, NOPRNT)) # Record 3.1
        write(tape5, @sprintf("%10.3f%10.3f%10.3f\n", H1, H2, ANGLE)) # Record 3.2
        write(tape5, "\n") # Record 3.3A
        write(tape5, "\n") # Record 4.1
        write(tape5, "-1.\n")
        write(tape5, @sprintf(
"""
\$ Transfer to ASCII plotting data
 HI=0 F4=0 CN=0 AE=0 EM=0 SC=0 FI=0 PL=1 TS=0 AM=0 MG=0 LA=0 MS=0 XS=0    0    0
# Plot title not used
%10.3f%10.3f   10.2000  100.0000    5    0   12    0     1.000 0  0    0
    0.0000    1.2000    7.0200    0.2000    4    0    1    1    0    0 0    3 27
%10.3f%10.3f   10.2000  100.0000    5    0   12    0     1.000 0  0    0
    0.0000    1.2000    7.0200    0.2000    4    0    1    1    1    0 0    3 28
-1.
""", ν_s, ν_e, ν_s, ν_e))
    end
    @info "TAPE5 OK."

    # Run LBLRTM
    @info "Running LBLRTM..."
    @time run(`./lblrtm`)
    @info "LBLRTM completed."

    # Collect result
    @info "Collecting result..."
    wavenumber = []
    brightness_temperature = []
    open("TAPE28") do io
        see_header = false
        see_data = false
        for line in eachline(io)
            if !see_header
                if findfirst("WAVENUMBER", line) ≠ nothing
                    see_header = true
                end
            elseif !see_data
                see_data = true
            else
                wb, bt = map(parse_float, split(strip(line), r"\s+"))
                append!(wavenumber, wb)
                append!(brightness_temperature, bt)
            end
        end
    end
    @info "Results collected."

    return (wavenumber, brightness_temperature)
end