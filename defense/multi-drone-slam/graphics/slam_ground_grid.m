function G = slam_ground_grid(lo, hi, step)
% SLAM_GROUND_GRID  A hairline ground grid at z = 0.
%
%   G = slam_ground_grid(lo, hi, step) returns G.x, G.y and G.z: NaN-separated
%   lines from lo to hi in x and y, every step meters, for one plot3 call.
%   RunMat's 3D grid (grid on) uses fixed theme colors, which are heavy in
%   the light theme, so the figures draw this one instead.

    v = lo:step:hi;
    n = numel(v);
    a = [lo .* ones(1, n); hi .* ones(1, n); nan(1, n)];
    b = [v; v; nan(1, n)];
    G.x = [a(:); b(:)];
    G.y = [b(:); a(:)];
    G.z = zeros(2 .* 3 .* n, 1);
end
