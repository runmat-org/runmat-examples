% The can that holds one liter with the least metal: a one-variable minimum with fminbnd
V = 1000;                                 % cm^3
area = @(r) 2*pi*r.^2 + 2*V./r;           % top, bottom and side, cm^2
[r, a, flag, out] = fminbnd(area, 1, 20);
h = V/(pi*r^2);
fprintf('Radius %.2f cm, height %.2f cm, area %.1f cm^2 (%d evaluations)\n', r, h, a, out.funcCount);
fprintf('Height over diameter: %.3f\n', h/(2*r));

rr = linspace(2, 15, 300);
plot(rr, area(rr), 'LineWidth', 1.5);
hold on;
plot(r, a, 'ro', 'MarkerSize', 9, 'MarkerFaceColor', 'r');
hold off;
xlabel('Radius (cm)');
ylabel('Surface area (cm^2)');
title(sprintf('Least area at r = %.2f cm, where the height equals the diameter', r));
grid on;
