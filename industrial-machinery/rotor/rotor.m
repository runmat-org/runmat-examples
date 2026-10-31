% A stepped steel shaft on two bearings 1.2 m apart, carrying a 25 kg and a 40 kg
% disc, drawn to scale and colored by its first bending mode from a beam model.
% Deflection exaggerated.
E = 210e9;  rho = 7850;  L = 1.2;  ne = 48;  le = L/ne;
xm = ((1:ne)' - 0.5) * le;
dia = 0.05 + 0.02*(xm > 0.3 & xm < 0.9);
A = pi*dia.^2/4;  I = pi*dia.^4/64;
K = zeros(2*ne + 2);  M = zeros(2*ne + 2);
for e = 1:ne
    c = E*I(e)/le^3;  m = rho*A(e)*le/420;
    ke = c * [12 6*le -12 6*le; 6*le 4*le^2 -6*le 2*le^2; -12 -6*le 12 -6*le; 6*le 2*le^2 -6*le 4*le^2];
    me = m * [156 22*le 54 -13*le; 22*le 4*le^2 13*le -3*le^2; 54 13*le 156 -22*le; -13*le -3*le^2 -22*le 4*le^2];
    q = (2*e - 1:2*e + 2)';
    K(q, q) = K(q, q) + ke;  M(q, q) = M(q, q) + me;
end
discs = [0.4 25 0.147; 0.8 40 0.183];           % position (m), mass (kg), radius (m)
for j = 1:2
    r = 2*(round(discs(j, 1)/le) + 1) - 1;
    M(r, r) = M(r, r) + discs(j, 2);
end
free = setdiff((1:2*ne + 2)', [1; 2*ne + 1]);
[Phi, Lam] = eig(K(free, free), M(free, free));
[w2, first] = min(diag(Lam));
u = zeros(2*ne + 2, 1);  u(free) = Phi(:, first);
u = u((1:2:2*ne + 1)');  u = u / norm(u, Inf);
crit = sqrt(w2) * 60 / (2*pi);
fprintf('first critical speed %.0f rpm\n', crit);
fprintf('%.0f%% above a 1,800 rpm running speed\n', 100*(crit/1800 - 1));

% Shaft, one band per element; discs as short drums; bearings in grey.
amp = 0.06;  x = (0:ne)' * le;  cmap = parula(64);  theta = linspace(0, 2*pi, 25);
hold on;
for e = 1:ne
    r = dia(e)/2;
    ring1 = horzcat(x(e)*ones(25, 1), r*cos(theta)', amp*u(e) + r*sin(theta)');
    ring2 = horzcat(x(e+1)*ones(25, 1), r*cos(theta)', amp*u(e+1) + r*sin(theta)');
    tf = horzcat((1:24)', (2:25)', (27:50)', (26:49)');
    shade = cmap(1 + round(63*abs(u(e) + u(e+1))/2), :);
    patch('Vertices', vertcat(ring1, ring2), 'Faces', tf, 'FaceColor', shade, 'EdgeColor', shade);
end
for j = 1:2
    node = round(discs(j, 1)/le) + 1;  R = discs(j, 3);  z0 = amp*u(node);
    a = discs(j, 1) - 0.025;  b = discs(j, 1) + 0.025;
    face1 = horzcat(a*ones(25, 1), R*cos(theta)', z0 + R*sin(theta)');
    face2 = horzcat(b*ones(25, 1), R*cos(theta)', z0 + R*sin(theta)');
    side = horzcat((1:24)', (2:25)', (27:50)', (26:49)');
    shade = cmap(1 + round(63*abs(u(node))), :);
    patch('Vertices', vertcat(face1, face2), 'Faces', side, 'FaceColor', shade, 'EdgeColor', shade);
    patch('Vertices', face1, 'Faces', 1:24, 'FaceColor', shade, 'EdgeColor', shade);
    patch('Vertices', face2, 'Faces', 1:24, 'FaceColor', shade, 'EdgeColor', shade);
end
grey = [0.62 0.66 0.72];
box = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
for xb = [0 L]
    bv = [xb-0.03 -0.07 -0.12; xb+0.03 -0.07 -0.12; xb+0.03 0.07 -0.12; xb-0.03 0.07 -0.12;
          xb-0.03 -0.07 0.04; xb+0.03 -0.07 0.04; xb+0.03 0.07 0.04; xb-0.03 0.07 0.04];
    patch('Vertices', bv, 'Faces', box, 'FaceColor', grey, 'EdgeColor', grey);
end
hold off;
axis equal;
title('Rotor, first bending mode');
xlabel('Along the shaft (m)');
ylabel('y (m)');
zlabel('z (m)');
