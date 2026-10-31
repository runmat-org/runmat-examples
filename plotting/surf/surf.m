[X, Y] = meshgrid(linspace(-4, 4, 200), linspace(-4, 4, 200));
R = sqrt(X.^2 + Y.^2) + 0.01;
Z = sin(3*R) ./ R;

surf(X, Y, Z);
shading interp;
colormap('turbo');
colorbar;
title('Damped Radial Wavefield');
xlabel('x');
ylabel('y');
zlabel('Amplitude');
view(35, 25);
