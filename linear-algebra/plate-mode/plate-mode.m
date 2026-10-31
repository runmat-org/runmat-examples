% A vibration mode of a rectangular plate, from the smallest eigenvalues of its Laplacian
nx = 30;  ny = 20;  h = 1/(nx + 1);
[X, Y] = meshgrid((1:nx)*h, (1:ny)*h);

% Five-point Laplacian on the grid, stored sparse for eigs
T = @(m) toeplitz([2 -1 zeros(1, m - 2)]);
K = sparse(kron(eye(nx), T(ny)) + kron(T(nx), eye(ny)));

[V, D] = eigs(K, 12, 'smallestabs');
[lambda, order] = sort(diag(D) / h^2);
v = V(:, order(12));

Z = 0.15 * reshape(v / max(abs(v)), ny, nx);    % displacement drawn at 15% of the plate length
surf(X, Y, Z);
shading interp;
title('Plate mode 12 from eigs');
xlabel('x');
ylabel('y');
zlabel('Displacement');
view(-35, 40);
