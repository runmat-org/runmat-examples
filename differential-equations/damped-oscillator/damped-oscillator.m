% Damped mass-spring: x'' + 2*zeta*wn*x' + wn^2*x = 0, against the closed form
wn = 2*pi;  zeta = 0.1;
f = @(t, x) [x(2); -2*zeta*wn*x(2) - wn^2*x(1)];

opts = struct('RelTol', 1e-8, 'AbsTol', 1e-10);
[t, x] = ode45(f, [0 5], [1; 0], opts);

wd = wn*sqrt(1 - zeta^2);
exact = exp(-zeta*wn*t) .* (cos(wd*t) + zeta*wn/wd*sin(wd*t));

fprintf('Damping ratio %.2f, damped frequency %.3f Hz\n', zeta, wd/(2*pi));
fprintf('Largest difference from the closed form: %.1e\n', max(abs(x(:, 1) - exact)));

plot(t, x(:, 1));
hold on;
plot(t, exp(-zeta*wn*t), '--');
legend('ode45', 'decay envelope');
title('Damped oscillator');
xlabel('Time (s)');
ylabel('Displacement');
