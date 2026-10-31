% Projectile with quadratic drag; range found by interpolating the ground crossing
g = 9.81;  k = 0.005;                        % gravity, drag per unit mass (1/m)
v0 = 40;  angle = 45*pi/180;
f = @(t, s) [s(3); s(4); -k*sqrt(s(3)^2 + s(4)^2)*s(3); -g - k*sqrt(s(3)^2 + s(4)^2)*s(4)];

[t, s] = ode45(f, 0:0.01:10, [0; 0; v0*cos(angle); v0*sin(angle)]);

i = find(s(:, 2) < 0, 1);
range = interp1(s([i i-1], 2), s([i i-1], 1), 0);   % heights in increasing order
flight = interp1(s([i i-1], 2), t([i i-1]), 0);
fprintf('Range with drag: %.1f m (no drag: %.1f m)\n', range, v0^2*sin(2*angle)/g);
fprintf('Flight time: %.2f s\n', flight);

plot([s(1:i-1, 1); range], [s(1:i-1, 2); 0]);
title('Projectile with drag');
xlabel('Distance (m)');
ylabel('Height (m)');
grid on;
