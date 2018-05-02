% This work is licensed under the Creative Commons Attribution 4.0
% International License. To view a copy of this license, visit
% http://creativecommons.org/licenses/by/4.0/ or send a letter to
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

% calculate the bandwidth limits for each channel
cutoff = [carfreq-1/Tb carfreq+1/Tb]*2*Tn;
% pre-allocate filters matrix
H = zeros(impulseL, N);

% first channel lowpass
[tmp1,tmp2] = butter(10, cutoff(1,2));
H(:,1) = ifft(freqz(tmp1, tmp2, impulseL, 'whole', 1/Tn));

% others channels bandpass
for n = 2:N
    [tmp1,tmp2] = butter(10, [cutoff(n,1) cutoff(n,2)]);
    H(:,n) = ifft(freqz(tmp1, tmp2, impulseL, 'whole', 1/Tn));
end

% pre-allocate to please Matlab then filter
len2 = size(data,1)+impulseL-1;
% convolute the signal with the impulses responses
s2High = conv2(data, 1, H);

% demodulate
t = (0:Tn:(len2-1)*Tn)';
t = t(:,ones(1,N));
s2 = s2High.*cos(2*pi*carfreq'.*t);
s2(:,1) = s2High(:,1);
for i = 2:N
    [bf,af] = butter(5, carfreq(n)*2*Tn);
    impulse = ifft(freqz(bf, af, impulseL, 'whole', 1/Tn));
    s2(:,i) = conv(s2(:,i), impulse(1:+1:end), 'same'); % forward
    s2(:,i) = conv(s2(:,i), impulse(end:-1:1), 'same'); % backward
end

% filter the canal noise with the adequate filter
s2 = conv2(rcos, 1, s2);
% invert channel (no idea why)
polarity = kron(ones(1,ceil(N/2)), [1 -1]);
s2 = s2 .* polarity(1:N);
% find filters delay
[~,i] = max(H);
% compensate the start trame
s2t = s2(span*beta+i-2+shift:end, :);
% generate the index vector
s2i = 1:beta:beta*size(x,1);
% extract the values at index
decoded = s2t(s2i,:);
% quantize the extracted values
decoded = decoded>0;

% hit markers *PEW* *PEW*
figure, hold on
stem(s2t(:,2))
stem(s2i, s2t(s2i,2), 'r*', 'MarkerSize', 8.0)
grid, hold off

%% plot visual representation of the transmission
figure
subplot(2,1,1)
stem(linspace(0, len2*Tn, len2), s2High)
title('Représentation temporelle du signal reçu')
ylabel('Amplitude (v)'), xlabel('Times (s)')
legend(strcat("Canal ", num2str((1:N)')), 'Location', 'SouthWest')
grid

subplot(2,1,2)
plot(linspace(0, 1/Tn-1, len2), pow2db(abs(fft(s2High/len2)).^2/Z0)+30)
ylim([-60 10])
title('Représentation fréquentielle du signal reçu')
ylabel('Puissance (dBm)'), xlabel('Frequency (Hz)')
legend(strcat("Canal ", num2str((1:N)')), 'Location', 'North')
grid
