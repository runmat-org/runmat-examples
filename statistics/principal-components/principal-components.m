% Four correlated gauge readings per part: how many directions carry the variation?
rng(11);
n = 200;
sz = randn(n, 1);
warp = randn(n, 1);
X = [sz + 0.1*randn(n, 1), 0.9*sz + 0.2*randn(n, 1), ...
     0.7*sz + 0.5*warp + 0.2*randn(n, 1), 0.6*warp + 0.3*randn(n, 1)];

[coeff, score, ~, ~, explained] = pca(X);
fprintf('Variance explained: %s %%\n', sprintf('%.1f ', explained));
fprintf('First component loadings: %s\n', sprintf('%.2f ', coeff(:, 1)));

subplot(1, 2, 1);
bar(explained);
title('Variance explained');
xlabel('Component');
ylabel('Percent');
grid on;

subplot(1, 2, 2);
scatter(score(:, 1), score(:, 2), 12, 'filled');
title('Parts on the first two components');
xlabel('Component 1');
ylabel('Component 2');
grid on;
