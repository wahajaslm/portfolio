function [ R_MRT ] = rate_MRT( ~, ~, ~, ~,tau_d, Pd, ~, ~, K, aki_est )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
akk=diag(aki_est);

T_nd=logical(eye(K)) == 0;  % Non diagnol matrix for i != K
aki_sum=sum((abs(aki_est.*T_nd)).^2,2); % summation of interfering aki elelemnts for i!=k

R_MRT=mean(log2(1 + Pd*(abs(akk)).^2 ./ ((K*Pd/(tau_d*Pd+K))+ (Pd*aki_sum+1))),2); 


end