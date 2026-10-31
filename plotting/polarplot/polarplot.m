theta = linspace(0, 2*pi, 500);
primary = abs(cos(theta)).^3 + 0.12;
secondary = 0.55*abs(sin(2*theta)).^2 + 0.08;

polarplot(theta, primary, 'b-');
hold on;
polarplot(theta, secondary, 'r--', 'LineWidth', 2);
hold off;
title('Two Radiation Patterns');
legend('Primary', 'Secondary');
