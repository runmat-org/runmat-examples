% Multi-drone SLAM: simulates, saves the run, then plays it
%
% Runs the whole simulation from scratch (terrain, routes, odometry, LIDAR,
% loop closures and pose-graph solves) with progress in the console, saves
% the result to results/slam_run.mat and plays it. multi_drone_slam.m plays
% that file afterwards without simulating, as long as the simulation code
% and the step count stay the same.

settings = slam_settings();
S = slam_results(settings.steps, true);
slam_play(S, settings);
