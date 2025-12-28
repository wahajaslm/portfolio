function [ y ] = Rayleigh(x, Ts, K, M, SNR , Pp)
%RAYLEIGH Summary of this function goes here
%   Detailed explanation goes here

% Ts = 1e-4;   % Sample period (s)
fd = 100;    % Maximum Doppler shift

%% Path delay and gains
%By convention, the first delay is typically set to zero. 
%The first delay corresponds to the first arriving path.

%For indoor environments, path delays after the first are typically between 1 ns and 100 ns 
%(that is, between 1e-9 s and 1e-7 s).

%For outdoor environments, path delays after the first are typically between 100 ns and 10 ?s 
%(that is, between 1e-7 s and 1e-5 s). Very large delays in this range might correspond, 
%for example, to an area surrounded by mountains.

% The ability of a signal to resolve discrete paths is related to its bandwidth. 
% If the difference between the largest and smallest path delays is less than 
% about 1% of the symbol period, then the signal experiences the channel as if it had only one discrete path.

tau = [0.1 1.2 2.3 6.2 11.3]*Ts;  
PdB = linspace(0, -10, length(tau)) - length(tau)/20;

 nTrials = 10000;   % Number of trials
% N = 100;           % Number of samples per frame

h = rayleighchan(Ts, fd, tau, PdB);  % Create channel object
h.NormalizePathGains = 1;
h.ResetBeforeFiltering = 1;
h.StoreHistory = 1;
h % Show channel object

% Create an AWGNChannel and ErrorRate calculator System object
awgn = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)');
hErrorCalc = comm.ErrorRate;
awgn.SNR = SNR;

% x = 1*ones(10000,1);   % Random symbols

% %% Channel fading simulation
  for trial = 1:nTrials
% %     x = 1*ones(10000,1);   % Random symbols
%   x = randi([0 3],10000,1);   % Random symbols
% %     dpskSig = step(hMod, x);    % Modulated symbols
rxSig = sqrt(Pp) * filter(h, x);    % Channel filter

y = step(awgn,rxSig);   % Add Gaussian noise


  % Plot channel response
plot(h);                 

% Plot power of faded signal, versus sample number.
subplot (122)
plot(20*log10(abs(y)))
subplot (121)
plot(20*log10(abs(x)))

%     % The line below returns control to the command line in case
%     % the GUI is closed while this program is still running
      if isempty(findobj('name', 'Multipath Channel')), 
           break; 
      end;
 end
    

end

