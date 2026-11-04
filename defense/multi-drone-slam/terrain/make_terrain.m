function terrain = make_terrain(cfg)
% MAKE_TERRAIN  Procedural mountain heightfield.
%
%   terrain = make_terrain(cfg) blends two periodic diamond-square fractals
%   (60 % smooth, 40 % folded into ridges), smooths the result and shapes it
%   to 0 to 110 m over a cfg.L-meter square world. Returns terrain.H, the
%   (M+1) x (M+1) heights with H(row = y, col = x), terrain.cell, the cell
%   size in meters, and terrain.gx, the grid coordinates.

    M = cfg.M;
    base = diamondSquare(M, 0.62);
    ridgeSrc = diamondSquare(M, 0.48);
    ridged = (1 - abs(2 .* ridgeSrc - 1)) .^ 2.2;
    H = 0.60 .* base + 0.40 .* ridged;
    H = conv2([H H; H H], ones(5, 5) ./ 25, 'same');
    H = H(1:M, 1:M);
    H = (H - min(H(:))) ./ (max(H(:)) - min(H(:)));
    H = 110 .* H .^ 1.35;
    terrain.H = [H H(:, 1); H(1, :) H(1, 1)];   % (M+1)^2, H(row = y, col = x)
    terrain.cell = cfg.L ./ M;
    terrain.gx = linspace(0, cfg.L, M + 1);
end

function F = diamondSquare(M, roughness)
    % Periodic diamond-square fractal on an M x M grid (M a power of two).
    F = zeros(M, M);
    step = M;
    amp = 1;
    while step > 1
        half = step ./ 2;
        r = (half:step:M-1) + 1;
        c0 = mod(r - 1 - half, M) + 1;
        c1 = mod(r - 1 + half, M) + 1;
        F(r, r) = (F(c0, c0) + F(c0, c1) + F(c1, c0) + F(c1, c1)) ./ 4 + amp .* randn(numel(r));
        a = (half:step:M-1) + 1;
        b = (0:step:M-1) + 1;
        F(a, b) = squareAvg(F, a, b, half, M) + amp .* randn(numel(a), numel(b));
        F(b, a) = squareAvg(F, b, a, half, M) + amp .* randn(numel(b), numel(a));
        amp = amp .* 2 .^ (-roughness);
        step = half;
    end
    F = (F - min(F(:))) ./ (max(F(:)) - min(F(:)));
end

function v = squareAvg(F, r, c, half, M)
    up = mod(r - 1 - half, M) + 1;
    dn = mod(r - 1 + half, M) + 1;
    lf = mod(c - 1 - half, M) + 1;
    rt = mod(c - 1 + half, M) + 1;
    v = (F(up, c) + F(dn, c) + F(r, lf) + F(r, rt)) ./ 4;
end
