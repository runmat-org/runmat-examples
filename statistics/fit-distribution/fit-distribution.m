% Fit a normal distribution to measured diameters, then check the fit two ways
rng(8);
d = 12.70 + 0.025*randn(150, 1);       % mm

pd = fitdist(d, 'Normal');
fprintf('Fitted mean %.4f mm, standard deviation %.4f mm\n', pd.mu, pd.sigma);
[h, p] = kstest((d - pd.mu)/pd.sigma);
fprintf('Kolmogorov-Smirnov p = %.3f (h = %d)\n', p, h);
fprintf('Expected out of 12.70 +/- 0.06 mm: %.3f%%\n', 100*(1 - (cdf(pd, 12.76) - cdf(pd, 12.64))));

subplot(1, 2, 1);
histogram(d, 20, 'Normalization', 'pdf');
hold on;
xs = linspace(min(d), max(d), 200);
plot(xs, pdf(pd, xs), 'LineWidth', 2);
hold off;
title('Histogram and fitted normal');
xlabel('Diameter (mm)');
ylabel('Density');
grid on;

subplot(1, 2, 2);
qqplot(d);
title('Quantiles against a normal');
grid on;
