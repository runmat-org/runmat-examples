% A finned aluminum heat sink, 125 x 35 x 35 mm, the size of the KiCad model in
% heatsink-steady.fea, sized by hand: fin efficiency, thermal resistance to air and
% the temperature rise for 10 W. The solved study will be checked against this.
L = 0.125;  W = 0.035;  H = 0.035;          % length, width, height (m)
nfin = 7;  t = 0.002;  base = 0.004;          % fins, fin thickness, base thickness (m)
k = 160;  h = 35;  Q = 10;                    % W/m/K, W/m^2/K, W
Lf = H - base;                                % fin height
m = sqrt(2*h / (k*t));
eta = tanh(m*Lf) / (m*Lf);                    % fin efficiency
Afin = nfin * (2*Lf*L + t*L);
Abase = W*L - nfin*t*L + 2*base*L + 2*base*W;
R = 1 / (h*(Abase + eta*Afin));
fprintf('fin efficiency %.0f%%, thermal resistance %.2f K/W to air\n', 100*eta, R);
fprintf('%d W raises the base %.1f K above ambient\n', Q, Q*R);

% The geometry, as boxes: the base plate and the fins.
pitch = (W - t) / (nfin - 1);
boxes = zeros(nfin + 1, 6);
boxes(1, :) = [0 0 0 W L base];
for f = 1:nfin
    boxes(f + 1, :) = [(f-1)*pitch, 0, base, t, L, Lf];
end
faces = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
hold on;
for b = 1:size(boxes, 1)
    x0 = 1000*boxes(b, 1);  y0 = 1000*boxes(b, 2);  z0 = 1000*boxes(b, 3);
    dx = 1000*boxes(b, 4);  dy = 1000*boxes(b, 5);  dz = 1000*boxes(b, 6);
    V = [x0 y0 z0; x0+dx y0 z0; x0+dx y0+dy z0; x0 y0+dy z0;
         x0 y0 z0+dz; x0+dx y0 z0+dz; x0+dx y0+dy z0+dz; x0 y0+dy z0+dz];
    patch('Vertices', V, 'Faces', faces, 'FaceColor', [0.62 0.66 0.72], 'EdgeColor', [0.3 0.33 0.38]);
end
hold off;
view(-35, 25);
axis equal;
title('Finned heat sink, 125 x 35 x 35 mm');
xlabel('Width (mm)');
ylabel('Length (mm)');
zlabel('Height (mm)');
