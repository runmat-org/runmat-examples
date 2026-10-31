rng(5);
residuals = 0.8*randn(200, 1) + 0.15*randn(200, 1).^3;

qqplot(residuals);
title('Fit Residuals Against a Normal Distribution');
xlabel('Standard normal quantiles');
ylabel('Residual quantiles');
grid on;
