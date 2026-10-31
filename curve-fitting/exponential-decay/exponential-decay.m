% Fit y = A*exp(-k*t) + c with bounds, then read the parameters and the residuals
rng(3);
t = linspace(0, 10, 60)';
truth = [4.0 0.6 1.2];
y = truth(1)*exp(-truth(2)*t) + truth(3) + 0.12*randn(size(t));

model = @(p, t) p(1)*exp(-p(2)*t) + p(3);
lb = [0 0 -Inf];
ub = [Inf 5 Inf];
opts = optimoptions('lsqcurvefit', 'Display', 'off');
[p, resnorm, res, ~, ~, ~, J] = lsqcurvefit(model, [1 0.1 0], t, y, lb, ub, opts);

% 95% intervals from the Jacobian at the solution
dof = numel(t) - numel(p);
covP = inv(J'*J) * resnorm/dof;
half = tinv(0.975, dof) * sqrt(diag(covP))';
names = ["A" "k" "c"];
for i = 1:3
    fprintf('%s = %.3f +/- %.3f   (true %.1f)\n', names(i), p(i), half(i), truth(i));
end
fprintf('RMS residual %.4f\n', sqrt(resnorm/numel(t)));

subplot(2, 1, 1);
plot(t, y, 'o', 'MarkerSize', 5);
hold on;
plot(t, model(p, t), 'LineWidth', 2);
hold off;
legend('data', 'fit');
title('Exponential decay fitted with lsqcurvefit');
xlabel('t');
ylabel('y');
grid on;

subplot(2, 1, 2);
stem(t, res, 'filled');
yline(0);
title('Residuals: no pattern left');
xlabel('t');
ylabel('y - fit');
grid on;
