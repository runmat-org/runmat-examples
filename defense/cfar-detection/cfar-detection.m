% Cell-averaging CFAR on a range profile: each cell is compared with the average of the
% cells around it, scaled for a false-alarm probability of 1e-5. Two of the targets sit
% ten cells apart, inside each other's training window.
rng(3);
n = 2000;
x = abs(randn(n, 1) + 1i*randn(n, 1)).^2 / 2;      % noise power, mean 1
cells = [400 410 1200 1650];
snr_db = [13 13 14 16];
for q = 1:numel(cells)
    x(cells(q)) = x(cells(q)) + 10^(snr_db(q)/10);
end

guard = 2;  train = 16;  pfa = 1e-5;
nt = 2*train;
alpha = nt * (pfa^(-1/nt) - 1);
valid = (train+guard+1:n-train-guard)';
threshold = inf(n, 1);                       % no detection where the window does not fit
for m = valid'
    lead = x(m-train-guard:m-guard-1);
    lag = x(m+guard+1:m+guard+train);
    threshold(m) = alpha * (sum(lead) + sum(lag)) / nt;
end
hits = find(x > threshold);

plot((1:n)', 10*log10(x), valid, 10*log10(threshold(valid)));
hold on;
scatter(hits, 10*log10(x(hits)), 80, [0.95 0.35 0.3], 'filled');
hold off;
xlim([0 2000]); ylim([-30 25]);
legend('Range profile', 'CFAR threshold', 'Detections');
title('CA-CFAR detection');
xlabel('Range cell');
ylabel('Power (dB)');

fprintf('%d detections, at cells %s\n', numel(hits), mat2str(hits'));
fprintf('threshold %.1f dB above the local noise estimate for Pfa = 1e-5\n', 10*log10(alpha));
