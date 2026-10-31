% Wafer bow from film stress by Stoney's equation: a tensile film on a 300 mm,
% 775 um silicon wafer, across film thickness.
E = 130e9;  nu = 0.28;  ts = 775e-6;  D = 0.300;   % silicon, thickness, diameter
sigma = 400e6;                                     % film stress (Pa)
tf = linspace(0.1e-6, 2e-6, 60);
kappa = 6 * sigma * tf * (1 - nu) / (E * ts^2);   % curvature (1/m)
bow = kappa * D^2 / 8;                             % sagitta (m)
fprintf('a 1 um film at 400 MPa bows the wafer %.0f um\n', 1e6 * interp1(tf, bow, 1e-6));
fprintf('radius of curvature %.0f m at 1 um\n', 1 / interp1(tf, kappa, 1e-6));

plot(1e6*tf, 1e6*bow);
title('Wafer bow against film thickness');
xlabel('Film thickness (um)');
ylabel('Bow (um)');
