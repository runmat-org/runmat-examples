% Rig 3 load log: mean force for each fixture in each hour of the shift
T = rmmissing(readtable('rig_clean.csv'));
T = T(~isoutlier(T.Force_N), :);
T.Hour = hour(T.Timestamp);

P = pivot(T, Rows = 'Fixture', Columns = 'Hour', DataVariable = 'Force_N', Method = 'mean')

h = heatmap(T, 'Hour', 'Fixture', 'ColorVariable', 'Force_N', 'ColorMethod', 'mean');
h.Title = 'Mean force by fixture and hour (N)';
h.XLabel = 'Hour of day';
h.YLabel = 'Fixture';
