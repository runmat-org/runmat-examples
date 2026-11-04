function S = slam_results(steps, recompute)
% SLAM_RESULTS  The SLAM run for playback: the saved one, or a new one.
%
%   S = slam_results(steps, recompute) returns the run slam_play draws.
%   With recompute false it loads results/slam_run.mat when the key saved in
%   it matches slam_run_key for the current code and step count. Otherwise,
%   or with recompute true, it runs slam_simulate(steps), stores the key in
%   S.key, saves S to results/slam_run.mat and returns it.

    root = slamProjectRoot();
    file = fullfile(root, 'results', 'slam_run.mat');
    key = slam_run_key(root, steps);
    if ~recompute
        [S, why] = loadSavedRun(file, key);
        if isempty(why)
            fprintf('Playing the saved run from results/slam_run.mat (key %s).\n', key);
            fprintf('Run simulate_slam.m to simulate it again.\n\n');
            fprintf('%s', S.report);
            return;
        end
        fprintf('%s: simulating %d steps first.\n', why, steps);
    end
    S = slam_simulate(steps);
    S.key = key;
    saveRun(root, file, S);
    fprintf('Saved the run to results/slam_run.mat (key %s).\n', key);
end

function root = slamProjectRoot()
    % The project folder: two levels up from this file, else the current
    % folder.
    root = fileparts(fileparts(mfilename('fullpath')));
    if isempty(root) || ~isfolder(fullfile(root, 'terrain'))
        root = pwd;
    end
end

function [S, why] = loadSavedRun(file, key)
    % The saved run, or an empty S and the reason it can't be used.
    S = [];
    why = '';
    if ~isfile(file)
        why = 'No saved run in results/slam_run.mat';
        return;
    end
    try
        data = load(file);
    catch
        why = 'results/slam_run.mat could not be read';
        return;
    end
    if ~isfield(data, 'S') || ~isfield(data.S, 'key')
        why = 'results/slam_run.mat holds no SLAM run';
    elseif ~strcmp(data.S.key, key)
        why = sprintf('The simulation code or step count changed since results/slam_run.mat was saved (key %s, now %s)', data.S.key, key);
    else
        S = data.S;
    end
end

function saveRun(root, file, S)
    if ~isfolder(fullfile(root, 'results'))
        mkdir(fullfile(root, 'results'));
    end
    save(file, 'S');
end
