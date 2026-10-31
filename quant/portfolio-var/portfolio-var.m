% One-day 99% value at risk and expected shortfall of a three-asset book,
% from 500,000 correlated scenarios, checked against the normal closed forms.
rng(11);
w = [0.5; 0.3; 0.2];
vol = [0.012; 0.020; 0.008];
C = [1.0 0.6 0.2; 0.6 1.0 0.3; 0.2 0.3 1.0];
Sigma = (vol * vol') .* C;
returns = randn(500000, 3) * chol(Sigma);
pnl = returns * w;
var99 = -prctile(pnl, 1);
es99 = -mean(pnl(pnl <= -var99));
sp = sqrt(w' * Sigma * w);
fprintf('99%% VaR %.3f%% of the book (normal theory %.3f%%)\n', 100*var99, 100*norminv(0.99)*sp);
fprintf('99%% expected shortfall %.3f%% (normal theory %.3f%%)\n', 100*es99, 100*sp*normpdf(norminv(0.99))/0.01);

histogram(100*pnl, 120);
xline(-100*var99);
title('One-day P&L with the 99% VaR');
xlabel('P&L (% of book)');
ylabel('Scenarios');
