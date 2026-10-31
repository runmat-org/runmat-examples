% Rosenbrock's function from (-1.2, 1) with three solvers, and the evaluations each needs
f = @(x) 100*(x(2) - x(1)^2)^2 + (1 - x(1))^2;
x0 = [-1.2 1];

[x1, f1, e1, o1] = fminsearch(f, x0);
opts = optimoptions('fminunc', 'Display', 'off');
[x2, f2, e2, o2] = fminunc(f, x0, opts);
opts = optimoptions(opts, 'SpecifyObjectiveGradient', true);
[x3, f3, e3, o3] = fminunc(@rosenbrock, x0, opts);

names = {'fminsearch', 'fminunc, finite differences', 'fminunc, gradient supplied'};
counts = [o1.funcCount o2.funcCount o3.funcCount];
ends = [x1; x2; x3];
for k = 1:3
    fprintf('%-28s x = (%.4f, %.4f), %3d evaluations\n', names{k}, ends(k, :), counts(k));
end

subplot(1, 2, 1);
[X, Y] = meshgrid(-2:0.02:2, -1:0.02:3);
contour(X, Y, 100*(Y - X.^2).^2 + (1 - X).^2, logspace(-1, 3, 18));
hold on;
plot(x0(1), x0(2), 'o', 'Color', [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5]);
plot(1, 1, 'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
hold off;
xlabel('x_1');
ylabel('x_2');
title('Start (gray) and minimum (red)');
subplot(1, 2, 2);
bar(counts);
xticks(1:3);
xticklabels({'fminsearch', 'fminunc', 'fminunc + grad'});
ylabel('Function evaluations');
title('Cost to converge');
grid on;

function [v, g] = rosenbrock(x)
v = 100*(x(2) - x(1)^2)^2 + (1 - x(1))^2;
g = [-400*x(1)*(x(2) - x(1)^2) - 2*(1 - x(1)); 200*(x(2) - x(1)^2)];
end
