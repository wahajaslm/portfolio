function [ Stb ] = spectral_efficiency_ZF(T,tau_u, Pd, Pu, M, K)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
Stb= ((T-tau_u)/T)*K*log2(1 + ((M-K)/K) * ((tau_u*Pu*Pd)/(tau_u*Pu+Pd+1)));

end