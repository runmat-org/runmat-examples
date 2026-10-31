% The smallest eigenvalues of a sparse operator: a 1-D Laplacian with 500 points
n = 500;  h = 1/(n + 1);
e = ones(n, 1);
L = spdiags(e * [-1 2 -1], -1:1, n, n);       % second difference; divide by h^2 for the Laplacian

lambda = sort(eigs(L, 5, 'smallestabs')) / h^2;
exact = (pi * (1:5)').^2;

fprintf('Matrix: %d by %d with %d nonzeros\n', n, n, nnz(L));
fprintf('Five smallest eigenvalues within %.1e of (k*pi)^2\n', max(abs(lambda - exact) ./ exact));

plot(1:5, lambda, 'o');
hold on;
plot(1:5, exact, '-');
legend('eigs', '(k\pi)^2');
title('Smallest eigenvalues of a sparse Laplacian');
xlabel('k');
ylabel('Eigenvalue');
grid on;
