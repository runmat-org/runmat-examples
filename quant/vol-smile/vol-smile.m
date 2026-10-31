% Implied volatilities from one expiry's option quotes, and a quadratic smile
% fitted through them. Quotes are rounded to the nearest 0.05, as a screen shows.
S0 = 100;  r = 0.02;  T = 0.25;
K = (75:5:125)';
m = log(K / S0);
true_vol = 0.21 - 0.25*m + 0.6*m.^2;
quotes = round(blsprice(S0, K, r, T, true_vol) / 0.05) * 0.05;
iv = blsimpv(S0, K, r, T, quotes);
coef = polyfit(m, iv, 2);
fprintf('at-the-money implied volatility %.1f%%\n', 100*polyval(coef, 0));
fprintf('90 strike %.1f%%, 110 strike %.1f%%: a skew of %.1f points\n', 100*polyval(coef, log(0.9)), 100*polyval(coef, log(1.1)), 100*(polyval(coef, log(0.9)) - polyval(coef, log(1.1))));

mm = linspace(min(m), max(m), 100);
plot(K, 100*iv, 'o', S0*exp(mm), 100*polyval(coef, mm));
xlim([70 130]);
legend('From quotes', 'Fitted smile');
title('Implied volatility smile, 3 months');
xlabel('Strike');
ylabel('Implied volatility (%)');
