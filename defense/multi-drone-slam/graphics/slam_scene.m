function G = slam_scene(S, opts)
% SLAM_SCENE  Builds figures 1 to 3 once, for playback.
%
%   G = slam_scene(S, opts) draws the run at step 1 in the layout slam_draw
%   uses and returns the handles slam_scene_step updates at each later step.
%   Only the data of the drawn objects changes after this call; the camera
%   of figure 1 is set here once, so an orbit or zoom made with the mouse
%   during playback stays in place.
%
%   The map points are drawn in G.bands height bands over 0 to 115 m, one
%   line object per band in the turbo colormap, each point a short stroke,
%   and each drone as a small flat spiral. RunMat's set() changes the data
%   of line objects but not of scatter3 objects, and plot3 draws no markers,
%   so lines carry everything that moves. slam_draw, which draws one step
%   from scratch, uses scatter3.
%
%   opts.light and opts.fontSize are as in slam_draw.

    cfg = S.cfg;
    style = slam_style(opts.light);
    G.style = style;
    G.trail = 150;
    G.bands = 16;
    G.bandColors = turbo(G.bands);
    G.zTop = 115;
    G.dotLength = 1.2;
    G.dotWidth = 1.5;
    G.droneRadius = 9;
    G.markSize = round(opts.fontSize .* 0.7);
    G.marksDrawn = 0;
    G.errTop = ceil(max(S.errShown(:)) ./ 10) .* 10;

    figure(1);
    clf;
    ground = slam_ground_grid(-1000, 1500, 50);
    plot3(ground.x, ground.y, ground.z, '-', 'Color', style.grid, 'LineWidth', 0.6);
    hold on;
    wire = slam_terrain_wire(S.H, S.gx, 8);
    plot3(wire.x, wire.y, wire.z, '-', 'Color', style.wire, 'LineWidth', 0.6);
    G.ax1 = gca;
    G.map = zeros(1, G.bands);
    for b = 1:G.bands
        G.map(b) = plot3(NaN, NaN, NaN, '-', 'Color', G.bandColors(b, :), 'LineWidth', G.dotWidth);
    end
    G.truthLine = zeros(1, cfg.D);
    G.estLine = zeros(1, cfg.D);
    G.rayLine = zeros(1, cfg.D);
    G.drone = zeros(1, cfg.D);
    for d = 1:cfg.D
        p = squeeze(S.truth(d, 1, 1:3));
        G.truthLine(d) = plot3(p(1), p(2), p(3), '--', 'Color', style.truth, 'LineWidth', 1.4);
        G.estLine(d) = plot3(p(1), p(2), p(3), '-', 'Color', style.drone(d, :), 'LineWidth', 3.2);
        G.rayLine(d) = plot3(p(1), p(2), p(3), '-', 'Color', style.ray, 'LineWidth', 0.7);
        G.drone(d) = plot3(p(1), p(2), p(3), '-', 'Color', style.drone(d, :), 'LineWidth', 3.5);
    end
    axis([0 cfg.L 0 cfg.L 0 200]);
    grid off;
    % RunMat 0.7.0 RC draws a 3D title in a fixed 28 px band and clips a
    % large one at the top; the empty first line gives it room.
    title(sprintf('\nDrones scanning terrain'), 'FontSize', opts.fontSize);
    set(gca, 'FontSize', round(opts.fontSize .* 0.8));
    % The starting camera of slam_draw's orbit. Playback never moves it.
    view(32, 34);
    zoom(1.5);

    tickStep = 50;
    if cfg.T >= 300
        tickStep = 100;
    end
    stepTicks = tickStep:tickStep:cfg.T;
    small = round(opts.fontSize .* 0.8);

    figure(2);
    clf;
    hold on;
    G.ax2 = gca;
    G.err = zeros(1, cfg.D);
    for d = 1:cfg.D
        G.err(d) = plot(1, S.errShown(d, 1), '-', 'Color', style.drone(d, :), 'LineWidth', 5);
    end
    xlim([0 cfg.T]);
    ylim([0 G.errTop]);
    title('Position error (m)', 'FontSize', opts.fontSize);
    xlabel('Step', 'FontSize', small);
    set(gca, 'FontSize', small, 'XTick', stepTicks);

    figure(3);
    clf;
    hold on;
    G.ax3 = gca;
    G.cov = plot(1, S.coverage(1), '-', 'Color', style.drone(3, :), 'LineWidth', 5);
    xlim([0 cfg.T]);
    ylim([0 100]);
    title('Map coverage (%)', 'FontSize', opts.fontSize);
    xlabel('Step', 'FontSize', small);
    set(gca, 'FontSize', small, 'XTick', stepTicks);

    G = slam_scene_step(G, S, 1);
end
