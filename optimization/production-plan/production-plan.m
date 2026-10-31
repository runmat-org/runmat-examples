% A production plan as a linear program: two products, three machine-hour limits
f = -[3 5];                               % profit per unit (negated: linprog minimizes)
A = [1 0; 0 2; 3 2];                      % hours each unit takes on machines 1 to 3
b = [4; 12; 18];                          % hours available per week
[x, fval] = linprog(f, A, b, [], [], [0 0]);
profit = -fval;
fprintf('Make %.0f of product 1 and %.0f of product 2 for a profit of %.0f\n', x, profit);

fill([0 4 4 2 0], [0 0 3 6 6], [0.3 0.55 0.9], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
hold on;
plot([4 4], [0 9], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.2);
plot([0 6], [6 6], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.2, 'HandleVisibility', 'off');
plot([0 6], [9 0], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.2, 'HandleVisibility', 'off');
plot([0 profit/3], [profit/5 0], 'r--', 'LineWidth', 1.5);
plot(x(1), x(2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
hold off;
axis([0 6 0 9]);
xlabel('Product 1 (units per week)');
ylabel('Product 2 (units per week)');
title(sprintf('Best plan: (%.0f, %.0f), profit %.0f', x, profit));
legend('feasible plans', 'machine limits', 'profit line through the optimum', 'optimum');
grid on;
