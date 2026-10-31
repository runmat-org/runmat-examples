% Monte Carlo tolerance stack-up: the estimate of the interference probability against the
% number of draws, inside a two-standard-error band that narrows as 1/sqrt(n)
rng(1);
N = 1e6;
shaft = 25.000 + 0.010*randn(N, 1);        % mm
bore = 25.030 + 0.012*randn(N, 1);         % mm
growth = 0.002 + 0.0006*randn(N, 1);       % thermal growth of the shaft, mm
clearance = bore - shaft - growth;

p = mean(clearance < 0);
n = (1:N)';
running = cumsum(clearance < 0) ./ n;
k = unique(round(logspace(2, 6, 200)))';
band = 2*sqrt(p*(1 - p) ./ k);

semilogx(k, 100*running(k), 'LineWidth', 2);
hold on;
semilogx(k, 100*(p + band), '--', 'LineWidth', 1.2);
semilogx(k, 100*(p - band), '--', 'LineWidth', 1.2);
hold off;
legend('running estimate', 'estimate + 2 SE', 'estimate - 2 SE');
title(sprintf('Interference probability: %.2f%% after a million draws', 100*p));
xlabel('Draws');
ylabel('Interference (%)');
ylim([0 8]);
grid on;
