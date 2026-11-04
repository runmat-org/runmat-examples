function slam_play(S, settings)
% SLAM_PLAY  Plays a SLAM run in real time.
%
%   slam_play(S, settings) builds figures 1 to 3 (slam_scene) and steps them
%   through the run at settings.rate simulation steps per second, timed by
%   the wall clock. When a frame takes longer to draw than one step, the
%   next frame jumps to the step that is due, so the run keeps its pace on a
%   slow machine; a fast machine waits between frames. The camera of figure
%   1 is never moved, so the map can be orbited and zoomed while it plays.
%   The last frame is always the last step.
%
%   Where figures cannot be shown while a script runs (the command-line
%   runtime), it draws the last step only.

    opts = struct('light', settings.light, 'fontSize', settings.fontSize);
    T = S.cfg.T;
    G = slam_scene(S, opts);
    if ~slamCanAnimate()
        slam_scene_step(G, S, T);
        fprintf('Drew step %d; this runtime shows figures when the script ends.\n', T);
        return;
    end
    fprintf('Playing %d steps at %d steps per second (%.0f s). Drag figure 1 to orbit, scroll to zoom.\n', ...
        T, settings.rate, T ./ settings.rate);
    tPlay = tic;
    f = 1;
    frames = 1;
    while f < T
        wait = f ./ settings.rate - toc(tPlay);   % step f + 1 is due f / rate seconds in
        if wait > 0
            pause(wait);
        end
        f = min(T, max(f + 1, 1 + floor(toc(tPlay) .* settings.rate)));
        G = slam_scene_step(G, S, f);
        drawnow;
        frames = frames + 1;
    end
    fprintf('Played %d steps in %.1f s (%d frames).\n', T, toc(tPlay), frames);
end

function ok = slamCanAnimate()
    % True when drawnow can show figures while the script runs.
    ok = true;
    try
        drawnow;
    catch
        ok = false;
    end
end
