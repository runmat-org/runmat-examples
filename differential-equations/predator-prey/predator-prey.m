% Lotka-Volterra: prey x, predators y
alpha = 1.1;  beta = 0.4;
delta = 0.1;  gamma = 0.4;
f = @(t, s) [alpha*s(1) - beta*s(1)*s(2); delta*s(1)*s(2) - gamma*s(2)];

opts = struct('RelTol', 1e-8, 'AbsTol', 1e-10);
[t, s] = ode45(f, [0 60], [10; 5], opts);

fprintf('ode45: %d steps at RelTol 1e-8\n', numel(t) - 1);
fprintf('Prey %.2f to %.2f, predators %.2f to %.2f\n', min(s(:, 1)), max(s(:, 1)), min(s(:, 2)), max(s(:, 2)));

subplot(1, 2, 1);
plot(t, s(:, 1));
hold on;
plot(t, s(:, 2));
legend('prey', 'predators');
title('Time history');
xlabel('Time');
ylabel('Population');

subplot(1, 2, 2);
plot(s(:, 1), s(:, 2));
title('Phase portrait');
xlabel('Prey');
ylabel('Predators');
grid on;
