function G = slam_scene_step(G, S, f)
% SLAM_SCENE_STEP  Moves the figures slam_scene built to step f.
%
%   G = slam_scene_step(G, S, f) sets the data of every moving object to
%   step f: the map points re-placed through the pose estimate shown at f
%   (slam_estimate), each drone's true and estimated path over the last
%   G.trail steps, its LIDAR rays and its position, and the error and
%   coverage curves up to f. A sync mark is added to figures 2 and 3 for each
%   pose-graph solve reached since the last call. Nothing else in the
%   figures changes, so the camera stays where the viewer put it.

    cfg = S.cfg;
    est = slam_estimate(S.epochs, S.eventSolve, cfg.snapFrames, f);
    [px, py, pz] = slam_map_points(S, est, f);
    band = min(max(floor(pz ./ G.zTop .* G.bands) + 1, 1), G.bands);
    for b = 1:G.bands
        in = band == b;
        if any(in)
            set(G.map(b), 'XData', slamDots(px(in), G.dotLength), 'YData', slamDots(py(in), 0), ...
                'ZData', slamDots(pz(in), 0));
        else
            set(G.map(b), 'XData', NaN, 'YData', NaN, 'ZData', NaN);
        end
    end

    recent = max(1, f - G.trail):f;
    for d = 1:cfg.D
        tx = squeeze(S.truth(d, recent, 1));
        ty = squeeze(S.truth(d, recent, 2));
        tz = squeeze(S.truth(d, recent, 3));
        set(G.truthLine(d), 'XData', tx, 'YData', ty, 'ZData', tz);
        set(G.estLine(d), 'XData', squeeze(est(d, recent, 1)), 'YData', squeeze(est(d, recent, 2)), 'ZData', tz);
        rx = squeeze(S.rays(d, f, :, 1));
        ry = squeeze(S.rays(d, f, :, 2));
        rz = squeeze(S.rays(d, f, :, 3));
        n = numel(rx);
        ox = S.truth(d, f, 1) .* ones(n, 1);
        oy = S.truth(d, f, 2) .* ones(n, 1);
        oz = S.truth(d, f, 3) .* ones(n, 1);
        set(G.rayLine(d), 'XData', reshape([ox rx nan(n, 1)]', [], 1), ...
            'YData', reshape([oy ry nan(n, 1)]', [], 1), 'ZData', reshape([oz rz nan(n, 1)]', [], 1));
        q = slamDroneGlyph(squeeze(S.truth(d, f, :)), G.droneRadius);
        set(G.drone(d), 'XData', q(:, 1), 'YData', q(:, 2), 'ZData', q(:, 3));
        set(G.err(d), 'XData', 1:f, 'YData', S.errShown(d, 1:f));
    end
    set(G.cov, 'XData', 1:f, 'YData', S.coverage(1:f));

    while G.marksDrawn < numel(S.eventSolve) && S.eventSolve(G.marksDrawn + 1) <= f
        G.marksDrawn = G.marksDrawn + 1;
        t = S.eventSolve(G.marksDrawn);
        slamSyncMark(G.ax2, t, G.errTop, cfg.T, G.style.mark, G.markSize);
        slamSyncMark(G.ax3, t, 100, cfg.T, G.style.mark, G.markSize);
    end
end

function slamSyncMark(ax, t, yTop, xSpan, color, fontSize)
    % One sync mark, placed as draw_sync_marks places it.
    plot(ax, [t t], [0 yTop], ':', 'Color', color, 'LineWidth', 2);
    text(ax, t - 0.07 .* xSpan, 0.92 .* yTop, 'sync', 'FontSize', fontSize, 'Color', color);
end

function v = slamDots(c, len)
    % Each point as a short stroke from c to c + len, NaN-separated, so one
    % line object draws a band of points (plot3 draws no markers in RunMat).
    c = reshape(c, [], 1);
    v = reshape([c, c + len, nan(numel(c), 1)]', [], 1);
end

function q = slamDroneGlyph(pose, radius)
    % The drone marker: a flat spiral of three turns out to radius around the
    % true position (pose = [x y z yaw]). One unbroken thick path draws as a
    % filled disc; plot3 draws no markers in RunMat.
    u = linspace(0, 1, 49)';
    a = pose(4) + 6 .* pi .* u;
    q = [pose(1) + radius .* u .* cos(a), pose(2) + radius .* u .* sin(a), pose(3) + 0 .* u];
end
