% The NREL 5-MW reference turbine (Jonkman et al. 2009, NREL/TP-500-38060), drawn to
% scale, with the tower colored by its first fore-aft mode from a beam model built on
% the report's Table 6-1 (rotor and nacelle as 350 t at the top). Deflection exaggerated.
H = 87.6;  top = 110000 + 240000;
frac = (0:0.1:1)';
mden = [5590.87 5232.43 4885.76 4550.87 4227.75 3916.41 3616.83 3329.03 3053.01 2788.75 2536.27]';
EI = 1e9 * [614.34 534.82 463.27 399.13 341.88 291.01 246.03 206.46 171.85 141.78 115.82]';
ne = 30;  L = H / ne;  mid = ((1:ne)' - 0.5) / ne;
m = interp1(frac, mden, mid);  k = interp1(frac, EI, mid);
K = zeros(2*ne + 2);  M = zeros(2*ne + 2);
for e = 1:ne
    ke = k(e)/L^3 * [12 6*L -12 6*L; 6*L 4*L^2 -6*L 2*L^2; -12 -6*L 12 -6*L; 6*L 2*L^2 -6*L 4*L^2];
    me = m(e)*L/420 * [156 22*L 54 -13*L; 22*L 4*L^2 13*L -3*L^2; 54 13*L 156 -22*L; -13*L -3*L^2 -22*L 4*L^2];
    d = (2*e - 1:2*e + 2)';
    K(d, d) = K(d, d) + ke;  M(d, d) = M(d, d) + me;
end
M(end-1, end-1) = M(end-1, end-1) + top;
free = (3:2*ne + 2)';
[Phi, Lam] = eig(K(free, free), M(free, free));
[w2, first] = min(diag(Lam));
u = vertcat(0, Phi((1:2:2*ne)', first));
u = u / u(end);
fprintf('first fore-aft mode %.3f Hz; the tower top moves, the base is fixed\n', sqrt(w2)/(2*pi));
fprintf('half the tip motion is reached at %.0f m of %.1f m\n', interp1(u, (0:ne)'*L, 0.5), H);

% Tower: a tapered tube, 6 m to 3.87 m, one band per beam element, each colored by
% the mode's motion at that element.
amp = 6;                                   % drawn tip deflection (m)
z = (0:ne)' * L;
r = 3 - 1.065*z/H;
x = amp*u;
theta = linspace(0, 2*pi, 33);
cmap = parula(64);
% The whole turbine is turned 45 degrees about its axis so the rotor faces the viewer.
ca = cos(-pi/4);  sa = sin(-pi/4);
turn = @(P) horzcat(ca*P(:, 1) - sa*P(:, 2), sa*P(:, 1) + ca*P(:, 2), P(:, 3));
hold on;
for e = 1:ne
    ring1 = horzcat(x(e) + r(e)*cos(theta)', r(e)*sin(theta)', z(e)*ones(33, 1));
    ring2 = horzcat(x(e+1) + r(e+1)*cos(theta)', r(e+1)*sin(theta)', z(e+1)*ones(33, 1));
    tf = horzcat((1:32)', (2:33)', (35:66)', (34:65)');
    shade = cmap(1 + round(63*(u(e) + u(e+1))/2), :);
    patch('Vertices', turn(vertcat(ring1, ring2)), 'Faces', tf, 'FaceColor', shade, 'EdgeColor', shade);
end

% Nacelle and hub, carried with the tower top.
dx = amp;  zt = H;
nv = [-5 -2 zt; 9 -2 zt; 9 2 zt; -5 2 zt; -5 -2 zt+4; 9 -2 zt+4; 9 2 zt+4; -5 2 zt+4];
nv(:, 1) = nv(:, 1) + dx;
faces = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
grey = [0.78 0.8 0.84];
patch('Vertices', turn(nv), 'Faces', faces, 'FaceColor', grey, 'EdgeColor', grey);
hub = [-6 + dx, 0, zt + 2.4];
hv = vertcat(hub + [-1.5 -1.5 -1.5], hub + [1.5 -1.5 -1.5], hub + [1.5 1.5 -1.5], hub + [-1.5 1.5 -1.5], ...
             hub + [-1.5 -1.5 1.5], hub + [1.5 -1.5 1.5], hub + [1.5 1.5 1.5], hub + [-1.5 1.5 1.5]);
patch('Vertices', turn(hv), 'Faces', faces, 'FaceColor', grey, 'EdgeColor', grey);

% Three blades, 61.5 m, chord 4.6 m tapering to 1 m, in the rotor plane.
s = linspace(1.5, 63, 24)';
chord = interp1([1.5 10 63], [3.5 4.6 1.0], s);
for b = 0:2
    phi = pi/2 + b*2*pi/3;
    er = [0 cos(phi) sin(phi)];
    et = [0 -sin(phi) cos(phi)];
    cd = 0.35*[1 0 0] + 0.94*et;
    lead = repmat(hub, 24, 1) + s*er - 0.3*chord*cd;
    trail = repmat(hub, 24, 1) + s*er + 0.7*chord*cd;
    bv = vertcat(lead, trail);
    bf = horzcat((1:23)', (2:24)', (26:48)', (25:47)');
    patch('Vertices', turn(bv), 'Faces', bf, 'FaceColor', grey, 'EdgeColor', grey);
end
hold off;
axis equal;
view(-60, 12);
title('NREL 5-MW tower, first mode');
xlabel('x (m)');
ylabel('y (m)');
zlabel('Height (m)');
