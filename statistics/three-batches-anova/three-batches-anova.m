% Three suppliers, one question: does any differ? One-way ANOVA
rng(9);
strength = [410 + 8*randn(30, 1), 414 + 8*randn(30, 1), 419 + 8*randn(30, 1)];

[p, tbl] = anova1(strength, {'Supplier 1', 'Supplier 2', 'Supplier 3'}, 'off');
fprintf('F(%d, %d) = %.2f, p = %.4f\n', tbl{2, 3}, tbl{3, 3}, tbl{2, 5}, p);
fprintf('Group means: %.1f, %.1f, %.1f MPa\n', mean(strength));

boxplot(strength, 'Labels', {'Supplier 1', 'Supplier 2', 'Supplier 3'});
title(sprintf('Strength by supplier, one-way ANOVA p = %.4f', p));
xlabel('Supplier');
ylabel('Strength (MPa)');
grid on;
