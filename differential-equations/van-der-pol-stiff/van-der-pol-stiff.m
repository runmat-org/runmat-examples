% Van der Pol at mu = 1000: a stiff problem, solved with ode45 and with ode15s
mu = 1000;
f = @(t, y) [y(2); mu*(1 - y(1)^2)*y(2) - y(1)];

[t1, y1] = ode45(f, [0 5], [2; 0]);
[t2, y2] = ode15s(f, [0 5], [2; 0]);

fprintf('ode45 (explicit): %d steps\n', numel(t1) - 1);
fprintf('ode15s (stiff): %d steps\n', numel(t2) - 1);

semilogy(t1(2:end), diff(t1));
hold on;
semilogy(t2(2:end), diff(t2), 'o-');
legend('ode45', 'ode15s');
title('Step size on a stiff problem');
xlabel('Time');
ylabel('Step size');
