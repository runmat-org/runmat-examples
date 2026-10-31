% Pulse compression of a 10 us chirp with 5 MHz of bandwidth. Two targets
% 120 m apart near 12 km overlap in the raw return; the matched filter
% separates them and lifts them out of the noise.
c = 3e8;  fs = 50e6;  T = 10e-6;  B = 5e6;
t = (0:round(T*fs)-1)' / fs;
pulse = exp(1i*pi*(B/T)*(t - T/2).^2);
n = 2^14;
R = [12000; 12120];  amp = [1; 0.7];
rx = zeros(n, 1);
for q = 1:2
    idx = round(2*R(q)/c*fs) + (1:numel(pulse))';
    rx(idx) = rx(idx) + amp(q) * pulse;
end
rng(1);
noise = (randn(n, 1) + 1i*randn(n, 1)) / sqrt(2);
rx = rx + noise;

y = ifft(fft(rx) .* conj(fft(pulse, n)));
yn = ifft(fft(noise) .* conj(fft(pulse, n)));    % noise alone
r_km = (0:n-1)' * c / (2*fs) / 1000;

plot(r_km, 20*log10(abs(rx)), r_km, 20*log10(abs(y)));
xlim([11.9 12.3]); ylim([-20 60]);
legend('Raw return', 'After pulse compression');
title('Two targets 120 m apart');
xlabel('Range (km)');
ylabel('Amplitude (dB)');

% Measured: where the two peaks land, and how far compression lifts them above the noise.
win = r_km > 11.9 & r_km < 12.3;
yw = abs(y) .* win;
[p1, k1] = max(yw);
yw(max(k1-10, 1):k1+10) = 0;
[~, k2] = max(yw);
snr_in = 10*log10(amp(1)^2 / mean(abs(noise).^2));
snr_out = 10*log10(p1^2 / mean(abs(yn).^2));
fprintf('peaks at %.3f and %.3f km, %.0f m apart (resolution c/2B = %.0f m)\n', r_km(k1), r_km(k2), abs(r_km(k2) - r_km(k1))*1000, c/(2*B));
fprintf('compression gain %.1f dB, against %.1f dB expected for the %d samples in the pulse\n', snr_out - snr_in, 10*log10(numel(pulse)), numel(pulse));
