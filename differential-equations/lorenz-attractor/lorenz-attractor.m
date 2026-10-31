% Lorenz system with the classic parameters: a chaotic trajectory in three dimensions
sigma = 10;  rho = 28;  b = 8/3;
f = @(t, u) [sigma*(u(2) - u(1)); u(1)*(rho - u(3)) - u(2); u(1)*u(2) - b*u(3)];

[t, u] = ode45(f, 0:0.005:40, [1; 1; 1]);    % report the solution every 5 ms

plot3(u(:, 1), u(:, 2), u(:, 3), 'LineWidth', 1);
title('Lorenz attractor');
xlabel('x');
ylabel('y');
zlabel('z');
grid on;
view(35, 20);
