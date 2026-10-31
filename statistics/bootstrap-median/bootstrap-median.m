% A percentile interval for the median of a skewed sample, from 2,000 resamples
rng(4);
repair = exprnd(3.5, 60, 1);           % hours to repair, a skewed sample

medians = bootstrp(2000, @median, repair);
ci = prctile(medians, [2.5 97.5]);
fprintf('Median %.2f h; 95%% bootstrap interval %.2f to %.2f h\n', median(repair), ci(1), ci(2));
fprintf('Mean %.2f h sits above the median: the sample is skewed (skewness %.2f)\n', mean(repair), skewness(repair));

histogram(medians, 25);
xline(ci(1), 'r--', '2.5%');
xline(ci(2), 'r--', '97.5%');
xline(median(repair), 'k', 'sample median');
title('Bootstrap distribution of the median');
xlabel('Median repair time (h)');
ylabel('Resamples');
grid on;
