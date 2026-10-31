% Spectrogram of a motor run-up: shaft orders rise with speed, a resonance stays put
fs = 2000;                                   % sample rate (Hz)
t = 0:1/fs:10-1/fs;
rpm = 600 + (6000 - 600) * t / t(end);       % speed ramps from 600 to 6000 rpm
phase = 2*pi*cumsum(rpm/60)/fs;
x = sin(phase) + 0.6*sin(2*phase) + 0.35*sin(3*phase) + 0.2*sin(4*phase);

% A structural resonance at 320 Hz, rung by broadband noise
r = 0.995;  w0 = 2*pi*320/fs;
ring = filter(1, [1 -2*r*cos(w0) r^2], randn(size(t)));
x = x + 0.004*ring + 0.05*randn(size(t));

[s, f, tt, ps] = spectrogram(x, hann(512), 384, 512, fs);
power_db = 10*log10(ps / max(ps(:)) + 1e-12);
keep = f <= 500;                             % show 0 to 500 Hz

imagesc([tt(1) tt(end)], [f(1) max(f(keep))], power_db(keep, :));
axis xy;
xticks(2:2:8);
clim([-70 0]);
colorbar;
title('Motor run-up spectrogram');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
