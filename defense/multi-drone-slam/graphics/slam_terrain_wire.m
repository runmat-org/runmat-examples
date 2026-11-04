function W = slam_terrain_wire(H, gx, every)
% SLAM_TERRAIN_WIRE  The ground-truth heightfield as a sparse wireframe.
%
%   W = slam_terrain_wire(H, gx, every) returns W.x, W.y and W.z: the grid
%   lines of every every-th row and column of H, NaN-separated, for one
%   plot3 call.

    idx = 1:every:numel(gx);
    [X, Y] = meshgrid(gx(idx), gx(idx));
    Z = H(idx, idx);
    n = numel(idx);
    pad = nan(1, n);
    W.x = [reshape([X; pad], [], 1); reshape([X'; pad], [], 1)];
    W.y = [reshape([Y; pad], [], 1); reshape([Y'; pad], [], 1)];
    W.z = [reshape([Z; pad], [], 1); reshape([Z'; pad], [], 1)];
end
