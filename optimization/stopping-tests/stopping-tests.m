% Why did the solver stop? The same problem at five tolerance settings:
% evaluations spent and distance left to the true minimum at (1, 1)
f = @(x) 100*(x(2) - x(1)^2)^2 + (1 - x(1))^2;
tol = [1e-2 1e-4 1e-6 1e-8 1e-10];
err = zeros(size(tol)); evals = zeros(size(tol));
for k = 1:numel(tol)
    opts = optimoptions('fminunc', 'Display', 'off', 'OptimalityTolerance', tol(k), ...
        'FunctionTolerance', tol(k), 'StepTolerance', tol(k));
    [x, ~, flag, out] = fminunc(f, [-1.2 1], opts);
    err(k) = norm(x - [1 1]);
    evals(k) = out.funcCount;
    fprintf('tolerance %.0e: exitflag %d, %3d evaluations, error %.1e\n', tol(k), flag, evals(k), err(k));
end

subplot(2, 1, 1);
loglog(tol, err, 'o-', 'LineWidth', 1.5);
ylabel('Distance to (1, 1)');
title('Accuracy and cost at five tolerance settings');
grid on;
subplot(2, 1, 2);
semilogx(tol, evals, 's-', 'LineWidth', 1.5);
xlabel('Tolerance');
ylabel('Function evaluations');
grid on;
