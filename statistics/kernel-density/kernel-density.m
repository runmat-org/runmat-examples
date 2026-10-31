% Two populations mixed in one sample: a histogram hides it, a kernel density shows it
rng(10);
cycle = [8 + 0.6*randn(220, 1); 11 + 0.9*randn(130, 1)];    % cycle time, s

[f, xi] = ksdensity(cycle);
[~, k] = max(f);
fprintf('%d cycles; densest at %.2f s\n', numel(cycle), xi(k));

histogram(cycle, 12, 'Normalization', 'pdf');
hold on;
plot(xi, f, 'LineWidth', 2.2);
hold off;
legend('histogram, 12 bins', 'kernel density');
title('Cycle times from two machine settings');
xlabel('Cycle time (s)');
ylabel('Density');
grid on;
