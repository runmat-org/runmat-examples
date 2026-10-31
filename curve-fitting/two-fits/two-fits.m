% The same 25 noisy samples fitted two ways: a degree-6 polynomial and the exponential model
rng(4);
x = linspace(0, 4, 25)';
y = 2.5*exp(-1.3*x) + 0.5 + 0.05*randn(size(x));

[p6, ~, mu] = polyfit(x, y, 6);
model = @(p, x) p(1)*exp(-p(2)*x) + p(3);
opts = optimoptions('lsqcurvefit', 'Display', 'off');
pe = lsqcurvefit(model, [1 1 0], x, y, [0 0 -Inf], [], opts);

xx = linspace(0, 5, 300)';
plot(x, y, 'o', 'MarkerSize', 6);
hold on;
plot(xx, polyval(p6, xx, [], mu), 'LineWidth', 2);
plot(xx, model(pe, xx), 'LineWidth', 2);
hold off;
xline(4, ':');
ylim([0 3.5]);
legend('data', 'degree-6 polynomial', 'exponential model');
text(4.05, 0.2, 'last sample');
title('Two fits to the same data, past the last sample');
xlabel('x');
ylabel('y');
grid on;
