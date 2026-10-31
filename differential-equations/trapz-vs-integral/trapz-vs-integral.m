% Area under exp(-x^2) on [0, 2]: adaptive quadrature against the trapezoid rule
f = @(x) exp(-x.^2);
exact = sqrt(pi)/2 * erf(2);

q = integral(f, 0, 2);
x = 0:0.02:2;
area = trapz(x, f(x));

fprintf('integral: error %.1e\n', abs(q - exact));
fprintf('trapz, %d points: error %.1e\n', numel(x), abs(area - exact));

plot(x, f(x));
hold on;
plot(x, cumtrapz(x, f(x)));
legend('exp(-x^2)', 'cumulative area');
title('Area under a curve');
xlabel('x');
ylabel('Value');
