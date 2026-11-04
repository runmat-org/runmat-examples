function settings = slam_settings()
% SLAM_SETTINGS  Settings both entry points share.
%
%   settings = slam_settings() returns:
%     settings.steps     simulation steps: one correction lands near step
%                        156, then one every 140 steps (the home-page video
%                        runs 480)
%     settings.rate      playback speed, simulation steps per second
%     settings.light     true draws with the light-theme palette
%     settings.fontSize  title size; axis labels and ticks scale from it
%
%   steps is part of the saved run's key: changing it makes
%   multi_drone_slam.m simulate again. rate, light and fontSize only change
%   the playback.

    settings.steps = 180;
    settings.rate = 15;
    settings.light = false;
    settings.fontSize = 18;
end
