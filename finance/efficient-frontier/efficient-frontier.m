% Minimum-variance frontier for four assets from the covariance matrix
mu = [0.06; 0.08; 0.11; 0.14];
vol = [0.10; 0.14; 0.20; 0.28];
C = [1.0 0.3 0.2 0.1; 0.3 1.0 0.4 0.2; 0.2 0.4 1.0 0.5; 0.1 0.2 0.5 1.0];
Sigma = (vol * vol') .* C;

one = ones(4, 1);
a = one' * (Sigma \ one);
b = one' * (Sigma \ mu);
c = mu' * (Sigma \ mu);
d = a*c - b^2;

target = 0.05:0.001:0.16;
sd = sqrt((a*target.^2 - 2*b*target + c) / d);
wmin = (Sigma \ one) / a;

plot(100*sd, 100*target);
hold on;
scatter(100*vol, 100*mu);
title('Minimum-variance frontier');
xlabel('Volatility (%)');
ylabel('Expected return (%)');

fprintf('Minimum-variance portfolio: return %.2f%%, volatility %.2f%%\n', 100*b/a, 100*sqrt(1/a));
fprintf('Its weights: %.3f %.3f %.3f %.3f\n', wmin);
