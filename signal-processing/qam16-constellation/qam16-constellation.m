% 16-QAM: map random symbols, add noise, plot the received constellation
M = 16;
symbols = randi([0 M-1], 2000, 1);
tx = qammod(symbols, M);

snr_db = 20;
noise_power = mean(abs(tx).^2) / 10^(snr_db/10);
rx = tx + sqrt(noise_power/2) * (randn(size(tx)) + 1i*randn(size(tx)));

evm = 100 * sqrt(mean(abs(rx - tx).^2) / mean(abs(tx).^2));
fprintf('Symbols: %d at %d dB SNR\n', numel(rx), snr_db);
fprintf('Error vector magnitude: %.1f%%\n', evm);
scatterplot(rx);
title('16-QAM at 20 dB SNR');
xlabel('In-phase');
ylabel('Quadrature');
