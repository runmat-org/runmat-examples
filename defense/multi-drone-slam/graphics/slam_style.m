function style = slam_style(light)
% SLAM_STYLE  Colors for slam_draw in the dark or light theme.
%
%   style = slam_style(light) returns style.drone (one RGB row per drone),
%   style.wire (terrain wireframe), style.grid (ground grid), style.truth
%   (true paths), style.ray (LIDAR rays) and style.mark (sync markers), for
%   the light theme when light is true and the dark theme otherwise.

    if light
        style.drone = [0.90 0.36 0.02; 0.80 0.12 0.50; 0.02 0.50 0.78; 0.30 0.62 0.05];
        style.wire = [0.80 0.82 0.86];
        style.grid = [0.86 0.88 0.91];
        style.truth = [0.45 0.47 0.52];
        style.ray = [0.70 0.75 0.84];
        style.mark = [0.44 0.46 0.50];
    else
        style.drone = [0.98 0.45 0.12; 0.93 0.27 0.62; 0.20 0.78 0.95; 0.62 0.90 0.25];
        style.wire = [0.24 0.27 0.32];
        style.grid = [0.20 0.23 0.27];
        style.truth = [0.62 0.65 0.70];
        style.ray = [0.36 0.44 0.56];
        style.mark = [0.56 0.59 0.64];
    end
end
