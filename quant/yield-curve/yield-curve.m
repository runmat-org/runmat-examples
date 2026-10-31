% A Nelson-Siegel curve fitted to ten par yields: level, slope, curvature and
% a decay time, the form many central banks use to publish curves.
mat = [0.25 0.5 1 2 3 5 7 10 20 30]';
y = [5.30 5.25 5.05 4.70 4.50 4.35 4.35 4.40 4.70 4.65]' / 100;
ns = @(b, t) b(1) + b(2)*(1 - exp(-t/b(4)))./(t/b(4)) + b(3)*((1 - exp(-t/b(4)))./(t/b(4)) - exp(-t/b(4)));
b = lsqnonlin(@(b) ns(b, mat) - y, [0.045 0.01 -0.01 2]);
fit = ns(b, mat);
fprintf('level %.2f%%, slope %.2f%%, curvature %.2f%%, decay %.1f years\n', 100*b(1), 100*b(2), 100*b(3), b(4));
fprintf('largest miss %.1f basis points across %d maturities\n', 1e4*max(abs(fit - y)), numel(mat));

t = linspace(0.1, 30, 200);
plot(mat, 100*y, 'o', t, 100*ns(b, t));
xlim([0 30]); ylim([4 5.5]);
legend('Par yields', 'Nelson-Siegel');
title('Fitted yield curve');
xlabel('Maturity (years)');
ylabel('Yield (%)');
