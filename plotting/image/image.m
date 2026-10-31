[X, Y] = meshgrid(linspace(0, 1, 180), linspace(0, 1, 180));
pattern = 0.5 + 0.5*sin(4*pi*X).*cos(3*pi*Y);
color_index = round(1 + 63*pattern);

image(color_index);
colormap('turbo');
colorbar;
title('Indexed Color Field');
xlabel('Column');
ylabel('Row');
axis equal;
