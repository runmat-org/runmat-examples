vertices = [-1 -1 0; 1 -1 0; 1 1 0; -1 1 0; 0 0 1.8];
faces = [1 2 5; 2 3 5; 3 4 5; 4 1 5];

patch('Faces', faces, 'Vertices', vertices, 'FaceColor', [0.25 0.65 0.95], 'EdgeColor', [0.9 0.95 1.0], 'FaceAlpha', 0.72);
title('Triangulated Sensor Housing');
xlabel('x');
ylabel('y');
zlabel('z');
view(38, 24);
axis equal;
grid on;
