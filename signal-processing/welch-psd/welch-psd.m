% Compare FFT magnitude with Welch PSD
Fs = 1000;
t = 0:1/Fs:1-1/Fs;
x = sin(2*pi*70*t) + 0.5*sin(2*pi*180*t) + 0.35*randn(size(t));
N = length(x);

Y = fft(x - sum(x) / N);
fFft = Fs*(0:N/2)/N;
pFft = abs(Y(1:N/2+1)) * 2/N;

[pxx, fWelch] = pwelch(x, hamming(256), 128, 512, Fs);

% The two tones, and how much the noise floor wanders in a quiet band (250-450 Hz)
[~, i1] = max(pxx);
masked = pxx;  masked(abs(fWelch - fWelch(i1)) < 20) = 0;
[~, i2] = max(masked);
band = fWelch > 250 & fWelch < 450;
quiet = pFft(fFft > 250 & fFft < 450).^2;
fprintf('Tones found at %.0f Hz and %.0f Hz\n', fWelch(i1), fWelch(i2));
fprintf('Noise floor max/median: single FFT %.1f, Welch %.1f\n', max(quiet)/median(quiet), max(pxx(band))/median(pxx(band)));

subplot(2, 1, 1);
plot(fFft, pFft);
title('Single-run FFT magnitude');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');

subplot(2, 1, 2);
plot(fWelch, pxx);
grid on;
title('Welch PSD estimate');
xlabel('Frequency (Hz)');
ylabel('PSD');
