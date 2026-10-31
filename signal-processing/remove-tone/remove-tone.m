% One signal, start to finish: spectrum, filter design, filter vs filtfilt, Welch check
rng(0);
fs = 1000;                                  % sample rate (Hz)
t = 0:1/fs:2-1/fs;
tone = sin(2*pi*50*t);                      % the signal we want
x = tone + 0.5*sin(2*pi*120*t) + 0.3*randn(size(t));

% 1. Spectrum: single-sided amplitude
N = numel(x);
X = abs(fft(x)) / N;
f = (0:N/2) * fs / N;
A = 2 * X(1:N/2+1);
[~, i1] = max(A);
fprintf('largest peak: %.1f Hz\n', f(i1));

% 2. Low-pass Butterworth, cutoff 80 Hz
[b, a] = butter(4, 80/(fs/2));

% 3. Causal filter against zero-phase filtfilt
yc = filter(b, a, x);
yz = filtfilt(b, a, x);
w = 2*pi*50/fs;  k = 0:numel(b)-1;
H50 = sum(b .* exp(-1i*w*k)) / sum(a .* exp(-1i*w*k));
fprintf('filter delay at 50 Hz: %.1f samples (%.1f ms)\n', -angle(H50)/w, -angle(H50)/w/fs*1000);
fprintf('RMS error vs clean tone: filter %.3f, filtfilt %.3f\n', rms(yc - tone), rms(yz - tone));

% 4. Welch PSD before and after: attenuation at 120 Hz
[Pxx, fw] = pwelch(x, hamming(256), 128, 256, fs);
Pyy = pwelch(yz, hamming(256), 128, 256, fs);
[~, i120] = min(abs(fw - 120));
fprintf('120 Hz tone reduced by %.1f dB\n', 10*log10(Pxx(i120) / Pyy(i120)));

subplot(2, 2, 1); plot(f, A); xlim([0 200]); xlabel('Frequency (Hz)'); ylabel('Amplitude'); title('Spectrum (fft)');
[H, fh] = freqz(b, a, 512, fs);
subplot(2, 2, 2); plot(fh, 20*log10(abs(H))); ylim([-80 5]); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Butterworth response');
subplot(2, 2, 3); plot(t, tone, t, yc, t, yz); xlim([0.5 0.6]); xlabel('Time (s)'); ylabel('Amplitude'); legend('clean', 'filter', 'filtfilt'); title('filter lags, filtfilt does not');
subplot(2, 2, 4); plot(fw, 10*log10(Pxx), fw, 10*log10(Pyy)); xlabel('Frequency (Hz)'); ylabel('PSD (dB/Hz)'); legend('before', 'after'); title('Welch PSD');
