% Calibrate a pressure sensor with a straight line and show where a new reading will fall
rng(7);
volts = linspace(0.3, 4.7, 30)';
kPa = 25.4*volts - 3.1 + 1.1*randn(size(volts));

[p, S] = polyfit(volts, kPa, 1);
vq = linspace(0, 5, 200)';
[fitted, delta] = polyval(p, vq, S);
fprintf('kPa = %.2f * V %+.2f\n', p(1), p(2));
fprintf('A reading of 2.5 V means %.1f kPa, within about %.1f kPa\n', polyval(p, 2.5), 2*mean(delta));

subplot(2, 1, 1);
plot(volts, kPa, 'o', 'MarkerSize', 6);
hold on;
plot(vq, fitted, 'LineWidth', 2);
hold off;
legend('calibration points', 'fit', 'Location', 'northwest');
title('Sensor calibration');
xlabel('Output (V)');
ylabel('Pressure (kPa)');
grid on;

subplot(2, 1, 2);
fill([vq; flipud(vq)], [2*delta; flipud(-2*delta)], [0.3 0.6 0.9], 'FaceAlpha', 0.25, 'EdgeColor', 'none');
hold on;
plot(volts, kPa - polyval(p, volts), 'o', 'MarkerSize', 6);
hold off;
legend('95% prediction band', 'calibration points', 'Location', 'northwest');
title('Where the next reading falls, around the fit');
xlabel('Output (V)');
ylabel('kPa minus fit');
grid on;
