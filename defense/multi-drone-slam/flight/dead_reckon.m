function P = dead_reckon(odo, start, t0, T)
% DEAD_RECKON  Integrates odometry into poses.
%
%   P = dead_reckon(odo, start, t0, T) integrates the body-frame increments
%   odo (D x T x 3, from make_odometry) from start (D x 3: x, y, yaw) at
%   step t0 and returns D x T x 3 poses; steps before t0 stay zero.

    D = size(odo, 1);
    P = zeros(D, T, 3);
    P(:, t0, :) = reshape(start, [D 1 3]);
    for t = t0+1:T
        yaw = P(:, t-1, 3);
        P(:, t, 1) = P(:, t-1, 1) + cos(yaw) .* odo(:, t, 1) - sin(yaw) .* odo(:, t, 2);
        P(:, t, 2) = P(:, t-1, 2) + sin(yaw) .* odo(:, t, 1) + cos(yaw) .* odo(:, t, 2);
        P(:, t, 3) = yaw + odo(:, t, 3);
    end
end
