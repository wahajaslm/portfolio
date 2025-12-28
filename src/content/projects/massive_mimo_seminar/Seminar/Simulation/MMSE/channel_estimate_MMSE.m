function [ aki_est ] = channel_estimate_MMSE(Y_pT, H, W, tau, Pd, ~, ~, K)
%CHANNEL_ESTIMATE_MMSE Summary of this function goes here
%   Detailed explanation goes here
aki = H.'*W;
aki_est = zeros(K,K);

for k=1:K    
aki_est(k,:) = mean(aki(k,:)) + sqrt(tau*Pd)*(var(aki(k,:)))./...
    ((tau*Pd)*(var(aki(k,:))+1) * (Y_pT(k,:) - sqrt(tau*Pd)*(mean(aki(k,:)))));
end


end

