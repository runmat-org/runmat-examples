function est = slam_estimate(epochs, eventSolve, snapFrames, f)
% SLAM_ESTIMATE  The pose estimate shown at step f.
%
%   est = slam_estimate(epochs, eventSolve, snapFrames, f) returns the
%   D x T x 3 estimate (x, y, yaw) of the latest epoch solved by step f,
%   blended in from the previous epoch over snapFrames steps with a
%   smoothstep. slam_simulate uses it for the error plot and slam_draw for
%   the map, so both show the same estimate.

    e = sum(eventSolve <= f);
    est = epochs(:, :, :, e + 1);
    if e > 0
        a = min(max((f - eventSolve(e)) ./ snapFrames, 0), 1);
        a = a .^ 2 .* (3 - 2 .* a);
        est = (1 - a) .* epochs(:, :, :, e) + a .* est;
    end
end
