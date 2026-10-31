% Draw correlated random vectors from a covariance matrix with chol
Sigma = [1.0 0.8; 0.8 2.0];
R = chol(Sigma);                  % Sigma = R' * R
Z = randn(20000, 2);
X = Z * R;

C = cov(X);
fprintf('Target covariance [1.00 0.80; 0.80 2.00]\n');
fprintf('Sample covariance [%.2f %.2f; %.2f %.2f]\n', C(1, 1), C(1, 2), C(2, 1), C(2, 2));

plot(X(1:2000, 1), X(1:2000, 2), '.');
title('Correlated samples from chol');
xlabel('x1');
ylabel('x2');
axis equal;
grid on;
