% Lightest rectangular aluminum cantilever that carries its tip load: minimize the
% cross-section with fmincon under stress, deflection and depth limits
P = 3000; L = 1.5;                        % tip load (N), length (m)
E = 70e9; sigmaMax = 160e6; deltaMax = 0.006;   % Pa, Pa, m

area = @(v) v(1)*v(2);                    % v = [width b, depth h], m
limits = @(v) beamLimits(v, P, L, E, sigmaMax, deltaMax);
lb = [0.02 0.02]; ub = [0.10 0.25];
opts = optimoptions('fmincon', 'Display', 'off');
[v, A] = fmincon(area, [0.05 0.10], [], [], [], [], lb, ub, limits, opts);
c = limits(v);
fprintf('Width %.1f mm, depth %.1f mm, area %.0f mm^2\n', 1e3*v, 1e6*A);
fprintf('Stress %.0f MPa of %.0f; deflection %.2f mm of %.1f\n', ...
    (c(1) + sigmaMax)/1e6, sigmaMax/1e6, 1e3*(c(2) + deltaMax), 1e3*deltaMax);

[B, H] = meshgrid(linspace(0.02, 0.1, 200), linspace(0.02, 0.25, 200));
contour(1e3*B, 1e3*H, 1e6*B.*H, 12);
hold on;
contour(1e3*B, 1e3*H, 4*P*L^3 ./ (E*B.*H.^3), [deltaMax deltaMax], 'LineColor', [0.5 0.5 0.5], 'LineWidth', 1.5);
plot([20 62.5], [80 250], '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5);
plot(1e3*v(1), 1e3*v(2), 'ro', 'MarkerSize', 9, 'MarkerFaceColor', 'r');
hold off;
xlabel('Width b (mm)');
ylabel('Depth h (mm)');
legend('area', 'deflection = 6 mm', 'h = 4b', 'lightest section');
title('Lightest section sits on the deflection and depth limits');
grid on;

function [c, ceq] = beamLimits(v, P, L, E, sigmaMax, deltaMax)
c = [6*P*L/(v(1)*v(2)^2) - sigmaMax;      % bending stress
     4*P*L^3/(E*v(1)*v(2)^3) - deltaMax;  % tip deflection
     v(2) - 4*v(1)];                      % depth at most 4 widths
ceq = [];
end
