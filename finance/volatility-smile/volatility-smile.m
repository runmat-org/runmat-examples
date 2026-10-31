% Recover implied volatility from option prices across strikes
S0 = 100;  r = 0.02;  T = 0.5;
K = (70:5:130)';
m = (K - S0) / S0;
trueVol = 0.22 + 0.25*m.^2 - 0.08*m;
price = blsprice(S0, K, r, T, trueVol);

iv = blsimpv(S0, K, r, T, price);

plot(K, 100*iv, 'o-');
title('Volatility smile');
xlabel('Strike');
ylabel('Implied volatility (%)');

fprintf('At the money: %.1f%%, 30%% out of the money: %.1f%%\n', 100*iv(K == 100), 100*iv(K == 130));
fprintf('Largest error in the recovered volatility: %.1e\n', max(abs(iv - trueVol)));
