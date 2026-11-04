function loops = detect_closures(cfg, truth)
% DETECT_CLOSURES  Place recognition: loop closures and sync events.
%
%   loops = detect_closures(cfg, truth) walks the run step by step. Each
%   drone compares its pose with every mapped pose: another drone's track up
%   to now, or its own track at least minAge steps old. A match within
%   closeRange is a loop closure. Closures group into events: the first
%   detection after the refractory period opens an event, and the event's
%   pose-graph solve runs eventWindow steps later. Each drone pings at its
%   first detection in an event; its partner is the first other drone it
%   matched, else itself. Returns:
%     loops.i, loops.j, loops.step   closure edges (node indices, step)
%     loops.eventOpen, loops.eventSolve   event open and solve steps
%     loops.pings     rows of [step, drone, partner drone]
%     loops.nodeDrone, loops.nodeStep   drone and step of node (d-1)*T + t

    D = cfg.D;
    T = cfg.T;
    X = reshape(truth(:, :, 1)', [], 1);       % node (d, t) is (d-1)*T + t
    Y = reshape(truth(:, :, 2)', [], 1);
    nodeDrone = reshape(repmat(1:D, T, 1), [], 1);
    nodeStep = repmat((1:T)', D, 1);
    maxEdges = 2 .* D .* T;
    ci = zeros(maxEdges, 1);
    cj = zeros(maxEdges, 1);
    cstep = zeros(maxEdges, 1);
    nEdge = 0;
    eventOpen = zeros(1, 0);
    eventSolve = zeros(1, 0);
    pings = zeros(0, 3);                       % step, drone, partner drone
    lastSolve = -1e9;
    openAt = 0;
    pinged = false(D, 1);
    partner = zeros(D, 1);
    pingStep = zeros(D, 1);
    for t = 1:T
        if openAt > 0 && t == openAt + cfg.eventWindow
            eventSolve(end + 1) = t; %#ok<AGROW>
            lastSolve = t;
            for d = 1:D
                if pinged(d)
                    pings(end + 1, :) = [pingStep(d), d, partner(d)]; %#ok<AGROW>
                end
            end
            openAt = 0;
        end
        for d = 1:D
            node = (d - 1) .* T + t;
            mapped = nodeStep <= t & (nodeDrone ~= d | nodeStep <= t - cfg.minAge);
            dist = sqrt((X - X(node)) .^ 2 + (Y - Y(node)) .^ 2);
            dist(~mapped) = Inf;
            [best, j] = min(dist);
            dist(nodeDrone == d) = Inf;
            [bestOther, jOther] = min(dist);
            % No closures in the first minAge steps, while the drones leave the launch area together.
            if best < cfg.closeRange && mod(t, 2) == 0 && t > cfg.minAge
                nEdge = nEdge + 1;
                ci(nEdge) = j;
                cj(nEdge) = node;
                cstep(nEdge) = t;
                if bestOther < cfg.closeRange && jOther ~= j
                    % A match on another drone's map too: the drones share it.
                    nEdge = nEdge + 1;
                    ci(nEdge) = jOther;
                    cj(nEdge) = node;
                    cstep(nEdge) = t;
                end
                if openAt == 0 && t > lastSolve + cfg.refractory
                    openAt = t;
                    eventOpen(end + 1) = t; %#ok<AGROW>
                    pinged(:) = false;
                    partner(:) = 0;
                end
                if openAt > 0
                    if ~pinged(d)
                        pinged(d) = true;
                        pingStep(d) = t;
                        partner(d) = d;
                    end
                    if partner(d) == d && bestOther < cfg.closeRange
                        partner(d) = nodeDrone(jOther);
                    end
                end
            end
        end
    end
    loops.i = ci(1:nEdge);
    loops.j = cj(1:nEdge);
    loops.step = cstep(1:nEdge);
    loops.eventOpen = eventOpen;
    loops.eventSolve = eventSolve;
    loops.pings = pings;
    loops.nodeDrone = nodeDrone;
    loops.nodeStep = nodeStep;
end
