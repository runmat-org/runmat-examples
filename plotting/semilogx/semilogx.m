frequency = logspace(0, 5, 400);
cutoff = 750;
gain_db = 20*log10(1 ./ sqrt(1 + (frequency/cutoff).^4));

h = semilogx(frequency, gain_db);
set(h, 'LineWidth', 2);
title('Low-Pass Frequency Response');
xlabel('Frequency (Hz)');
ylabel('Gain (dB)');
grid on;
