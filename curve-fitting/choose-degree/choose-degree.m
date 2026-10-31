% One data set, polynomial degrees 1 to 6: R-squared keeps rising while the fit gets worse
rng(4);
x = linspace(0, 4, 25)';
y = 2.5*exp(-1.3*x) + 0.5 + 0.05*randn(size(x));
n = numel(x);

fprintf('degree   R^2       adjusted R^2   residual norm\n');
for d = 1:6
    [p, ~, mu] = polyfit(x, y, d);
    r = y - polyval(p, x, [], mu);
    R2 = 1 - sum(r.^2)/sum((y - mean(y)).^2);
    adj = 1 - (1 - R2)*(n - 1)/(n - d - 1);
    fprintf('%4d     %.5f   %.5f        %.4f\n', d, R2, adj, norm(r));
end

% Past the last sample the two fits part company
xx = linspace(0, 5, 300)';
[p2, ~, mu2] = polyfit(x, y, 2);
[p6, ~, mu6] = polyfit(x, y, 6);
plot(x, y, 'o', 'MarkerSize', 6);
hold on;
plot(xx, polyval(p2, xx, [], mu2), 'LineWidth', 1.8);
plot(xx, polyval(p6, xx, [], mu6), 'LineWidth', 1.8);
plot(xx, 2.5*exp(-1.3*xx) + 0.5, '--', 'LineWidth', 1.2);
hold off;
xline(4, ':');
ylim([0 3.5]);
legend('data', 'degree 2', 'degree 6', 'true curve');
text(4.05, 0.2, 'last sample');
title('Degree 2 against degree 6, extrapolated');
xlabel('x');
ylabel('y');
grid on;
