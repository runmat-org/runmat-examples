% Impact footprint of a ballistic payload released at 25 km: 4,000 runs with
% dispersed mass, drag, release state, air density and crosswind.
N = 4000;  rng(11);
g = 9.81;  dt = 0.1;

m    = 180 * (1 + 0.02 * randn(N, 1));            % kg
CdA  = 0.35 * (1 + 0.05 * randn(N, 1));           % m^2
rhoS = 1 + 0.04 * randn(N, 1);                    % density scale
wind = 8 * randn(N, 1);                           % crosswind, m/s
V0   = 900 * (1 + 0.01 * randn(N, 1));            % m/s
gam  = deg2rad(20 + 0.3 * randn(N, 1));           % flight-path angle

x = zeros(N, 1);  y = zeros(N, 1);  h = 25000 * ones(N, 1);
vx = V0 .* cos(gam);  vy = zeros(N, 1);  vh = V0 .* sin(gam);
flying = true(N, 1);

% Every run advances together, as arrays.
while any(flying)
    rho = 1.225 * rhoS .* exp(-h / 7200);
    ux = vx;  uy = vy - wind;  uh = vh;           % velocity relative to the air
    speed = sqrt(ux.^2 + uy.^2 + uh.^2);
    k = 0.5 * rho .* CdA .* speed ./ m;
    vx = vx - flying .* k .* ux * dt;
    vy = vy - flying .* k .* uy * dt;
    vh = vh - flying .* (k .* uh + g) * dt;
    x = x + flying .* vx * dt;
    y = y + flying .* vy * dt;
    h = h + flying .* vh * dt;
    flying = flying & h > 0;
end

% 3-sigma ellipse from the covariance of the impact points.
xk = x / 1000;  yk = y / 1000;
mu = [mean(xk), mean(yk)];
C = cov([xk(:) yk(:)]);
[V, D] = eig(C);
th = linspace(0, 2*pi, 200);
ell = (V * (3 * sqrt(D)) * [cos(th); sin(th)])' + mu;

fig = figure;
scatter(yk, xk, 6, [0.31 0.55 1.00], 'filled', 'MarkerEdgeColor', [0.31 0.55 1.00]); hold on;
plot(ell(:, 2), ell(:, 1), 'LineWidth', 2, 'Color', [0.94 0.45 0.20]);
plot(mu(2), mu(1), '+', 'MarkerSize', 14, 'LineWidth', 2.5, 'Color', [0.66 0.33 0.97]);
legend(sprintf('%d impact points', N), '3-sigma ellipse', 'Mean impact');
title('Impact footprint, 4,000 runs');
xlabel('Crossrange (km)'); ylabel('Downrange (km)');
axis equal;
grid on;
fprintf('mean impact %.1f km downrange\n', mu(1));
fprintf('3-sigma ellipse %.2f km by %.2f km\n', 3*sqrt(max(diag(D))), 3*sqrt(min(diag(D))));
