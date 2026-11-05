% The smallest Monte Carlo: points in a unit square, the fraction inside the quarter circle
rng(2);
N = 1e6;
xy = rand(N, 2);
inside = sum(xy.^2, 2) <= 1;
estimate = 4*cumsum(inside) ./ (1:N)';

k = unique(round(logspace(1, 6, 300)))';
err = abs(estimate(k) - pi);
spread = 4*sqrt((pi/4)*(1 - pi/4) ./ k);    % one standard error
fprintf('pi is about %.5f after %d points (error %.5f, standard error %.5f)\n', ...
    estimate(end), N, abs(estimate(end) - pi), spread(end));
fprintf('Ten times the points buys about %.2f times the accuracy\n', sqrt(10));

loglog(k, err, 'LineWidth', 1);
hold on;
loglog(k, spread, '--', 'LineWidth', 2);
hold off;
legend('actual error', 'one standard error');
title('Estimating pi: error against the number of points');
xlabel('Points');
ylabel('|estimate - pi|');
grid on;

% Keep the plotted curves in the workspace and let the million samples go
clear xy inside estimate
