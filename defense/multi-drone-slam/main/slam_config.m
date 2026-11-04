function cfg = slam_config(steps)
% SLAM_CONFIG  Parameters of the multi-drone SLAM run.
%
%   cfg = slam_config(steps) returns a struct with the world size, drone
%   count, route shape, place-recognition and event timing, LIDAR fan and
%   coverage grid settings for a run of the given number of steps.

    cfg.L = 512;                 % world size, m
    cfg.M = 256;                 % heightfield cells per side
    cfg.D = 4;                   % drones
    cfg.T = steps;               % simulation steps
    cfg.petal = 140;             % steps per petal: out into new ground and back past the launch area
    cfg.petalReach = 215;        % petal tip distance from the launch area, m
    cfg.petalWidth = 0.2;        % half-angle between a petal's outbound and return legs, rad
    cfg.petalTurn = 25;          % each new petal turns this far into new ground, degrees
    cfg.stagger = 6;             % steps between the drones' passes through the launch area
    cfg.closeRange = 15;         % place-recognition range: a pose this close to mapped track closes a loop, m
    cfg.minAge = 60;             % own track must be this many steps old to count as mapped
    cfg.eventWindow = 22;        % steps from an event's first detection to its pose-graph solve
    cfg.refractory = 60;         % steps after a solve before a new event can open
    cfg.snapFrames = 12;         % steps over which the map blends to the solved poses
    cfg.nAz = 72;                % LIDAR azimuths per revolution
    cfg.nEl = 16;                % LIDAR beams
    cfg.dt = 2.0;                % ray-march step, m
    cfg.nMarch = 110;            % march samples, so 220 m range
    cfg.keepPerDrone = 55;       % map points kept per drone per step
    cfg.showPerDrone = 24;       % rays drawn per drone per step
    cfg.covN = 256;              % coverage grid cells per side (2 m)
end
