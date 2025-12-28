function [Rk] = rate_ZF(~, ~, ~, tau_u, tau_d, Pd, Pu, ~, K , aki_est)


akk = diag(aki_est) ; % diagnoal elemets of estimated aki
T=logical(eye(K)) == 0;  % Non diagnol matrix for i != K

aki_sum=sum((abs(aki_est.*T)).^2,2); % summation of interfering aki elelemnts for i!=k

% Acheivable Rate
Rk = mean(log2(1 + Pd*(abs(akk)).^2 ./ ( (K*Pd/(tau_d*Pd + K*(tau_u*Pu+1))) + (Pd*aki_sum+1))),2) ; 
end