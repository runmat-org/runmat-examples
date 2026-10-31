[X, Y] = meshgrid(linspace(-3, 3, 150), linspace(-3, 3, 150));
Z = sin(X) .* cos(Y) + 0.5*sin(2*X + Y);

contourf(X, Y, Z, 25);
colormap('turbo');
colorbar;
title('Interference Pattern - Filled Contours');
xlabel('x');
ylabel('y');
axis equal;
