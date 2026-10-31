% Spectrogram of an equipment-shelf accelerometer through a compressed flight-test
% card: taxi, takeoff roll, climb and cruise. The propeller's blade-pass tone follows
% engine speed; the shelf's 170 Hz mode rings with the broadband level.
fs = 600;                                    % sample rate (Hz)
t = (0:1/fs:90-1/fs)';
n = numel(t);
rng(4);

% Propeller speed (rpm) and broadband level for each phase, eased between phases.
ramp = @(a, b, t0, t1) a + (b - a) * min(max((t - t0) / (t1 - t0), 0), 1);
rpm = ramp(1000, 1700, 8, 12) .* (t < 30) + ramp(1700, 1600, 30, 34) .* (t >= 30 & t < 60) + ramp(1600, 1400, 60, 64) .* (t >= 60);
level = 0.15 + 1.0 * (t >= 10 & t < 30) + 0.45 * (t >= 30 & t < 60) + 0.12 * (t >= 60);

% Four-bladed propeller: blade pass and its second harmonic.
phase = 2*pi*cumsum(4 * rpm / 60) / fs;
tone = 0.8 * sin(phase) + 0.3 * sin(2 * phase);

% The shelf's mode at 170 Hz, rung by broadband vibration.
r = 0.99;  w0 = 2*pi*170/fs;
ring = filter(1, [1 -2*r*cos(w0) r^2], randn(n, 1));
x = tone + level .* (0.25 * randn(n, 1) + 0.03 * ring);

[s, f, tt, ps] = spectrogram(x, hann(256), 0, 256, fs);
power_db = 10*log10(ps / max(ps(:)) + 1e-12);

imagesc([tt(1) tt(end)], [f(1) f(end)], power_db);
axis xy;
xlim([0 90]); xticks(0:15:90);
clim([-50 0]);
colorbar;
title('Shelf vibration through a flight');
xlabel('Time (s)');
ylabel('Frequency (Hz)');

% Measured: the blade-pass tone at takeoff and in cruise, and the shelf mode's level.
band = f >= 50 & f <= 130;
fb = f(band);
[~, i1] = max(mean(ps(band, tt > 15 & tt < 28), 2));
[~, i2] = max(mean(ps(band, tt > 70), 2));
mode = f >= 155 & f <= 185;
drop = 10 * log10(mean(mean(ps(mode, tt > 15 & tt < 28))) / mean(mean(ps(mode, tt > 70))));
fprintf('blade-pass tone %.0f Hz on the takeoff roll, %.0f Hz in cruise\n', fb(i1), fb(i2));
fprintf('170 Hz shelf mode %.1f dB lower in cruise than on the takeoff roll\n', drop);
