% A broken rotor bar in a 4-pole, 60 Hz induction motor at 3% slip: sidebands at
% (1 - 2s)f and (1 + 2s)f in the stator current, measured against the supply line.
fs = 5000;  t = (0:1/fs:10)';  f = 60;  s = 0.03;
i = sin(2*pi*f*t) .* (1 + 0.02*cos(2*pi*2*s*f*t)) + 0.001*randn(size(t));
w = hann(numel(i));
P = 20*log10(2*abs(fft(i .* w)) / sum(w));
fq = (0:numel(i)-1)' * fs / numel(i);
df = fs / numel(i);                              % frequency resolution
k1 = round(55/df) + 1;  k2 = round(57/df) + 1;
[side, j] = max(P(k1:k2));
fprintf('lower sideband at %.2f Hz, expected %.2f Hz from the slip\n', (k1 + j - 2)*df, (1 - 2*s)*f);
fprintf('%.0f dB below the supply line\n', max(P) - side);

show = fq > 50 & fq < 70;
plot(fq(show), P(show));
title('Stator current spectrum, broken rotor bar');
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');
