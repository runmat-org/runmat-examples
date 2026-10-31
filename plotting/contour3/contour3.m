[X, Y] = meshgrid(linspace(-3, 3, 100), linspace(-3, 3, 100));
Z = sin(X).*cos(Y) + 0.25*cos(2*X + Y);
levels = [-0.9 -0.6 -0.3 0 0.3 0.6 0.9];

contour3(X, Y, Z, levels, 'LineWidth', 2);
title('Potential Field Levels');
xlabel('x');
ylabel('y');
zlabel('Potential');
view(42, 28);
grid on;
