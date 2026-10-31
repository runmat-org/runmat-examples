% A shaft in a bore: how often do they interfere, and when is the estimate good enough?
rng(1);
N = 1e6;
shaft = 25.000 + 0.010*randn(N, 1);        % mm
bore = 25.030 + 0.012*randn(N, 1);         % mm
growth = 0.002 + 0.0006*randn(N, 1);       % thermal growth of the shaft, mm
clearance = bore - shaft - growth;

p = mean(clearance < 0);
se = sqrt(p*(1 - p)/N);
fprintf('Interference probability %.3f%%, standard error %.3f%%\n', 100*p, 100*se);
fprintf('Mean clearance %.4f mm; 0.1st percentile %.4f mm\n', mean(clearance), prctile(clearance, 0.1));

% The running estimate settles inside a band that narrows as 1/sqrt(n)
n = (1:N)';
running = cumsum(clearance < 0) ./ n;
k = unique(round(logspace(2, 6, 200)))';
band = 2*sqrt(p*(1 - p) ./ k);

subplot(2, 1, 1);
histogram(clearance, 120, 'Normalization', 'pdf');
xline(0, 'r', 'interference');
title('Clearance from a million draws');
xlabel('Clearance (mm)');
ylabel('Density');
grid on;

subplot(2, 1, 2);
semilogx(k, 100*running(k), 'LineWidth', 1.5);
hold on;
semilogx(k, 100*(p + band), '--');
semilogx(k, 100*(p - band), '--');
hold off;
title('Running estimate and its two-standard-error band');
xlabel('Draws');
ylabel('Interference (%)');
ylim([0 8]);
grid on;
