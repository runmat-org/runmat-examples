[X, Y] = meshgrid(linspace(-4, 4, 120), linspace(-4, 4, 120));
R = sqrt(X.^2 + Y.^2) + 0.15;
Z = cos(2.5*R).*exp(-0.22*R);

surfc(X, Y, Z);
shading interp;
colormap('turbo');
colorbar;
title('Damped Radial Response');
xlabel('x');
ylabel('y');
zlabel('Amplitude');
view(38, 27);
