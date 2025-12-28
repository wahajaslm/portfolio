%% The Massive MU-MIMO Downlink System over Rayleigh Fading Channel

%% Assumptions
% Single cell massive MU-MIMO system, which means no intra-cell interference
% M >= K

%% Scenario
% 1) increasing the number of antenna arrays with fixing the number of user
clear
% close all

% col={'r','--r','-*r','-xr','b','--b','-*b','-xb'};
% col={'r','--r','b','--b'};%,'b','--b','-*b','-xb'};
col={'r','*r','--r','*r','b','*b','--b','*b'};

T=200;                  % Coherence Interval 1msx200 Khz 
K = 5;                 % users
M = [10 50];                % Antennas   
% Ptr = -20:20 ;          % Base station Power in db
n=nextpow2(K); 
tau_u = K;                % tau >= K  Pair wise Orthognal pilot codes 
tau_d =tau_u;
Pu = 1;                 % Avg Transmit power per user 0 db
% Pp = tau * Pu;          % Transmit power  
sigma = 1;              % Noise variance

monte = 200;           % Monte carlo simulations


SNR= 0:0.5:20;            % SNR= 30 db

Stb_ZF_bf=zeros(monte,length(SNR));
Stb_ZF = zeros(monte,length(SNR));

Stb_MRT_bf=zeros(monte,length(SNR));
Stb_MRT=zeros(monte,length(SNR));

Stb_ZF_gen = zeros(monte,length(SNR));
Stb_MRT_gen = zeros(monte,length(SNR));
% W = 


x0=0;
y0=0;
width=4 ;height=4;
figure('Units','inches',...
'Position',[x0 y0 width height],... 
'PaperPositionMode','auto');
for mi=1:length(M)

for m=1:monte;

    
%% Channel Model
%Rayleigh Channel model
h_re = 1/sqrt(2)*randn(M(mi),K);
h_im = 1/sqrt(2)*randn(M(mi),K);
H = h_re + 1i*h_im;                  % MxK  Channel Matrix
%     H=rand(M(mi),K);
%% uplink Orthognal Pilot Signal Generation
% pilot_ul=orth(rand(K,tau));
% pilot_ul = hadamard(K);  % Pilot Symbols  Tau x K
% y = Rayleigh(x, Ts, K, M, SNR, Pp)  
% pilot_ul=orth(rand(K,tau));

%% Noise Model Uplink
N_ul = 1*randn(M(mi),tau_u);           % Zero mean unity variance 
% Np_ul = N * conj(pilot);      


%%  downlink Orthognal Pilot Signal Generation
% pilot_dl = orth(hadamard(K));  % Pilot Symbols  K x tau for downlink
A = randn(K);  % random iid ~N(0,1)
oA = orth( A ); % orthogonal basis
pilot_dl = bsxfun(@rdivide, oA, sqrt( sum( oA.^2 ) ) ); % normalize to unit length

% A = orth(randn(K,tau));  % % orthogonal basis random iid ~N(0,1)
%  pilot_dl = bsxfun(@rdivide, A, sqrt(sum(A.^2))); % normalize to unit length

 % pilot_dl=orth(randn(K,tau));
% pilot_dl=orth(rand(K,tau));

%% Noise Model
N_dl = 1*randn(K,tau_d);           % Zero mean unity variance 

% N_pT  = N_dl * conj(pilot_dl);     


%%  --------------UPLINK--------------- %%


%% Channel Estimate
H_est = ((tau_u*Pu)/(tau_u*Pu + 1))*H + (sqrt(tau_u*Pu)/(tau_u*Pu + 1)) * N_ul ; 

%% Linear Precoding
[W_ZF,Beta_ZF]     = ZF(H_est,tau_u,Pu,M(mi),K); % Zero Forcing
% [W_MMSE,Beta_MMSE] = MMSE(H_est, K, Ptr); % MMSE
[W_MRT,Beta_MRT]   = MRT(H_est,tau_u,Pu,M(mi),K); % MRT 



%% SNR Simulations
 for l=1:length(SNR)                       

Pd = 10.^(SNR(l)/10) ;     % Avg Transmit power at Base Station Pd == SNR    
                           % since noise variance(sigma) =1
         

%% ------------------- Downlink----------------------- %%



%% ------------------- Zero Forcing--------------------%%
%Perfect channel estimate
aki_ZF=H.'* W_ZF;
%Transmitted
Y_pT_ZF_tx = sqrt(tau_d*Pd)*H.'* W_ZF* pilot_dl + N_dl;
% Received
%% ZF Received Channel model after pilot processing at each user
Y_pT_ZF =  Y_pT_ZF_tx * (pilot_dl)';

%% ZERO FORCING ZF
% ZF Channel Estimate for each user
% aki is the channel model for each user which represents the kth row and ith coloumn 
% Each Kth row  corresponds to respective Kth user data
aki_ZF_est = channel_estimate_ZF(Y_pT_ZF, H, W_ZF, tau_u, tau_d, Pd, Pu, M(mi), K);
% ZF Acheivable Rate Rk for each user
Rk_ZF  = rate_ZF(Y_pT_ZF, H, W_ZF, tau_u, tau_d, Pd, Pu, M(mi), K, aki_ZF_est);  
% ZF Spectral efficiency WITH beamforming Stb for scenario
Stb_ZF_bf(m,l) = spectral_efficiency_bf(T,tau_u,tau_d,Rk_ZF);
% ZF Spectral efficiency WITHOUT beamforming Stb for scenario
Stb_ZF(m,l) = spectral_efficiency_ZF(T,tau_u, Pd, Pu, M(mi), K);
%Spectral efficiency genie receiver
Stb_ZF_gen(m,l)= genie_estimate(aki_ZF, T, tau_u, tau_d, Pd, K);



%% ------------------- MRT--------------------%%
%% MRT
%Perfect channel estimate
aki_MRT=H.'* W_MRT;
%% MRT Received Channel model after pilot processing at each user
Y_pT_MRT_tx = sqrt(tau_d*Pd)*H.'* W_MRT* pilot_dl  + N_dl;
Y_pT_MRT = Y_pT_MRT_tx * (pilot_dl)';

%% MRT
% MRT Channel Estimate for each user
% aki is the channel model for each user which represents the kth row and ith coloumn 
% Each Kth row  corresponds to respective Kth user data
aki_MRT_est = channel_estimate_MRT(Y_pT_MRT, H, W_MRT, tau_u, tau_d, Pd, Pu, M(mi), K);
% MRT Acheivable Rate Rk for each user
Rk_MRT  = rate_MRT(Y_pT_MRT, H, W_MRT, tau_u,tau_d, Pd, Pu, M(mi), K, aki_MRT_est);  
% MRT Spectral efficiency WITH BEAMFORMING Stb for scenario
Stb_MRT_bf(m,l) = spectral_efficiency_bf(T,tau_u,tau_d,Rk_MRT);
% MRT Spectral efficiency WITHOUT BEAMFORMING Stb for scenario
Stb_MRT(m,l)=spectral_efficiency_MRT(T,tau_u, Pd, Pu, M(mi), K);
%Spectral efficiency genie receiver
Stb_MRT_gen(m,l)= genie_estimate(aki_MRT, T, tau_u, tau_d, Pd, K);


 end
end

avg_Stb_ZF_gen= mean(Stb_ZF_gen);
avg_Stb_ZF_bf  = mean(Stb_ZF_bf);
avg_Stb_ZF  = mean(Stb_ZF);

avg_Stb_MRT_gen= mean(Stb_MRT_gen);
avg_Stb_MRT_bf  = mean(Stb_MRT_bf);
avg_Stb_MRT = mean(Stb_MRT);


% % figure
% hold on
% 
% plot(SNR,avg_Stb_ZF_bf','b')
% plot(SNR,avg_Stb_ZF','--b')
% 
% 
% plot(SNR,avg_Stb_MRT_bf','r')
% plot(SNR,avg_Stb_MRT','--r')
% 
%   legend('ZF-BF','ZF','MRT-BF','MRT')
% 
% xlabel('SNR(db)')
% ylabel('Spectral Efficiency(bits/s/Hz)')

% Run figure command before drawing the plot
hold on

% plot(SNR,avg_Stb_ZF_bf',col{2*mi-2+1},'LineWidth',1.7)
% plot(SNR,avg_Stb_ZF,col{2*mi},'LineWidth',1.7)

plot(SNR,avg_Stb_ZF_bf',col{4*mi-4+1},'LineWidth',1.7)
plot(SNR(1:5:end),avg_Stb_ZF_gen(1:5:end)',col{4*mi-4+2},'LineWidth',1.4)

% % plot(SNR,avg_Stb_ZF_gen,col{4*mi-4+1})
% plot(SNR,avg_Stb_ZF,col{4*mi-4+2},'LineWidth',1.7)
 plot(SNR,avg_Stb_MRT_bf',col{4*mi-1},'LineWidth',1.7)
 plot(SNR(1:5:end),avg_Stb_MRT_gen(1:5:end)',col{4*mi},'LineWidth',1.4)
%  plot(SNR(1:5:end),avg_Stb_MRT(1:5:end)',col{4*mi},'LineWidth',1.4)

axis([0 20 0 30]) 
set(gca,...
'Units','normalized',... 
'YTick',0:5:30,... 
'XTick',0:20/10:20,... 
'Position',[.15 .2 .75 .7],... 
'FontUnits','points',... 
'FontWeight','normal',... 
'FontSize',7,... 
'FontName','Times')

ylabel('Spectral Efficiency(bits/s/Hz)',... 
'FontUnits','points',... 
'interpreter','latex',... 
'FontSize',7,... 
'FontName','Times')

xlabel('SNR (dB)',... 
'FontUnits','points',...
'interpreter','latex',... 
'FontWeight','normal',... 
'FontSize',7,... 
'FontName','Times')
% ZF-BF','ZF','MRT-BF','MRT
% leg=legend({'ZF-With Beamforming','ZF',...
% 'MRT-Beamforming','MRT'},... 
% 'FontUnits','points',... 
% 'interpreter','latex',...
% 'FontSize',5,...
% 'FontWeight','normal',... 
% 'FontName','Times',... 
% 'Location','northwest');
leg=legend({'ZF-With Beamforming Training','ZF,MRT-With Genie Reciver','MRT-With Beamforming Training',},... 
'FontUnits','points',... 
'interpreter','latex',...
'FontSize',6,...
'FontWeight','normal',... 
'FontName','Times',... 
'Location','northwest');

hText = findobj(leg, 'type', 'text');
set(hText,'color', [0 0 0]); 
legend_markers = findobj(get(leg, 'Children'), ...
    'Type', 'line','Marker', 'none');
for i = 1:length(legend_markers)
    set(legend_markers(i), 'Color', 'k');
end
% set(leg,'position',[0.15 0.81 0.61 0.01])
ch2 = get(leg, 'Children');
set(ch2(1:3:end), 'Color', 'k')
set(leg,'color','w')
legend boxoff
title('Spectral Efficiency versus SNR',... 
'FontUnits','points',... 
'FontWeight','normal',... 
'FontSize',5,... 
'FontName','Times')

str1 = '$K=5, M(mi)=50$';
str2 = '$P_u$=0 dB, $P_d$=20 dB';
text(120,4,str1,'Interpreter','latex','FontSize',6)
text(120,2,str2,'Interpreter','latex','FontSize',6)

print -depsc2 SNR_K5_GENIE.eps

end
%% Results
% Achievable rate versus transmission power,
% The spectral efficiency versus the number of antenna arrays, 
% The spectral efficiency versus the number of users, and 
% The energy efficiency versus the spectral efficiency.


% %% MMSE Channel Estimate for each user
% % aki is the channel model for each user which represents the kth row and ith coloumn 
% % Each Kth row  corresponds to respective Kth user data
% aki_MMSE = channel_estimate_MMSE(Y_pT, H, W, tau, Pd, Pu, M(mi), K);





