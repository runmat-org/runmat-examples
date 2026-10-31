rng(11);
n = 2000;
theta = 4*pi*rand(1, n);
r = sqrt(rand(1, n));
x = r .* cos(theta);
y = r .* sin(theta);
z = sin(3*r) ./ (1 + r);

scatter3(x, y, z, 12, z, 'filled');
colormap('turbo');
colorbar;
title('3-D Point Cloud - Altitude Encoded');
xlabel('x');
ylabel('y');
zlabel('z');
view(35, 25);
grid on;
