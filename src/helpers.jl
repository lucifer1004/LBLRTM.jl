planck(ν, T) =
    u"W*m^-2*cm*sr^-1"(c_1 * ν^3 / (exp(c_2 * ν / T) - 1) * 1u"sr^-1")

radiance_to_bt(ν, L) = u"K"(c_2 * ν / log(c_1 * ν^3 / L + 1))
radiance_to_bt(ν) = L -> radiance_to_bt(ν, L)

get_molecular_weight(gas) = LBLRTM_GAS_MOLECULAR_WEIGHTS[LBLRTM_GAS_INDEX[gas]]
