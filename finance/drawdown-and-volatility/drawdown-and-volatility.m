% Drawdown and 21-day rolling volatility of a price series
rng(7);
n = 756;
ret = 0.0008 + 0.011 * randn(n, 1);
ret(400:460) = ret(400:460) - 0.002 + 0.02 * randn(61, 1);
price = 100 * cumprod(1 + ret);

vol21 = movstd(ret, 21) * sqrt(252);
dd = price ./ cummax(price) - 1;

subplot(2, 1, 1);
plot(price);
title('Price');
xlabel('Trading day');
ylabel('Price');
subplot(2, 1, 2);
plot(100 * vol21);
title('21-day volatility, annualized');
xlabel('Trading day');
ylabel('Volatility (%)');

fprintf('Maximum drawdown: %.1f%%\n', -100 * min(dd));
fprintf('Annualized volatility %.1f%%, Sharpe ratio %.2f\n', 100*std(ret)*sqrt(252), mean(ret)/std(ret)*sqrt(252));
