% Multi-drone SLAM over unknown terrain: plays the saved run.
% Four drones map mountains with LIDAR while their odometry drifts; loop
% closures re-solve every pose and the map snaps into place. See README.md.
% Simulates first when results/slam_run.mat is missing or out of date.

settings = slam_settings();
S = slam_results(settings.steps, false);
slam_play(S, settings);
