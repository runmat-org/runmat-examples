function slam_draw(S, f, opts)
% SLAM_DRAW  Draws the SLAM result at step f in figures 1 to 3.
%
%   slam_draw(S, f, opts) takes S from slam_simulate and draws:
%     figure 1  the 3D map: a ground grid every 50 m, terrain wireframe
%               (ground truth), map points colored by height, true paths
%               (dashed), estimated paths, LIDAR rays and drones
%     figure 2  position error of each drone against step
%     figure 3  map coverage against step
%   opts.light    true for the light-theme palette
%   opts.fontSize title size; axis labels and ticks scale from it
%   opts.sceneScale optional; scales figure 1's text, for a printed scene
%                 that is shrunk more than figures 2 and 3 (default 1)
%
% The map points are stored in each drone's body frame and re-projected
% through the pose estimate at step f: dead reckoning until the first
% closure event, then the latest pose-graph solve. The map snaps when an
% event's solve lands; figures 2 and 3 mark each solve reached by step f
% with a dotted "sync" line. Paths show the last trail steps only.

    cfg = S.cfg;
    trail = 150;
    sceneSize = opts.fontSize;
    if isfield(opts, 'sceneScale')
        sceneSize = round(opts.fontSize .* opts.sceneScale);
    end
    % Step ticks start after 0, so the x and y zero labels do not collide.
    tickStep = 50;
    if cfg.T >= 300
        tickStep = 100;
    end
    stepTicks = tickStep:tickStep:cfg.T;
    style = slam_style(opts.light);
    wire = slam_terrain_wire(S.H, S.gx, 8);
    est = slam_estimate(S.epochs, S.eventSolve, cfg.snapFrames, f);   % D x T x 3 (x, y, yaw)

    [px, py, pz] = slam_map_points(S, est, f);

    figure(1);
    clf;
    % A drawn hairline ground grid: RunMat's 3D grid (grid on) uses fixed theme
    % colors, which are heavy in the light theme.
    ground = slam_ground_grid(-1000, 1500, 50);
    plot3(ground.x, ground.y, ground.z, '-', 'Color', style.grid, 'LineWidth', 0.6);
    hold on;
    plot3(wire.x, wire.y, wire.z, '-', 'Color', style.wire, 'LineWidth', 0.6);
    scatter3(px, py, pz, 2.6, pz, 'filled');
    colormap(turbo);
    caxis([0 115]);
    recent = max(1, f - trail):f;
    for d = 1:cfg.D
        tx = squeeze(S.truth(d, recent, 1));
        ty = squeeze(S.truth(d, recent, 2));
        tzz = squeeze(S.truth(d, recent, 3));
        plot3(tx, ty, tzz, '--', 'Color', style.truth, 'LineWidth', 1.4);
        plot3(squeeze(est(d, recent, 1)), squeeze(est(d, recent, 2)), tzz, '-', ...
            'Color', style.drone(d, :), 'LineWidth', 3.2);
        rx = squeeze(S.rays(d, f, :, 1));
        ry = squeeze(S.rays(d, f, :, 2));
        rz = squeeze(S.rays(d, f, :, 3));
        n = numel(rx);
        ox = S.truth(d, f, 1) .* ones(n, 1);
        oy = S.truth(d, f, 2) .* ones(n, 1);
        oz = S.truth(d, f, 3) .* ones(n, 1);
        plot3(reshape([ox rx nan(n, 1)]', [], 1), reshape([oy ry nan(n, 1)]', [], 1), ...
            reshape([oz rz nan(n, 1)]', [], 1), '-', 'Color', style.ray, 'LineWidth', 0.7);
        scatter3(S.truth(d, f, 1), S.truth(d, f, 2), S.truth(d, f, 3), 260, style.drone(d, :), 'filled');
    end
    axis([0 cfg.L 0 cfg.L 0 200]);
    grid off;
    % RunMat 0.7.0 RC draws a 3D title in a fixed 28 px band and clips a
    % large one at the top; the empty first line gives it room.
    title(sprintf('\nDrones scanning terrain'), 'FontSize', sceneSize);
    set(gca, 'FontSize', round(sceneSize .* 0.8));
    % A slow orbit over the run; RunMat's 3D auto-framing needs the explicit
    % limits above and this zoom. At this zoom RunMat labels the x and y
    % axes every 100 m (100 to 400, along the terrain's back edges) and
    % altitude every 50 m.
    view(32 + 26 .* (f - 1) ./ (cfg.T - 1), 34 - 4 .* (f - 1) ./ (cfg.T - 1));
    zoom(1.5);

    steps = 1:f;
    small = round(opts.fontSize .* 0.8);
    mark = round(opts.fontSize .* 0.7);
    figure(2);
    clf;
    hold on;
    errTop = ceil(max(S.errShown(:)) ./ 10) .* 10;
    draw_sync_marks(S, f, errTop, cfg.T, style.mark, mark);
    for d = 1:cfg.D
        plot(steps, S.errShown(d, 1:f), '-', 'Color', style.drone(d, :), 'LineWidth', 5);
    end
    xlim([0 cfg.T]);
    ylim([0 errTop]);
    title('Position error (m)', 'FontSize', opts.fontSize);
    xlabel('Step', 'FontSize', small);
    set(gca, 'FontSize', small, 'XTick', stepTicks);

    figure(3);
    clf;
    hold on;
    draw_sync_marks(S, f, 100, cfg.T, style.mark, mark);
    plot(steps, S.coverage(1:f), '-', 'Color', style.drone(3, :), 'LineWidth', 5);
    xlim([0 cfg.T]);
    ylim([0 100]);
    title('Map coverage (%)', 'FontSize', opts.fontSize);
    xlabel('Step', 'FontSize', small);
    set(gca, 'FontSize', small, 'XTick', stepTicks);
end
