[X, Y] = meshgrid(linspace(-3, 3, 80), linspace(-3, 3, 80));
Z = (X.^2 - Y.^2).*exp(-0.18*(X.^2 + Y.^2));

meshc(X, Y, Z);
colormap('turbo');
colorbar;
title('Coupled Response Surface');
xlabel('x');
ylabel('y');
zlabel('Response');
view(40, 28);
