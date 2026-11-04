function [px, py, pz] = slam_map_points(S, est, f)
% SLAM_MAP_POINTS  Map points scanned by step f, placed through an estimate.
%
%   [px, py, pz] = slam_map_points(S, est, f) takes the map points stored in
%   each drone's body frame (S.ptBody) and places every point scanned up to
%   step f through the pose estimate est (D x T x 3: x, y, yaw) at the step
%   it was scanned. Heights use the true altitude.

    cfg = S.cfg;
    seen = S.ptStep <= f;
    k = S.ptDrone(seen) + (S.ptStep(seen) - 1) .* cfg.D;
    ex = est(:, :, 1);
    ey = est(:, :, 2);
    eyaw = est(:, :, 3);
    tz = S.truth(:, :, 3);
    c = cos(eyaw(k));
    sn = sin(eyaw(k));
    b = S.ptBody(seen, :);
    px = ex(k) + c .* b(:, 1) - sn .* b(:, 2);
    py = ey(k) + sn .* b(:, 1) + c .* b(:, 2);
    pz = tz(k) + b(:, 3);
end
