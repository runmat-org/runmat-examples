% Fit a line, read its prediction interval, and check the residuals that judge it
rng(6);
load_kN = linspace(2, 20, 40)';
deflection = 0.42*load_kN + 0.8 + 0.35*randn(size(load_kN));    % mm

m = fitlm(load_kN, deflection);
b = m.Coefficients.Estimate;
fprintf('deflection = %.3f * load + %.3f mm, R^2 = %.4f\n', b(2), b(1), m.Rsquared.Ordinary);
[yq, yci] = predict(m, 25, 'Prediction', 'observation');
fprintf('At 25 kN: %.2f mm, 95%% prediction interval %.2f to %.2f mm\n', yq, yci(1), yci(2));

xq = linspace(0, 26, 100)';
[yf, band] = predict(m, xq, 'Prediction', 'observation');

subplot(2, 1, 1);
plot(load_kN, deflection, 'o');
hold on;
plot(xq, yf, 'LineWidth', 2);
plot(xq, band(:, 1), '--');
plot(xq, band(:, 2), '--');
hold off;
title('Fit and 95% prediction interval');
xlabel('Load (kN)');
ylabel('Deflection (mm)');
grid on;

subplot(2, 1, 2);
r = m.Residuals.Raw;
plot(m.Fitted, r, 'o');
yline(0);
title('Residuals against fitted values: no pattern');
xlabel('Fitted deflection (mm)');
ylabel('Residual (mm)');
grid on;
