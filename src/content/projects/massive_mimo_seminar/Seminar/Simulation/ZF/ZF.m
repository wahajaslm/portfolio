function [ W_ZF,Beta ] = ZF(H,tau_u,Pu,M,K)

% A : Linear Precoding Matrix
% B : Scalar of Wiener filter
% 
% ZF precoding is one technique of linear precoding in which the interuser interference
% can be cancelled out at each user. This precoding is assumed to implement
% a pseudo-inverse of the channel matrix.
% ZF approaches MMSE when Ptr -> Infinity.


 B = conj(H) * (H.'* conj(H))^(-1); % Generic
 Beta = sqrt(trace(B*B')/(tau_u*Pu));
%   W_ZF = 1/Beta * conj(H) * (H.'* conj(H))^(-1);   %H.' = nonconjugate transpose

 alpha_ZF = sqrt(((M-K)*tau_u*Pu)/(K*(tau_u*Pu+1)));
 W_ZF = alpha_ZF * conj(H) * (H.'* conj(H))^(-1);   %H.' = nonconjugate transpose

end


