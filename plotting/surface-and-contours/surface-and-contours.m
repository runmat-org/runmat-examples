[X, Y] = meshgrid(linspace(-3, 3, 80));
Z = 3*(1 - X).^2 .* exp(-X.^2 - (Y + 1).^2) - 10*(X/5 - X.^3 - Y.^5) .* exp(-X.^2 - Y.^2) ...
    - exp(-(X + 1).^2 - Y.^2)/3;

subplot(1, 2, 1);
surf(X, Y, Z);
shading interp;
title('Surface');
xlabel('x');
ylabel('y');
zlabel('z');
view(-35, 30);

subplot(1, 2, 2);
contourf(X, Y, Z, 16);
title('Filled contours');
xlabel('x');
ylabel('y');
colorbar;
