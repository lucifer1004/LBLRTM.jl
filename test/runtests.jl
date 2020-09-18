using LBLRTM
using Unitful
using Test

@testset "Planck function and its inverse" begin
    ν = 1000u"cm^-1"
    T_0 = 300u"K"
    L = planck(ν, T_0)
    T_1 = radiance_to_bt(ν, L)
    T_2 = radiance_to_bt(ν)(L)

    @test T_0 == T_1
    @test T_0 == T_2
end
