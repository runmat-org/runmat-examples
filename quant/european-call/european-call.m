% A European call priced by Monte Carlo and checked against Black-Scholes.
% With four million paths the estimate should sit within a few standard
% errors of the closed form.
rng(42);
S0 = 100;  K = 105;  r = 0.03;  sigma = 0.2;  T = 1;
n = 4e6;
Z = randn(n, 1);
ST = S0 * exp((r - 0.5*sigma^2)*T + sigma*sqrt(T)*Z);
payoff = exp(-r*T) * max(ST - K, 0);
price = mean(payoff);
se = std(payoff) / sqrt(n);
bs = blsprice(S0, K, r, T, sigma);
gap = abs(price - bs) / se;
fprintf('Monte Carlo %.4f, standard error %.4f\n', price, se);
fprintf('Black-Scholes %.4f, %.1f standard errors away\n', bs, gap);

% How the estimate settles as paths are added.
counts = round(logspace(3, log10(n), 40));
est = zeros(1, 40);  band = zeros(1, 40);
for k = 1:40
    p = payoff(1:counts(k));
    est(k) = mean(p);
    band(k) = 2 * std(p) / sqrt(counts(k));
end
semilogx(counts, est, counts, est + band, counts, est - band);
yline(bs);
legend('Estimate', '+2 standard errors', '-2 standard errors', 'Black-Scholes');
title('European call by Monte Carlo');
xlabel('Paths');
ylabel('Price');
