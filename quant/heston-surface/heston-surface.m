% Heston stochastic volatility by Monte Carlo, priced across strikes and
% maturities and inverted to a Black-Scholes implied volatility surface.
rng(3);
S0 = 100;  r = 0.02;  v0 = 0.04;  kappa = 2;  theta = 0.04;  xi = 0.5;  rho = -0.7;
n = 50000;  dt = 1/120;  steps = 240;            % two years, maturities fall on steps
mats = [0.25 0.5 0.75 1 1.5 2];
K = 70:5:130;
x = log(S0) * ones(n, 1);
v = v0 * ones(n, 1);
surface = zeros(numel(mats), numel(K));
row = 1;
for s = 1:steps
    z1 = randn(n, 1);
    z2 = rho*z1 + sqrt(1 - rho^2)*randn(n, 1);
    vp = max(v, 0);
    x = x + (r - 0.5*vp)*dt + sqrt(vp*dt).*z1;
    v = v + kappa*(theta - vp)*dt + xi*sqrt(vp*dt).*z2;
    if row <= numel(mats) && s == round(mats(row) / dt)
        ST = exp(x);
        for c = 1:numel(K)
            price = exp(-r*mats(row)) * mean(max(ST - K(c), 0));
            surface(row, c) = blsimpv(S0, K(c), r, mats(row), price);
        end
        row = row + 1;
    end
end
fprintf('one-year at-the-money implied volatility %.1f%%\n', 100*surface(4, 7));
fprintf('one-year skew: %.1f%% at the 70 strike, %.1f%% at the 130 strike\n', 100*surface(4, 1), 100*surface(4, 13));

[KK, TT] = meshgrid(K, mats);
surf(KK, TT, 100*surface);
view(-50, 25);
axis tight;
title('Heston implied volatility');
xlabel('Strike');
ylabel('Maturity (years)');
zlabel('Implied volatility (%)');
