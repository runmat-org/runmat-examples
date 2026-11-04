% Multi-drone SLAM over unknown terrain: plays the saved run
%
% Four drones fly long routes over procedural mountain terrain, out into new
% ground and back past their launch area. Each spins a LIDAR fan (16 beams x
% 72 azimuths), marches every ray against the heightfield and adds the hits
% to a shared point-cloud map through its own odometry, which drifts. When a
% drone comes back within range of mapped track (its own or another
% drone's), it detects a loop closure; the pose graph of every drone is then
% re-solved with sparse least squares and the map snaps into alignment.
%
% This entry point plays results/slam_run.mat when that file was saved from
% the current simulation code and step count. When the code or the step
% count has changed, or the file is missing, it simulates first (with
% progress in the console), saves the new run and then plays it.
% simulate_slam.m always simulates.
%
% Playback runs at settings.rate steps per second. Drag figure 1 to orbit the
% map and scroll to zoom while the drones fly. Figure 2 shows each drone's
% position error and figure 3 the share of the terrain mapped; a dotted
% "sync" line in both marks each pose-graph solve.
%
% Settings live in slam_settings.m and model parameters in slam_config.m.

settings = slam_settings();
S = slam_results(settings.steps, false);
slam_play(S, settings);
