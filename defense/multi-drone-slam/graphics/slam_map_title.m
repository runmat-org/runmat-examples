function t = slam_map_title(coverage)
% SLAM_MAP_TITLE  Title of the playback map, with the share of terrain mapped.
%
%   t = slam_map_title(coverage) returns the title slam_scene draws and
%   slam_scene_step updates, for coverage in percent. RunMat 0.7.0 RC draws
%   a 3D title in a fixed 28 px band and clips a large one at the top; the
%   empty first line gives it room.

    t = sprintf('\nDrones scanning terrain: %.0f%% mapped', coverage);
end
