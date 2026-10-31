% Do two batches of tensile results differ? Box plots, then Welch's t-test
rng(5);
batchA = 412 + 9*randn(40, 1);       % MPa
batchB = 418 + 12*randn(40, 1);

fprintf('Batch A: mean %.1f MPa, std %.1f\n', mean(batchA), std(batchA));
fprintf('Batch B: mean %.1f MPa, std %.1f\n', mean(batchB), std(batchB));
[h, p, ci, stats] = ttest2(batchB, batchA, 'Vartype', 'unequal');
fprintf('Difference B - A: 95%% interval %.1f to %.1f MPa; t = %.2f, p = %.3f\n', ci(1), ci(2), stats.tstat, p);

boxplot([batchA batchB], 'Labels', {'Batch A', 'Batch B'});
title(sprintf('Tensile strength, Welch t-test p = %.3f', p));
xlabel('Batch');
ylabel('Strength (MPa)');
grid on;
