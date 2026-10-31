% Time-frequency workflow with spectrogram
Fs = 1000;
t = 0:1/Fs:1-1/Fs;
x = sin(2*pi*60*t) + sin(2*pi*(120 + 80*t).*t);

[s, f, tt, ps] = spectrogram(x, hamming(128), 96, 256, Fs);
power_db = 10 * log10(ps + 1e-12);

% Follow the sweep: the strongest bin above 90 Hz in the first and last frames
above = f > 90;
fa = f(above);
[~, k1] = max(ps(above, 1));
[~, k2] = max(ps(above, end));
fb = f(~above);
[~, k0] = max(ps(~above, 1));
fprintf('Steady tone: %.1f Hz (bin width %.1f Hz)\n', fb(k0), f(2) - f(1));
fprintf('Sweep: %.0f Hz at %.2f s, %.0f Hz at %.2f s\n', fa(k1), tt(1), fa(k2), tt(end));

subplot(2, 1, 1);
plot(t, x);
title('Signal with changing frequency content');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2, 1, 2);
imagesc([tt(1) tt(end)], [f(1) f(end)], power_db);
axis xy;
colorbar;
title('Spectrogram power');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
