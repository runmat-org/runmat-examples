function [epochs, info] = solve_pose_graph(cfg, truth, odo, loops)
% SOLVE_POSE_GRAPH  Pose-graph back end: one sparse least-squares solve per event.
%
%   [epochs, info] = solve_pose_graph(cfg, truth, odo, loops) returns
%   epochs, D x T x 3 x (events + 1). Epoch 1 is dead reckoning from the
%   known launch poses. Epoch e+1 is the estimate after event e: every pose
%   up to the solve step from the pose graph, dead reckoning after it.
%   info(e, :) is [nodes, edges, loop closures, nonzeros of the normal
%   matrix] for event e. Each closure is measured as a scan matcher would
%   report it: the true relative pose plus 0.25 m and 0.003 rad of noise.

    D = cfg.D;
    T = cfg.T;
    nEvents = numel(loops.eventSolve);
    epochs = zeros(D, T, 3, nEvents + 1);
    epochs(:, :, :, 1) = dead_reckon(odo, squeeze(truth(:, 1, [1 2 4])), 1, T);
    info = zeros(nEvents, 4);
    for e = 1:nEvents
        te = loops.eventSolve(e);
        [poses, info(e, :)] = solveGraphAt(cfg, truth, odo, loops, te);
        est = epochs(:, :, :, e);
        est(:, 1:te, :) = poses;
        after = dead_reckon(odo, squeeze(poses(:, te, :)), te, T);
        est(:, te:T, :) = after(:, te:T, :);
        epochs(:, :, :, e + 1) = est;
    end
end

function [poses, info] = solveGraphAt(cfg, truth, odo, loops, te)
    % Nodes: every pose of every drone up to step te. Edges: odometry between
    % consecutive poses and every loop closure detected so far. Two linear
    % least-squares stages share the sparse incidence matrix A (one row per
    % edge, +1 at pose j and -1 at pose i, plus one anchor row per drone):
    %   1. headings:  A * yaw = measured relative headings
    %   2. positions: A * x = measured displacements rotated by the solved
    %      headings, and the same for y.
    % Each stage solves the sparse weighted normal equations with \.
    D = cfg.D;
    T = cfg.T;
    nNode = D .* te;
    first = (0:D-1)' .* te;
    oi = reshape(first + (1:te-1), [], 1);
    oj = oi + 1;
    ox = reshape(odo(:, 2:te, 1), [], 1);
    oy = reshape(odo(:, 2:te, 2), [], 1);
    oth = reshape(odo(:, 2:te, 3), [], 1);

    use = loops.step <= te;
    gi = loops.i(use);
    gj = loops.j(use);
    di = loops.nodeDrone(gi);
    si = loops.nodeStep(gi);
    dj = loops.nodeDrone(gj);
    sj = loops.nodeStep(gj);
    TX = truth(:, :, 1)';                     % T x D, so node (d-1)*T + t indexes it
    TY = truth(:, :, 2)';
    TYaw = truth(:, :, 4)';
    nLC = numel(gi);
    cI = cos(TYaw(gi));
    sI = sin(TYaw(gi));
    lx = cI .* (TX(gj) - TX(gi)) + sI .* (TY(gj) - TY(gi)) + 0.25 .* randn(nLC, 1);
    ly = -sI .* (TX(gj) - TX(gi)) + cI .* (TY(gj) - TY(gi)) + 0.25 .* randn(nLC, 1);
    lth = TYaw(gj) - TYaw(gi) + 0.003 .* randn(nLC, 1);
    I = [oi; (di - 1) .* te + si];
    J = [oj; (dj - 1) .* te + sj];
    nE = numel(I);
    isLoop = [false(numel(oi), 1); true(nLC, 1)];
    anchor = first + 1;

    A = sparse([(1:nE)'; (1:nE)'; nE + (1:D)'], [J; I; anchor], ...
        [ones(nE, 1); -ones(nE, 1); ones(D, 1)], nE + D, nNode);
    sigmaTh = 0.0008 + 0.0022 .* isLoop;
    wTh = [1 ./ sigmaTh; 1000 .* ones(D, 1)] .^ 2;
    yawOpt = (A' * (A .* wTh)) \ (A' * (wTh .* [oth; lth; TYaw(1, :)']));

    c = cos(yawOpt(I));
    sn = sin(yawOpt(I));
    mx = [ox; lx];
    my = [oy; ly];
    bx = c .* mx - sn .* my;
    by = sn .* mx + c .* my;
    sigma = 0.05 + 0.25 .* isLoop;
    wP = [1 ./ sigma; 1000 .* ones(D, 1)] .^ 2;
    N = A' * (A .* wP);
    pxOpt = N \ (A' * (wP .* [bx; TX(1, :)']));
    pyOpt = N \ (A' * (wP .* [by; TY(1, :)']));
    info = [nNode, nE, nLC, nnz(N)];
    poses = zeros(D, te, 3);
    poses(:, :, 1) = reshape(pxOpt, te, D)';
    poses(:, :, 2) = reshape(pyOpt, te, D)';
    poses(:, :, 3) = reshape(yawOpt, te, D)';
end
