% This work is licensed under the Creative Commons Attribution 4.0
% International License. To view a copy of this license, visit
% http://creativecommons.org/licenses/by/4.0/ or send a letter to
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

% handle which maps 0,1 to -1,1
codesymbol = @(x)x.*2-1;

x = randi([0 1], M, N);
a = codesymbol(x);
rcos = rcosdesign(roll, span, beta);
s1 = upfirdn(a, rcos, beta);
len = size(s1, 1);

carfreq = (0:N-1)'*L*2/Tb; % carrier frequencies
carrier = cos(carfreq*linspace(0, 2*pi*len*Tn, len))';

%% plot impulsions
% iX = linspace(0, span/1e2, 1e2*span+1);
% iY = rcosdesign(roll, span, 1e2);
% plot(iX, iY' * ones(1, N) .* ...
%      cos(carfreq*linspace(0, 2*pi, span*1e2+1))')
% ylim([-max(iY)*1.1 +max(iY)*1.1])
% title("Représentation temporelle des impulsions utilisées")
% ylabel("Coefficient d'amplitude"), xlabel("Temps (s)")
% legend(strcat("Canal ", num2str((1:N)')))
% grid
% clear('iX', 'iY')

%% modulate by carriers
s1High = s1 .* carrier;

% normalise power to 'pwr' dBm
avgPower = bandpower(s1High)/Z0*(1000/pwr);
s1High = s1High./sqrt(avgPower*Z0);

%% plot visual representation of the transmission
figure
subplot(2,1,1)
stem(linspace(0, len*Tn, len), s1High)
title('Représentation temporelle du signal envoyé')
ylabel('Amplitude (v)'), xlabel('Times (s)')
legend('Canal 1', 'Canal 2', 'Location', 'SouthWest')
grid

subplot(2,1,2)
plot(linspace(0, 1/Tn-1, len), pow2db(abs(fft(s1High/len)).^2/Z0)+30)
ylim([-60 0]), xlim([0 79])
title('Représentation fréquentielle du signal envoyé')
ylabel('Puissance (dBm)'), xlabel('Frequency (Hz)')
legend('Canal 1', 'Canal 2', 'Location', 'North')
grid

%% sum all channels before transmission
data = sum(s1High, 2);
