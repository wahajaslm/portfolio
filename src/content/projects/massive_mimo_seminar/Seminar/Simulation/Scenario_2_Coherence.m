%% The Massive MU-MIMO Downlink System over Rayleigh Fading Channel

%% Assumptions
% Single cell massive MU-MIMO system, which means no intra-cell interference
% M >= K

%% Scenario
% 1) increasing the number of antenna arrays with fixing the number of user
clear
close all

T=10:5:250;                  % Coherence Interval 1msx200 Khz 
K = 5;                  % users
M = 50;                % Antennas   
% Ptr = -20:20 ;          % Base station Power in db
n=nextpow2(K);           

tau_u = K;                % tau >= K  Pair wise Orthognal pilot codes 
tau_d =tau_u;
Pu = 1;                 % Avg Transmit power per user 0 db
% Pp = tau * Pu;          % Transmit power  
sigma = 1;              % Noise variance

monte = 100;           % Monte carlo simulations


SNR= 20;            % SNR= 20 db
Pd = 10.^(SNR/10) ;     % Avg Transmit power at Base Station Pd == SNR    
                           % since noise variance(sigma) =1
         

Stb_ZF_bf=zeros(monte,length(T));
Stb_ZF = zeros(monte,length(T));

Stb_MRT_bf=zeros(monte,length(T));
Stb_MRT=zeros(monte,length(T));



for m=1:monte;


    
%% Channel Model
% MxK  Channel Matrix
   H=randn(M,K);
%% uplink Orthognal Pilot Signal Generation
% pilot = hadamard(2^n);% Pilot Symbols  nxn
% pilot_ul=pilot(1:K,1:tau); % Pilot Symbols  Kxtau
% pilot_ul=orth(randn(K,tau)); % Pilot Symbols  Kxtau

%% Noise Model Uplink
N_ul = sigma*randn(M,tau_u);           % Zero mean unity variance 
% Np_ul = N * conj(pilot);      


%%  downlink Orthognal Pilot Signal Generation
% pilot = hadamard(2^n);% Pilot Symbols  nxn
% pilot_dl = pilot(1:K,1:tau);  % Pilot Symbols  K x tau for downlink
%% uplink Orthognal Pilot Signal Generation
% pilot_dl=orth(rand(K,tau));
A = randn(K);  % random iid ~N(0,1)
oA = orth( A ); % orthogonal basis
pilot_dl = bsxfun(@rdivide, oA, sqrt( sum( oA.^2 ) ) ); % normalize to unit length

%% Noise Model
N_dl = sigma*randn(K,tau_d);           % Zero mean unity variance 
% N_pT  = N_dl * conj(pilot_dl);     


%%  --------------UPLINK--------------- %%


%% Channel Estimate
H_est = ((tau_u*Pu)/(tau_u*Pu + 1))*H + (sqrt(tau_u*Pu)/(tau_u*Pu + 1)) * N_ul ; 

%% Linear Precoding
[W_ZF,Beta_ZF]     = ZF(H_est,tau_u,Pu,M,K); % Zero Forcing
% [W_MMSE,Beta_MMSE] = MMSE(H_est, K, Ptr); % MMSE
[W_MRT,Beta_MRT]   = MRT(H_est,tau_u,Pu,M,K); % MRT 





%% ------------------- Downlink----------------------- %%



%% Coherence Time Simulations
 for l=1:length(T)                       
%Transmitted
Y_pT_ZF_tx = sqrt(tau_u*Pd) * H' * W_ZF* pilot_dl + N_dl;

% Received
%% ZF Received Channel model after pilot processing at each user
Y_pT_ZF =  Y_pT_ZF_tx * pilot_dl';


%% ZERO FORCING ZF
% ZF Channel Estimate for each user
% aki is the channel model for each user which represents the kth row and ith coloumn 
% Each Kth row  corresponds to respective Kth user data
aki_ZF = channel_estimate_ZF(Y_pT_ZF, H, W_ZF, tau_u, tau_d, Pd, Pu, M, K);
% ZF Acheivable Rate Rk for each user
Rk_ZF  = rate_ZF(Y_pT_ZF, H, W_ZF, tau_u, tau_d, Pd, Pu, M, K, aki_ZF);  
% ZF Spectral efficiency WITH beamforming Stb for scenario
Stb_ZF_bf(m,l) = spectral_efficiency_bf(T(l),tau_u,tau_d,Rk_ZF);
% ZF Spectral efficiency WITHOUT beamforming Stb for scenario
Stb_ZF(m,l) = spectral_efficiency_ZF(T(l),tau_u, Pd, Pu, M, K);


%% MRT Received Channel model after pilot processing at each user
Y_pT_MRT_tx = sqrt(tau_u*Pd) * H' * W_MRT*pilot_dl  + N_dl;
Y_pT_MRT = Y_pT_MRT_tx * pilot_dl';

%% MRT
% MRT Channel Estimate for each user
% aki is the channel model for each user which represents the kth row and ith coloumn 
% Each Kth row  corresponds to respective Kth user data
aki_MRT = channel_estimate_MRT(Y_pT_MRT, H, W_MRT, tau_u, tau_d, Pd, Pu, M, K);
% MRT Acheivable Rate Rk for each user
Rk_MRT  = rate_MRT(Y_pT_MRT, H, W_MRT, tau_u,tau_d, Pd, Pu, M, K, aki_MRT);  
% MRT Spectral efficiency WITH BEAMFORMING Stb for scenario
Stb_MRT_bf(m,l) = spectral_efficiency_bf(T(l),tau_u,tau_d,Rk_MRT);
% MRT Spectral efficiency WITHOUT BEAMFORMING Stb for scenario
Stb_MRT(m,l)=spectral_efficiency_MRT(T(l),tau_u, Pd, Pu, M, K);


 end
end

avg_Stb_ZF_bf  = mean(Stb_ZF_bf);
avg_Stb_ZF  = mean(Stb_ZF);


avg_Stb_MRT_bf  = mean(Stb_MRT_bf);
avg_Stb_MRT = mean(Stb_MRT);


% figure
% hold on
% 
% plot(T,avg_Stb_ZF_bf','b')
% plot(T,avg_Stb_ZF','--b')
% 
% 
% plot(T,avg_Stb_MRT_bf','r')
% plot(T,avg_Stb_MRT','--r')
% 
%   legend('ZF-BF','ZF','MRT-BF','MRT')
% 
% xlabel('Coherence Time (Symbols)')
% ylabel('Spectral Efficiency(bits/s/Hz)')
% 


%Latex Plot
% (x0,y0) = position of the lower left side of the figure
x0=0;
y0=0;
width=4 ;height=4;
% Run figure command before drawing the plot
figure('Units','inches',...
'Position',[x0 y0 width height],... 
'PaperPositionMode','auto');

hold on
plot(T,avg_Stb_ZF_bf','b','LineWidth',1.7)
plot(T,avg_Stb_ZF','--b','LineWidth',1.7)
plot(T,avg_Stb_MRT_bf','r','LineWidth',1.7)
plot(T,avg_Stb_MRT','--r','LineWidth',1.7)

axis([10 200 0 35]) 
set(gca,...
'Units','normalized',... 
'YTick',0:5:35,... 
'XTick',0:200/4:200,... 
'Position',[.15 .2 .75 .7],... 
'FontUnits','points',... 
'FontWeight','normal',... 
'FontSize',7,... 
'FontName','Times')

ylabel('Spectral Efficiency (bits/s/Hz)',... 
'FontUnits','points',... 
'interpreter','latex',... 
'FontSize',7,... 
'FontName','Times')
xlabel('Coherence Interval $T$ (symbols)',... 
'FontUnits','points',...
'interpreter','latex',... 
'FontWeight','normal',... 
'FontSize',7,... 
'FontName','Times')
% ZF-BF','ZF','MRT-BF','MRT
leg=legend({'With Beamforming Training','Without Beamforming Training'},... 
'FontUnits','points',... 
'interpreter','latex',...
'FontSize',5,...
'FontWeight','normal',... 
'FontName','Times',... 
'Location','NorthWest');
hText = findobj(leg, 'type', 'text');
set(hText,'color', [0 0 0]); 
legend_markers = findobj(get(leg, 'Children'), ...
    'Type', 'line','Marker', 'none');
for i = 1:length(legend_markers)
    set(legend_markers(i), 'Color', 'k');
end
legend boxoff
title('Spectral Efficiency versus Coherence Interval',... 
'FontUnits','points',... 
'FontWeight','normal',... 
'FontSize',7,... 
'FontName','Times')

str1 = '$K=5, M=50$';
str2 = '$P_u$=0 dB, $P_d$=20 dB';
text(120,4,str1,'Interpreter','latex','FontSize',6)
text(120,2,str2,'Interpreter','latex','FontSize',6)

print -depsc2 T_K5_M50.eps


%% Results
% Achievable rate versus transmission power,
% The spectral efficiency versus the number of antenna arrays, 
% The spectral efficiency versus the number of users, and 
% The energy efficiency versus the spectral efficiency.


% %% MMSE Channel Estimate for each user
% % aki is the channel model for each user which represents the kth row and ith coloumn 
% % Each Kth row  corresponds to respective Kth user data
% aki_MMSE = channel_estimate_MMSE(Y_pT, H, W, tau, Pd, Pu, M, K);





