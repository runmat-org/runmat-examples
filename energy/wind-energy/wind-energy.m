% A year of hourly wind speeds at hub height: a Weibull fit by maximum likelihood,
% then the energy a 5 MW turbine yields (cut-in 3 m/s, rated 11.4, cut-out 25).
rng(7);
u = 8.5 * (-log(rand(8760, 1))).^(1/2.1);
g = @(k) 1/k + mean(log(u)) - sum(u.^k .* log(u)) / sum(u.^k);
k = fzero(g, 2);
c = mean(u.^k)^(1/k);
fprintf('Weibull shape %.2f, scale %.2f m/s, mean speed %.2f m/s\n', k, c, mean(u));
v = (0:0.25:30)';
P = 5 * min(1, max(0, (v.^3 - 27) / (11.4^3 - 27))) .* (v <= 25);
pdf = (k/c) * (v/c).^(k - 1) .* exp(-(v/c).^k);
aep = 8760 * trapz(v, P .* pdf);
fprintf('%.1f GWh a year, a capacity factor of %.0f%%\n', aep/1000, 100*aep/(5*8760));

edges = 0:1:26;
counts = histcounts(u, edges);
bar(edges(1:end-1) + 0.5, counts / numel(u));
hold on;
plot(v, pdf, 'LineWidth', 2);
xlim([0 26]);
xticks(0:5:25);
title('Hourly wind speed and the fitted Weibull density');
xlabel('Wind speed (m/s)');
ylabel('Probability density');
