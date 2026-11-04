function truth = fly_routes(cfg)
% FLY_ROUTES  True trajectories of the drones.
%
%   truth = fly_routes(cfg) returns a D x T x 4 array (x, y, z, yaw) of
%   petal-shaped routes from the launch area. Each drone flies petals from
%   its launch pad: out along one leg, round a tip, back along the other
%   leg. Petal k of drone d points at (d-1)*90 + k*petalTurn degrees, so
%   every petal maps new ground and only the legs near the launch area
%   cross earlier track.

    D = cfg.D;
    T = cfg.T;
    center = [cfg.L cfg.L] ./ 2;
    truth = zeros(D, T, 4);   % x, y, z, yaw
    for d = 1:D
        padAngle = (d - 1) .* pi ./ 2 + pi ./ 4;
        pad = center + 7 .* [cos(padAngle) sin(padAngle)];
        s = (0:T-1) - (d - 1) .* cfg.stagger;
        k = floor(s ./ cfg.petal);
        u = (s - k .* cfg.petal) ./ cfg.petal;
        heading = (d - 1) .* pi ./ 2 + k .* cfg.petalTurn .* pi ./ 180;
        r = cfg.petalReach .* sin(pi .* u);
        ang = heading - cfg.petalWidth .* cos(pi .* u);
        x = pad(1) + r .* cos(ang);
        y = pad(2) + r .* sin(ang);
        truth(d, :, 1) = x;
        truth(d, :, 2) = y;
        truth(d, :, 3) = 150 + 4 .* d + 5 .* sin(2 .* pi .* u);
        truth(d, :, 4) = unwrap(atan2(gradient(y), gradient(x)));
    end
end
