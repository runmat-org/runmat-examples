% A 12-cell module on its cold plate, drawn to scale and colored by each cell's
% temperature after three back-to-back EPA US06 cycles (the model in module-temperature.m).
d = readmatrix('cycles/us06.txt', 'NumHeaderLines', 2);
v = repmat(d(:, 2) * 0.44704, 3, 1);  n = numel(v);
P = 1800*vertcat(diff(v), 0).*v + 1800*9.81*0.009*v + 0.31*1.2*v.^3 + 400;
I = P / 350 / 3;
cells = 12;  R = 0.0021;  Cth = 900;  hc = 0.8;  hn = 1.0;
Tc = 25 + 0.4*(0:cells - 1)';  T = 25*ones(cells, 1);  mid = (2:cells - 1)';
for k = 1:n
    lap = vertcat(T(2) - T(1), T(mid + 1) - 2*T(mid) + T(mid - 1), T(cells - 1) - T(cells));
    T = T + (I(k)^2*R - hc*(T - Tc) + hn*lap) / Cth;
end
fprintf('cells run from %.1f C at the coolant inlet to %.1f C at the outlet end\n', T(1), T(end));
fprintf('spread across the module %.1f K\n', max(T) - min(T));

% Prismatic cells 27 x 148 x 98 mm with 3 mm gaps, on a 10 mm aluminum plate (mm).
w = 27;  gap = 3;  depth = 148;  h = 98;
cmap = parula(64);  lo = min(T);  hi = max(T);
faces = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
box = @(x0, y0, z0, dx, dy, dz) [x0 y0 z0; x0+dx y0 z0; x0+dx y0+dy z0; x0 y0+dy z0;
                                  x0 y0 z0+dz; x0+dx y0 z0+dz; x0+dx y0+dy z0+dz; x0 y0+dy z0+dz];
hold on;
for c = 1:cells
    shade = cmap(1 + round(63*(T(c) - lo)/(hi - lo)), :);
    patch('Vertices', box((c-1)*(w + gap), 0, 10, w, depth, h), 'Faces', faces, 'FaceColor', shade, 'EdgeColor', [0.2 0.22 0.26]);
end
L = cells*(w + gap) - gap;
grey = [0.7 0.73 0.78];
patch('Vertices', box(-10, -10, 0, L + 20, depth + 20, 10), 'Faces', faces, 'FaceColor', grey, 'EdgeColor', grey);
hold off;
axis equal;
title('Cell temperatures after US06');
xlabel('Along the plate (mm)');
ylabel('y (mm)');
zlabel('z (mm)');
