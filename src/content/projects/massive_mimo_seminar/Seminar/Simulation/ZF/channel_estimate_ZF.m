function [ aki_est ] = channel_estimate_ZF(Y_pT, ~, ~, tau_u, tau_d, Pd, Pu, M, K)
%CHANNEL_ESTIMATE_ZF Summary of this function goes here
%   Detailed explanation goes here


delta=eye(K);
% aki = H.'*W;
aki_est = zeros(K,K);   




for k=1:K
aki_est(k,:) = (sqrt(tau_d*Pd)./(tau_d*Pd+K*(tau_u*Pu+1))).*(Y_pT(k,:));
end

aki_est = aki_est + (sqrt(K*(M-K)*tau_u*Pu*(tau_u*Pu+1))./(tau_d*Pd+K*(tau_u*Pu+1))).*delta;
