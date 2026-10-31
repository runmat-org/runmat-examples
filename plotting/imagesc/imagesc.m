[X, Y] = meshgrid(linspace(-pi, pi, 300), linspace(-pi, pi, 300));
Z = sin(3*X) .* cos(2*Y) + cos(X.*Y);

imagesc(Z);
colormap('turbo');
colorbar;
title('Scalar Field Heatmap');
xlabel('Column');
ylabel('Row');
axis equal;
