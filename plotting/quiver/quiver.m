[X, Y] = meshgrid(linspace(-2, 2, 25), linspace(-2, 2, 25));
Z = X .* exp(-X.^2 - Y.^2);
[DX, DY] = gradient(Z, X(1,2)-X(1,1), Y(2,1)-Y(1,1));

contourf(X, Y, Z, 15);
hold on;
quiver(X, Y, DX, DY, 'k', 'LineWidth', 1);
hold off;

colormap('turbo');
colorbar;
title('Gradient Field over Scalar Potential');
xlabel('x');
ylabel('y');
