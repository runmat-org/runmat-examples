% Alpha-band (8 to 12 Hz) power in one EEG channel, eyes open against eyes closed:
% closing the eyes raises the 10 Hz rhythm.
rng(4);
fs = 256;  t = (0:1/fs:60-1/fs)';  n = numel(t);
pink = filter(1, [1 -0.95], randn(n, 1));
open_eeg = pink + 0.4*sin(2*pi*10.2*t + 0.3*randn(n, 1));
closed_eeg = pink + 1.6*sin(2*pi*10.2*t + 0.3*randn(n, 1));
[po, f] = pwelch(open_eeg, hann(512), 256, 512, fs);
pc = pwelch(closed_eeg, hann(512), 256, 512, fs);
band = f >= 8 & f <= 12;
ao = trapz(f(band), po(band));  ac = trapz(f(band), pc(band));
[~, k] = max(pc(band));  fb = f(band);
fprintf('alpha power %.1f times higher with eyes closed\n', ac / ao);
fprintf('alpha peak at %.1f Hz\n', fb(k));

semilogy(f, po, f, pc);
xlim([1 40]);
legend('Eyes open', 'Eyes closed');
title('EEG power spectrum');
xlabel('Frequency (Hz)');
ylabel('Power (uV^2/Hz)');
