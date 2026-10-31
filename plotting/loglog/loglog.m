problem_size = logspace(1, 6, 300);
measured = 0.018*problem_size.^1.42 .* (1 + 0.035*sin(log(problem_size)));
reference = 0.018*problem_size.^1.42;

h1 = loglog(problem_size, measured);
set(h1, 'LineWidth', 2, 'DisplayName', 'Measured');
hold on;
h2 = loglog(problem_size, reference, '--');
set(h2, 'LineWidth', 1.5, 'DisplayName', 'n^{1.42} reference');
hold off;
title('Scaling Law Comparison');
xlabel('Problem size');
ylabel('Work units');
legend();
grid on;
