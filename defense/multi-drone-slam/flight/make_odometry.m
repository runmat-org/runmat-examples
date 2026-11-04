function odo = make_odometry(cfg, truth)
% MAKE_ODOMETRY  Drifting visual-inertial odometry.
%
%   odo = make_odometry(cfg, truth) returns D x T x 3 body-frame increments
%   (forward, left, dyaw) measured along the true trajectories. The main
%   error is a slow velocity bias fixed in the world frame (as an
%   uncorrected wind or flow bias gives), so position drift grows steadily
%   between corrections; a small scale error, yaw-rate bias and white noise
%   ride on top. dead_reckon.m integrates the increments into poses.

    D = cfg.D;
    T = cfg.T;
    biasWorld = [0.070 0.035; -0.040 0.068; -0.066 -0.042; 0.045 -0.066];   % m per step
    yawBias = [0.00012; -0.0001; 0.00014; -0.00012];
    scaleErr = [1.005; 0.995; 1.004; 0.996];
    ddx = diff(truth(:, :, 1), 1, 2) + biasWorld(:, 1);
    ddy = diff(truth(:, :, 2), 1, 2) + biasWorld(:, 2);
    yaw0 = truth(:, 1:T-1, 4);
    fwd = cos(yaw0) .* ddx + sin(yaw0) .* ddy;
    lft = -sin(yaw0) .* ddx + cos(yaw0) .* ddy;
    dyaw = diff(truth(:, :, 4), 1, 2);
    odo = zeros(D, T, 3);
    odo(:, 2:T, 1) = scaleErr .* fwd + 0.03 .* randn(D, T - 1);
    odo(:, 2:T, 2) = lft + 0.03 .* randn(D, T - 1);
    odo(:, 2:T, 3) = dyaw + yawBias + 0.0008 .* randn(D, T - 1);
end
