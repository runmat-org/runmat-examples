t = linspace(0, 8*pi, 600);
radius = 1 + 0.12*cos(5*t);
x = radius.*cos(t);
y = radius.*sin(t);
z = linspace(0, 6, 600) + 0.12*sin(3*t);

h = plot3(x, y, z);
set(h, 'LineWidth', 2);
title('Helical Sensor Trajectory');
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
view(38, 26);
grid on;
axis equal;
