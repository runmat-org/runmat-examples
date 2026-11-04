function G = slam_scene_finish(G, S)
% SLAM_SCENE_FINISH  Ends playback on the finished map.
%
%   G = slam_scene_finish(G, S) replaces the playback's map strokes with one
%   scatter3 cloud of every map point at the last step, colored by height,
%   as slam_draw draws it. The strokes take about three times the data of
%   the cloud, and RunMat keeps no interactive scene of figure 1 for the
%   finished run when the strokes are left in place. The camera is not
%   touched.

    T = S.cfg.T;
    est = slam_estimate(S.epochs, S.eventSolve, S.cfg.snapFrames, T);
    [px, py, pz] = slam_map_points(S, est, T);
    for b = 1:G.bands
        set(G.map(b), 'XData', NaN, 'YData', NaN, 'ZData', NaN);
    end
    G.cloud = scatter3(G.ax1, px, py, pz, 2.6, pz, 'filled');
    colormap(turbo);
    caxis([0 115]);
end
