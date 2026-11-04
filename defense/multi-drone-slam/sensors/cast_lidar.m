function scan = cast_lidar(cfg, terrain, truth, tStart)
% CAST_LIDAR  LIDAR scans and map coverage along the true trajectories.
%
%   scan = cast_lidar(cfg, terrain, truth, tStart) casts, every step,
%   D x nAz x nEl rays at once from the true poses. Each ray is sampled
%   nMarch times along its length, the first sample under the terrain is
%   found with max(), and the crossing is refined linearly. Returns:
%     scan.body, scan.drone, scan.step, scan.valid  map points in each
%         drone's body frame, keepPerDrone per drone per step
%     scan.rays      D x T x showPerDrone x 3 ray end points to draw (NaN
%                    for a miss)
%     scan.coverage  1 x T share of the coverage grid hit so far, %
%     scan.raysCast, scan.hits  totals
%   It prints a progress line every 30 steps, timed from tStart (a tic).

    D = cfg.D;
    T = cfg.T;
    nRay = cfg.nAz .* cfg.nEl;
    [AZ, EL] = meshgrid((0:cfg.nAz-1) .* 2 .* pi ./ cfg.nAz, linspace(-60, -87, cfg.nEl) .* pi ./ 180);
    AZ = repmat(AZ(:), D, 1);
    EL = repmat(EL(:), D, 1);
    droneOfRay = reshape(repmat(1:D, nRay, 1), [], 1);
    ts = (1:cfg.nMarch) .* cfg.dt;
    keep = cfg.keepPerDrone;
    show = cfg.showPerDrone;
    covered = zeros(cfg.covN .* cfg.covN, 1);
    scan.coverage = zeros(1, T);
    scan.body = zeros(D .* T .* keep, 3);
    scan.drone = zeros(D .* T .* keep, 1);
    scan.step = zeros(D .* T .* keep, 1);
    scan.valid = false(D .* T .* keep, 1);
    scan.rays = nan(D, T, show, 3);
    scan.raysCast = 0;
    scan.hits = 0;
    for t = 1:T
        ox = truth(droneOfRay, t, 1);
        oy = truth(droneOfRay, t, 2);
        oz = truth(droneOfRay, t, 3);
        yaw = truth(droneOfRay, t, 4);
        az = AZ + yaw + 0.21 .* t;
        ux = cos(EL) .* cos(az);
        uy = cos(EL) .* sin(az);
        uz = sin(EL);
        gap = (oz + uz .* ts) - terrainAt(terrain, ox + ux .* ts, oy + uy .* ts);
        [anyHit, first] = max(gap < 0, [], 2);
        hit = anyHit > 0;
        R = numel(ox);
        g2 = gap(sub2ind(size(gap), (1:R)', first));
        g1 = gap(sub2ind(size(gap), (1:R)', max(first - 1, 1)));
        g0 = oz - terrainAt(terrain, ox, oy);
        g1(first == 1) = g0(first == 1);
        tHit = ts(first)' - cfg.dt + cfg.dt .* g1 ./ (g1 - g2);
        hx = ox + ux .* tHit;
        hy = oy + uy .* tHit;
        hz = oz + uz .* tHit;
        scan.raysCast = scan.raysCast + R;
        scan.hits = scan.hits + sum(hit);

        % Coverage: fixed-shape accumulation, misses go to a spill cell
        ci = min(max(floor(hx ./ (cfg.L ./ cfg.covN)), 0), cfg.covN - 1);
        cj = min(max(floor(hy ./ (cfg.L ./ cfg.covN)), 0), cfg.covN - 1);
        cell = cj + ci .* cfg.covN + 1;
        cell(~hit) = cfg.covN .* cfg.covN + 1;
        counts = accumarray(cell, 1, [cfg.covN .* cfg.covN + 1, 1]);
        covered = min(covered + counts(1:end-1), 1);
        scan.coverage(t) = 100 .* mean(covered);

        % Map points: a random, fixed-size subset per drone, stored in the
        % drone's body frame so any pose estimate can re-project them.
        score = reshape(rand(R, 1) + hit, nRay, D);
        [~, order] = sort(score, 1, 'descend');
        pick = order(1:keep, :) + (0:D-1) .* nRay;
        pick = pick(:);
        rx = hx(pick) - ox(pick);
        ry = hy(pick) - oy(pick);
        c = cos(yaw(pick));
        sn = sin(yaw(pick));
        rows = (t - 1) .* D .* keep + (1:D .* keep);
        scan.body(rows, :) = [c .* rx + sn .* ry, -sn .* rx + c .* ry, hz(pick) - oz(pick)];
        scan.drone(rows) = droneOfRay(pick);
        scan.step(rows) = t;
        scan.valid(rows) = hit(pick);

        % Rays to draw: evenly spaced around each drone's fan
        sel = round(linspace(1, nRay, show))' + (0:D-1) .* nRay;
        sel = sel(:);
        hxs = hx(sel);
        hys = hy(sel);
        hzs = hz(sel);
        miss = ~hit(sel);
        hxs(miss) = NaN;
        hys(miss) = NaN;
        hzs(miss) = NaN;
        scan.rays(:, t, :, 1) = reshape(hxs, show, D)';
        scan.rays(:, t, :, 2) = reshape(hys, show, D)';
        scan.rays(:, t, :, 3) = reshape(hzs, show, D)';

        if mod(t, 30) == 0 || t == T
            fprintf('[%5.1f s] LIDAR step %d of %d, %.1f %% mapped\n', toc(tStart), t, T, scan.coverage(t));
        end
    end
end

function h = terrainAt(terrain, X, Y)
    % Bilinear heightfield lookup; points outside the world return -1e9.
    H = terrain.H;
    n = size(H, 1);
    M = n - 1;
    u = X ./ terrain.cell;
    v = Y ./ terrain.cell;
    inside = u >= 0 & u < M & v >= 0 & v < M;
    u = min(max(u, 0), M - 1e-9);
    v = min(max(v, 0), M - 1e-9);
    i0 = floor(u);
    j0 = floor(v);
    fu = u - i0;
    fv = v - j0;
    k00 = j0 + 1 + i0 .* n;
    h = (1 - fu) .* (1 - fv) .* H(k00) + fu .* (1 - fv) .* H(k00 + n) ...
        + (1 - fu) .* fv .* H(k00 + 1) + fu .* fv .* H(k00 + n + 1);
    h(~inside) = -1e9;
end
