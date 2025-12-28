function [ Stb ] = spectral_efficiency_MRT(T,tau_u, Pd, Pu, M, K)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
Stb= ((T-tau_u)/T)*K*log2(1+ (M/K)*(tau_u*Pu*Pd)/((Pd+1)*(tau_u*Pu+1)));

end