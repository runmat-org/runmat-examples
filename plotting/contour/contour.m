[X, Y] = meshgrid(linspace(-3, 3, 120), linspace(-3, 3, 120));
Z = 2*exp(-((X-1).^2 + Y.^2)) + 1.5*exp(-((X+1.5).^2 + (Y-1).^2)) - exp(-(X.^2 + (Y+1.5).^2));

contour(X, Y, Z, 20);
colormap('turbo');
colorbar;
title('Thermal Field - Level Sets');
xlabel('x (m)');
ylabel('y (m)');
axis equal;
