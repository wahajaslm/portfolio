function [ Stb ] = spectral_efficiency_bf(T,tau_u,tau_d,Rk)
%SPECTRAL_EFFICIENCY Beamforming Summary of this function goes here
%   Detailed explanation goes here

 Stb = ((T - tau_u - tau_d) / T) * sum(Rk);

end

