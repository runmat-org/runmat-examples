% A CT scan of a potted module, 96 slices of 96 x 96 voxels, searched for voids:
% voxels much less dense than the potting, grouped and located.
rng(4);
N = 96;
[X, Y, Z] = meshgrid(1:N, 1:N, 1:N);
V = 0.8 + 0.05*randn(N, N, N);                               % potting density
V(((X - 60).^2 + (Y - 40).^2 + (Z - 50).^2) < 4^2) = 0.1;    % a void
V(((X - 30).^2 + (Y - 70).^2 + (Z - 20).^2) < 2^2) = 0.1;    % a smaller one
mask = V < 0.4;
[r, c, p] = ind2sub(size(mask), find(mask));
big = (c - 60).^2 + (r - 40).^2 + (p - 50).^2 < 36;
fprintf('%d void voxels found in %d slices\n', nnz(mask), numel(unique(p)));
fprintf('largest void centered at (%.0f, %.0f, %.0f), %d voxels\n', mean(c(big)), mean(r(big)), mean(p(big)), nnz(big));

imagesc(V(:, :, 50), [0 1]);
axis xy;
colormap(gray);
title('Slice 50 with the void');
xlabel('x (voxels)');
ylabel('y (voxels)');
