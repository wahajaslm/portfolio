function [ W_MRT,Beta ] = MRT(H,tau_u,Pu,M,K)

% A : Linear Precoding Matrix
% B : Scalar of Wiener filter
% 
% One of the common methods is MRT which maximizes the SNR. MRT works well
% in the MU-MIMO system where the base station radiates low signal power to the
% users.
% MRT approaches MMSE when Ptr -> 0.


 B = conj(H);
 Beta = sqrt(trace(B*B')/(tau_u*Pu));
%  W_MRT = 1/Beta * conj(H);

alpha_MRT = sqrt((tau_u*Pu+1)/(M*K*tau_u*Pu));
W_MRT = alpha_MRT * conj(H);
end


