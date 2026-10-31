% Natural frequencies of n equal masses joined by equal springs, against the closed form
n = 6;  k = 1000;  m = 2;                        % N/m and kg
K = k * toeplitz([2 -1 zeros(1, n - 2)]);        % fixed at both ends

[V, D] = eig(K / m);
[w2, order] = sort(diag(D));
V = V(:, order);
f = sqrt(w2) / (2*pi);
exact = sqrt(k/m) / pi * sin((1:n)' * pi / (2*(n + 1)));

fprintf('Lowest three modes: %.2f, %.2f, %.2f Hz\n', f(1), f(2), f(3));
fprintf('Largest difference from the closed form: %.1e Hz\n', max(abs(f - exact)));

x = 0:n+1;
plot(x, [0; V(:, 1); 0] / max(abs(V(:, 1))));
hold on;
plot(x, [0; V(:, 2); 0] / max(abs(V(:, 2))));
plot(x, [0; V(:, 3); 0] / max(abs(V(:, 3))));
legend('mode 1', 'mode 2', 'mode 3');
title('Mode shapes of a spring-mass chain');
xlabel('Mass index');
ylabel('Normalized displacement');
grid on;
