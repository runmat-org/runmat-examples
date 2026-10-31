% Linear, spline and shape-preserving interpolation through the same step
x = 1:10;
y = [0 0 0 0.1 0.9 1 1 1 1 1];
xq = linspace(1, 10, 400);

lin = interp1(x, y, xq, 'linear');
spl = interp1(x, y, xq, 'spline');
shp = interp1(x, y, xq, 'pchip');
fprintf('Spline overshoot: max %.3f, min %.3f\n', max(spl), min(spl));
fprintf('pchip stays in range: max %.3f, min %.3f\n', max(shp), min(shp));

plot(x, y, 'o', 'MarkerSize', 7);
hold on;
plot(xq, lin, 'LineWidth', 1.4);
plot(xq, spl, 'LineWidth', 1.8);
plot(xq, shp, 'LineWidth', 1.8);
hold off;
yline([0 1], ':');
legend('samples', 'linear', 'spline', 'pchip', 'Location', 'southeast');
title('Interpolating across a step');
xlabel('x');
ylabel('y');
grid on;
