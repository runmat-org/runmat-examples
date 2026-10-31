% Two equations, two unknowns: where a circle meets an exponential curve.
% fsolve finds a different solution from each starting point.
F = @(v) [v(1)^2 + v(2)^2 - 4; v(2) - exp(v(1)) + 1];
opts = optimoptions('fsolve', 'Display', 'off');
starts = [1 1; -2 -1];
sol = zeros(2, 2);
for k = 1:2
    [sol(k, :), Fv, flag] = fsolve(F, starts(k, :), opts);
    fprintf('From (%.0f, %.0f): x = %.4f, y = %.4f, residual %.1e, exitflag %d\n', ...
        starts(k, :), sol(k, :), norm(Fv), flag);
end

t = linspace(0, 2*pi, 400);
x = linspace(-2.2, 1.2, 400);
plot(2*cos(t), 2*sin(t), 'LineWidth', 1.5);
hold on;
plot(x, exp(x) - 1, 'LineWidth', 1.5);
plot(starts(:, 1), starts(:, 2), 's', 'Color', [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5]);
plot(sol(:, 1), sol(:, 2), 'ro', 'MarkerSize', 9, 'MarkerFaceColor', 'r');
hold off;
axis equal;
axis([-3 3 -2.5 2.5]);
legend('x^2 + y^2 = 4', 'y = e^x - 1', 'starting points', 'solutions');
title('fsolve from two starting points');
grid on;
