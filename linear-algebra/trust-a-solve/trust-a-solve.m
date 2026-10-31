% Solve an ill-conditioned system two ways and check each answer
x = (0:11)' / 11;
A = x .^ (0:11);                  % 12-by-12 Vandermonde matrix
xtrue = ones(12, 1);
b = A * xtrue;

x1 = inv(A) * b;
x2 = A \ b;

fprintf('cond(A) = %.1e, so expect to lose about %.0f of 16 digits\n', cond(A), log10(cond(A)));
fprintf('Error: inv(A)*b %.1e, A\\b %.1e\n', norm(x1 - xtrue), norm(x2 - xtrue));

s = svd(A);
semilogy(1:12, s, 'o-');
title('Singular values of the Vandermonde matrix');
xlabel('Index');
ylabel('Singular value');
grid on;
