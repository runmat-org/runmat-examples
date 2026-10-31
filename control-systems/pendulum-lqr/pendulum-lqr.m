% Balance an inverted pendulum on a cart with LQR, then simulate the loop with ode45
M = 0.5; m = 0.2; b = 0.1; I = 0.006; g = 9.81; l = 0.3;   % kg, N/m/s, kg m^2, m/s^2, m
p = I*(M + m) + M*m*l^2;
A = [0, 1, 0, 0;
     0, -(I + m*l^2)*b/p, m^2*g*l^2/p, 0;
     0, 0, 0, 1;
     0, -m*l*b/p, m*g*l*(M + m)/p, 0];
B = [0; (I + m*l^2)/p; 0; m*l/p];
fprintf('Open-loop poles: %s (one unstable)\n', num2str(eig(A).', 4));

K = lqr(A, B, diag([5000 0 100 0]), 1);
fprintf('LQR gain K = [%s]\n', num2str(K, 5));

x0 = [0; 0; 0.2; 0];                                       % 0.2 rad tilt, cart at rest
[t, x] = ode45(@(t, x) (A - B*K)*x, 0:0.01:5, x0);
u = -(K*x.').';
fprintf('Peak force %.1f N, cart travel %.3f m, angle within 1 deg after %.2f s\n', ...
    max(abs(u)), max(abs(x(:, 1))), t(find(abs(x(:, 3)) > pi/180, 1, 'last')));

subplot(2, 1, 1);
plot(t, x(:, 1), t, x(:, 3)*180/pi, 'LineWidth', 1.5);
legend('cart position (m)', 'pendulum angle (deg)');
title('Inverted pendulum under LQR');
grid on;
subplot(2, 1, 2);
plot(t, u, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Force (N)');
grid on;
