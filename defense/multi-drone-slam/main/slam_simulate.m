function S = slam_simulate(steps)
% SLAM_SIMULATE  Multi-drone LIDAR SLAM over procedural mountain terrain.
%
%   S = slam_simulate(steps) flies four drones for the given number of steps
%   and returns everything the figures need: the configuration, terrain,
%   true and estimated trajectories, map points, drawn rays, coverage, sync
%   events, each drone's position error and the run report (S.report). It
%   prints a progress line per stage while it runs. The home-page video uses
%   480 steps (16 s at 30 frames per second).
%
% The stages run in this order, each in its own file:
%   slam_config      parameters
%   make_terrain     procedural mountain heightfield
%   fly_routes       true petal-shaped routes
%   make_odometry    drifting odometry (dead_reckon integrates it)
%   cast_lidar       LIDAR scans, map points and coverage
%   detect_closures  loop closures and sync events
%   solve_pose_graph sparse least-squares pose-graph solve per event
%
% Every random draw comes from rng(20261103), in the stage order above: the
% same steps give the same run.
%
% RunMat 0.7.0 RC workarounds kept in these files:
%   - scalar division is written ./ (sin(X/15) fails with
%     RunMat:Placement:InvalidDecision);
%   - the work lives in short functions (a long body fails with
%     RunMat:CallableArtifact:ExecutableProduct);
%   - every function name, including local functions, is unique across the
%     project (two files with a same-named local function fail with
%     RunMat:ExecutableSourceIdentity);
%   - shapes inside the per-step loops stay fixed from step to step;
%   - a missed ray is NaN in x, y and z (partial NaN breaks plot3 bounds).

    rng(20261103);
    tStart = tic;
    cfg = slam_config(steps);
    terrain = make_terrain(cfg);
    simProgress(tStart, 'terrain built');
    truth = fly_routes(cfg);
    odo = make_odometry(cfg, truth);
    simProgress(tStart, 'routes and odometry done');
    scan = cast_lidar(cfg, terrain, truth, tStart);
    loops = detect_closures(cfg, truth);
    simProgress(tStart, sprintf('%d loop closures detected', numel(loops.i)));
    [epochs, solveInfo] = solve_pose_graph(cfg, truth, odo, loops);
    simProgress(tStart, sprintf('%d pose-graph solves done', numel(loops.eventSolve)));
    errShown = shownError(cfg, truth, epochs, loops.eventSolve);
    runSeconds = toc(tStart);
    report = reportRun(cfg, scan, loops, solveInfo, epochs, truth, runSeconds);
    fprintf('%s', report);
    S = packResults(cfg, terrain, truth, epochs, scan, loops, errShown, runSeconds);
    S.report = report;
end

function simProgress(tStart, what)
    % One progress line per stage, with the time since the run started.
    fprintf('[%5.1f s] %s\n', toc(tStart), what);
end

function errShown = shownError(cfg, truth, epochs, eventSolve)
    % Position error of the estimate the video shows at each step.
    errShown = zeros(cfg.D, cfg.T);
    for f = 1:cfg.T
        est = slam_estimate(epochs, eventSolve, cfg.snapFrames, f);
        errShown(:, f) = sqrt((est(:, f, 1) - truth(:, f, 1)) .^ 2 + (est(:, f, 2) - truth(:, f, 2)) .^ 2);
    end
end

function report = reportRun(cfg, scan, loops, info, epochs, truth, runSeconds)
    % The run summary as text: slam_simulate prints it, and playback prints
    % it again from the saved run.
    report = sprintf('terrain %dx%d, %d drones, %d steps\n', cfg.M + 1, cfg.M + 1, cfg.D, cfg.T);
    report = [report sprintf('rays cast %d (%d per step, %d march samples each), hits %d\n', ...
        scan.raysCast, cfg.D .* cfg.nAz .* cfg.nEl, cfg.nMarch, scan.hits)];
    report = [report sprintf('map points %d\n', sum(scan.valid))];
    report = [report sprintf('loop closures %d in %d events\n', numel(loops.i), numel(loops.eventSolve))];
    for e = 1:numel(loops.eventSolve)
        te = loops.eventSolve(e);
        before = epochs(:, te, :, e);
        after = epochs(:, te, :, e + 1);
        errBefore = mean(sqrt((before(:, 1, 1) - truth(:, te, 1)) .^ 2 + (before(:, 1, 2) - truth(:, te, 2)) .^ 2));
        errAfter = mean(sqrt((after(:, 1, 1) - truth(:, te, 1)) .^ 2 + (after(:, 1, 2) - truth(:, te, 2)) .^ 2));
        report = [report sprintf('event %d: opened step %d, solved step %d, %d nodes, %d edges (%d closures), mean error %.1f m -> %.2f m\n', ...
            e, loops.eventOpen(e), te, info(e, 1), info(e, 2), info(e, 3), errBefore, errAfter)];
    end
    report = [report sprintf('coverage %.1f %% at the end\n', scan.coverage(cfg.T))];
    report = [report sprintf('simulation time %.1f s\n', runSeconds)];
end

function S = packResults(cfg, terrain, truth, epochs, scan, loops, errShown, runSeconds)
    S.cfg = cfg;
    S.H = terrain.H;
    S.gx = terrain.gx;
    S.truth = truth;
    S.epochs = epochs;
    S.eventOpen = loops.eventOpen;
    S.eventSolve = loops.eventSolve;
    S.pings = loops.pings;
    keepRows = find(scan.valid);
    S.ptBody = scan.body(keepRows, :);
    S.ptDrone = scan.drone(keepRows);
    S.ptStep = scan.step(keepRows);
    S.rays = scan.rays;
    S.coverage = scan.coverage;
    S.errShown = errShown;
    S.runSeconds = runSeconds;
end
