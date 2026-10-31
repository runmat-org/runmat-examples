[X, Y] = meshgrid(linspace(-3, 3, 60), linspace(-3, 3, 60));
Z = X.^2 - Y.^2;

mesh(X, Y, Z);
colormap('jet');
colorbar;
title('Hyperbolic Paraboloid');
xlabel('x');
ylabel('y');
zlabel('z = x^2 - y^2');
view(40, 30);
