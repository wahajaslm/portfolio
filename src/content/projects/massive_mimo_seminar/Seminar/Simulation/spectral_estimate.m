% function 
% 
% 
% 
% akk_sq=abs(diag(aki_est)).^2;
% T_nd=logical(eye(K)) == 0;  % Non diagnol matrix for i != K
% aki_sum = sum((abs(aki_est.*T_nd)).^2,2); % summation of interfering aki elelemnts for i!=k
% eik_sq  = K/(tau_d*Pd + K);
% 
% 
% Rk= log2(1 + Pd*akk_sq/(Pd* eik_sq + Pd*aki_sum + 1) )
% 
% Stb=((T-tau_u-tau_d)/T) * sum(mean(log2(1 + Pd*akk_sq./(Pd*aki_sum + 1)),2));