% Temperature of an avionics board through a three-hour flight. The board and
% its case are two thermal masses; the electrical load rises in flight while
% the cooling air gets thinner and colder with altitude.
Cb = 900;  Cc = 4000;  R = 0.4;                         % J/K, J/K, K/W
P  = @(t) 30 + 25 * (t > 600 & t < 9000);               % W
G  = @(t) (3.0 - 1.0 * min(t / 1800, 1)) .* (t < 9600) + 3.0 * (t >= 9600);   % W/K
Ta = @(t) (45 - 20 * min(t / 1800, 1)) .* (t < 9600) + 45 * (t >= 9600);      % deg C

f = @(t, T) [(P(t) - (T(1) - T(2)) / R) / Cb; ...
             ((T(1) - T(2)) / R - G(t) * (T(2) - Ta(t))) / Cc];
[t, T] = ode45(f, [0 3 * 3600], [45; 45]);

[peak, i] = max(T(:, 1));
fig = figure;
plot(t / 60, T(:, 1), 'LineWidth', 2, 'Color', [0.94 0.45 0.20]); hold on;
plot(t / 60, T(:, 2), 'LineWidth', 1.8, 'Color', [0.31 0.55 1.00]);
plot([0 180], [85 85], 'LineWidth', 1.4, 'Color', [0.55 0.58 0.65]);
legend('Board', 'Case', 'Board limit');
title('Avionics temperature through a flight');
xlabel('Time (min)'); ylabel('Temperature (deg C)');
xlim([0 180]); ylim([20 100]); grid on;
fprintf('peak board temperature %.1f C at %.0f min\n', peak, t(i) / 60);
fprintf('margin to the 85 C limit %.1f C\n', 85 - peak);
