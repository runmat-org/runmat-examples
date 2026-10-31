% Price a European call by simulation and check it against Black-Scholes
rng(42);
S0 = 100;  K = 105;  r = 0.03;  sigma = 0.2;  T = 1;
N = 1e6;

Z = randn(N, 1);
ST = S0 * exp((r - 0.5*sigma^2)*T + sigma*sqrt(T)*Z);
payoff = exp(-r*T) * max(ST - K, 0);

running = cumsum(payoff) ./ (1:N)';
call = blsprice(S0, K, r, T, sigma);
se = std(payoff) / sqrt(N);

idx = round(logspace(2, 6, 200));
band = 2 * std(payoff) ./ sqrt(idx);
semilogx(idx, running(idx));
hold on;
semilogx(idx, call + band, ':');
semilogx(idx, call - band, ':');
yline(call, '--');
title('Monte Carlo estimate against Black-Scholes');
xlabel('Paths');
ylabel('Call price');

fprintf('Monte Carlo: %.3f (standard error %.3f)\n', running(end), se);
fprintf('Black-Scholes: %.3f\n', call);
