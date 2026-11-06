function slam_play(S, settings)
% SLAM_PLAY  Plays a SLAM run in real time.
%
%   slam_play(S, settings) builds the playback figure (slam_scene) and steps it
%   through the run at settings.rate simulation steps per second, timed by
%   the wall clock. When a frame takes longer to draw than one step, the
%   next frame jumps to the step that is due, so the run keeps its pace on a
%   slow machine; a fast machine waits between frames. The camera of the
%   map is never moved, so it can be orbited and zoomed while it plays.
%   The last frame is always the last step, and slam_scene_finish then
%   draws the finished map as slam_draw does.
%
%   The figures are presented while the script pauses, so every frame
%   pauses at least 10 ms. drawnow is called as well when the runtime
%   provides it; RunMat 0.7.0 reports it unavailable
%   (RunMat:RuntimeContext:CapabilityUnavailable).

    opts = struct('light', settings.light, 'fontSize', settings.fontSize);
    T = S.cfg.T;
    G = slam_scene(S, opts);
    flush = slamDrawnowWorks();
    fprintf('Playing %d steps at %d steps per second (%.0f s). Drag the map to orbit, scroll to zoom.\n', ...
        T, settings.rate, T ./ settings.rate);
    tPlay = tic;
    f = 1;
    frames = 1;
    while f < T
        % Frame k is due (k - 1) / fps seconds in and shows the step due
        % then. Every frame pauses at least settings.minPause: the figures
        % are presented while the script waits.
        pause(max(frames ./ settings.fps - toc(tPlay), settings.minPause));
        f = min(T, max(f + 1, 1 + floor(toc(tPlay) .* settings.rate)));
        G = slam_scene_step(G, S, f);
        if flush
            drawnow;
        end
        frames = frames + 1;
    end
    slam_scene_finish(G, S);
    fprintf('Played %d steps in %.1f s (%d frames).\n', T, toc(tPlay), frames);
end

function ok = slamDrawnowWorks()
    ok = true;
    try
        drawnow;
    catch
        ok = false;
    end
end
