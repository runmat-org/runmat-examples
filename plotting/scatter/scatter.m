reference = 10:10:100;
run_a = [11.8 21.6 31.5 41.9 51.2 61.7 71.5 81.8 91.3 101.0];
run_b = [8.7 18.4 28.8 38.5 48.6 58.9 68.4 78.9 88.7 98.5];

scatter(reference, run_a, 90, [0.15 0.65 1.0], 'filled');
hold on;
scatter(reference, run_b, 90, [1.0 0.45 0.2], 'filled');
plot([10 100], [10 100], '--', 'LineWidth', 1.5);
hold off;
legend('Calibration run A', 'Calibration run B', 'Ideal response');
title('Calibration Repeatability');
xlabel('Reference value');
ylabel('Measured value');
grid on;
