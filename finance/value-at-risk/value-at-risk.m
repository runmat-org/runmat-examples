% One-day 99% value at risk for three correlated assets, by simulation
rng(11);
w = [0.5; 0.3; 0.2];
vol = [0.012; 0.020; 0.008];
C = [1.0 0.6 0.2; 0.6 1.0 0.3; 0.2 0.3 1.0];
Sigma = (vol * vol') .* C;

R = chol(Sigma);
pnl = (randn(500000, 3) * R) * w;

var99 = -prctile(pnl, 1);
es99 = -mean(pnl(pnl <= -var99));
sigmaP = sqrt(w' * Sigma * w);

histogram(100 * pnl, 120);
hold on;
xline(-100 * var99, '--');
title('One-day P&L with the 99% VaR');
xlabel('P&L (% of portfolio)');
ylabel('Scenarios');

fprintf('99%% VaR %.2f%%, expected shortfall %.2f%% of portfolio value\n', 100*var99, 100*es99);
fprintf('Normal closed form: VaR %.2f%%, expected shortfall %.2f%%\n', 100*norminv(0.99)*sigmaP, 100*sigmaP*normpdf(norminv(0.99))/0.01);
