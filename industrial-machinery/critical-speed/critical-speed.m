% First critical speed of a stepped steel shaft on two bearings 1.2 m apart, with a
% 25 kg and a 40 kg disc: Dunkerley's lower bound, a beam model, Rayleigh's upper bound.
E = 210e9;  rho = 7850;  L = 1.2;  ne = 48;  le = L/ne;  g = 9.81;
xm = ((1:ne)' - 0.5) * le;
dia = 0.05 + 0.02*(xm > 0.3 & xm < 0.9);
A = pi*dia.^2/4;  I = pi*dia.^4/64;
K = zeros(2*ne + 2);  Ms = zeros(2*ne + 2);
for e = 1:ne
    c = E*I(e)/le^3;  m = rho*A(e)*le/420;
    ke = c * [12 6*le -12 6*le; 6*le 4*le^2 -6*le 2*le^2; -12 -6*le 12 -6*le; 6*le 2*le^2 -6*le 4*le^2];
    me = m * [156 22*le 54 -13*le; 22*le 4*le^2 13*le -3*le^2; 54 13*le 156 -22*le; -13*le -3*le^2 -22*le 4*le^2];
    q = (2*e - 1:2*e + 2)';
    K(q, q) = K(q, q) + ke;  Ms(q, q) = Ms(q, q) + me;
end
discs = [round(0.4/le) + 1, 25; round(0.8/le) + 1, 40];   % node, mass (kg)
free = setdiff((1:2*ne + 2)', [1; 2*ne + 1]);
Kf = K(free, free);  F = inv(Kf);
Md = zeros(size(Ms));                           % the discs' masses, at their nodes
for j = 1:2
    Md(2*discs(j, 1) - 1, 2*discs(j, 1) - 1) = discs(j, 2);
end
M = Ms + Md;
rpm = @(w) w*60/(2*pi);
beam = sqrt(min(eig(Kf, M(free, free))));
shaft = sqrt(min(eig(Kf, Ms(free, free))));
inv2 = 1/(shaft*shaft);
for j = 1:2
    r = find(free == 2*discs(j, 1) - 1);
    inv2 = inv2 + discs(j, 2) * F(r, r);
end
dunkerley = sqrt(1/inv2);
load = zeros(numel(free), 1);
tw = find(mod(free, 2) == 1);
load(tw) = g * diag(M(free(tw), free(tw)));
y = F * load;
rayleigh = sqrt(g * sum(load(tw) .* y(tw)) / sum(load(tw) .* y(tw).^2));
fprintf('first critical speed %.0f rpm by beam model\n', rpm(beam));
fprintf('Dunkerley %.0f rpm below it, Rayleigh %.0f rpm above it\n', rpm(dunkerley), rpm(rayleigh));

bar(1:3, [rpm(dunkerley) rpm(beam) rpm(rayleigh)]);
xticks(1:3);
xticklabels({'Dunkerley', 'Beam model', 'Rayleigh'});
title('First critical speed, three ways');
xlabel(' ');
ylabel('Speed (rpm)');
