function [ Stb ] = genie_estimate(aki_est,T, tau_u, tau_d,Pd, K)
%GENIE_ESTIMATE Summary of this function goes here
%   Detailed explanation goes here

akk_sq=abs(diag(aki_est)).^2;
T_nd=logical(eye(K)) == 0;  % Non diagnol matrix for i != K
aki_sum = sum((abs(aki_est.*T_nd)).^2,2); % summation of interfering aki elelemnts for i!=k

Stb=((T-tau_u-tau_d)/T) * sum(mean(log2(1 + Pd*akk_sq./(Pd*aki_sum + 1)),2));

end

