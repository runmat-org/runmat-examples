% How much of a noisy matrix do the first five singular values carry?
Z = peaks(120);
A = Z + 0.2*randn(size(Z));

[U, S, V] = svd(A);
s = diag(S);
r = 5;
Ar = U(:, 1:r) * S(1:r, 1:r) * V(:, 1:r)';

energy = cumsum(s.^2) / sum(s.^2);
fprintf('Rank %d keeps %.1f%% of the energy\n', r, 100*energy(r));
fprintf('Relative error: noisy %.3f, rank %d %.3f\n', norm(A - Z, 'fro')/norm(Z, 'fro'), r, norm(Ar - Z, 'fro')/norm(Z, 'fro'));

subplot(1, 2, 1);
imagesc([1 120], [1 120], A);
title('Noisy matrix');
xlabel('Column');
ylabel('Row');
subplot(1, 2, 2);
imagesc([1 120], [1 120], Ar);
title('Rank 5 approximation');
xlabel('Column');
ylabel('Row');
