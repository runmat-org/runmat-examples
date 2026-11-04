function key = slam_run_key(root, steps)
% SLAM_RUN_KEY  Key of a SLAM run: a checksum of its code and step count.
%
%   key = slam_run_key(root, steps) reads every file that decides the
%   simulation's result (main/slam_config.m, main/slam_simulate.m and the
%   .m files in terrain/, flight/, sensors/ and slam/ under root) and
%   returns a 20-digit checksum of their names, their text and steps. A
%   change to any of them changes the key, and multi_drone_slam.m then
%   simulates again instead of playing results/slam_run.mat. The graphics/
%   and playback/ folders and the playback settings in slam_settings.m are
%   left out: changing how the run is drawn never needs a new simulation.
%
%   Each file's name and text get two checksums mod 2^31 - 1 over their
%   character codes, and the key adds them up mod 2^31 - 1, so the order
%   dir lists the files in does not matter. All of it is exact integer
%   arithmetic, so the key is the same on every machine. Carriage returns
%   are dropped first, so a file saved with Windows line endings keeps its
%   key.

    files = {'main/slam_config.m', 'main/slam_simulate.m'};
    folders = {'terrain', 'flight', 'sensors', 'slam'};
    for k = 1:numel(folders)
        listing = dir(fullfile(root, folders{k}, '*.m'));
        for n = 1:numel(listing)
            files{end + 1} = [folders{k} '/' listing(n).name];
        end
    end
    p = 2147483647;
    [h1, h2] = slamTextHash(sprintf('steps=%d', steps), p);
    for k = 1:numel(files)
        [a, b] = slamTextHash([files{k} char(0) fileread(fullfile(root, files{k}))], p);
        h1 = mod(h1 + a, p);
        h2 = mod(h2 + b, p);
    end
    key = sprintf('%010d%010d', h1, h2);
end

function [h1, h2] = slamTextHash(text, p)
    % Character codes go mod 251 into a 64-row matrix, one column per 64
    % characters. Each column is summed against two sets of row weights; the
    % column sums stay below 2^24, so the vector part is exact even in single
    % precision. The column sums then feed two polynomial hashes mod p in a
    % loop over the columns.
    codes = reshape(mod(double(text(text ~= char(13))), 251), 1, []);
    n = numel(codes);
    cols = max(1, ceil(n ./ 64));
    M = reshape([codes, zeros(1, cols .* 64 - n)], 64, cols);
    rows = (1:64)';
    s1 = sum(M .* (mod(rows .* 37, 251) + 1), 1);
    s2 = sum(M .* (mod(rows .* 101, 241) + 1), 1);
    h1 = n;
    h2 = n;
    for k = 1:cols
        h1 = mod(h1 .* 31 + s1(k), p);
        h2 = mod(h2 .* 131 + s2(k), p);
    end
end
