% A rig log as exported: two preamble lines, a units row, "N/A" markers,
% a thousands separator and two timestamp formats
raw = readtable('rig_log.csv');                 % defaults take the preamble as the header
fprintf('Defaults: %s\n', strjoin(raw.Properties.VariableNames, ', '));

% Say where the names, units and data are, and how the numbers are written
opts = detectImportOptions('rig_log.csv', 'NumHeaderLines', 2);
opts.VariableNamesLine = 3;
opts.VariableUnitsLine = 4;
opts.DataLines = [5 Inf];
opts = setvartype(opts, {'Force_N', 'Temp_C'}, 'double');
opts = setvartype(opts, 'Timestamp', 'string');
opts = setvaropts(opts, {'Force_N', 'Temp_C'}, 'TreatAsMissing', 'N/A');
opts = setvaropts(opts, 'Force_N', 'ThousandsSeparator', ',');
T = readtable('rig_log.csv', opts);

% Two timestamp formats: parse one, then the rows it could not read
t = datetime(T.Timestamp, 'InputFormat', 'yyyy-MM-dd HH:mm');
other = ismissing(t);
t(other) = datetime(T.Timestamp(other), 'InputFormat', 'dd/MM/yyyy HH:mm');
T.Timestamp = t;
T.Timestamp.Format = 'yyyy-MM-dd HH:mm';

fprintf('%d rows; %d force readings missing; units %s\n', height(T), ...
    sum(ismissing(T.Force_N)), strjoin(T.Properties.VariableUnits(3:4), ', '));
head(T, 4)
writetable(T, 'rig_clean.csv');

% Force through the shift, one line per fixture
hold on;
for f = ["A" "B" "C"]
    rows = T.Fixture == f;
    plot(T.Timestamp(rows), T.Force_N(rows), 'o-', 'LineWidth', 1.2);
end
hold off;
legend('Fixture A', 'Fixture B', 'Fixture C', 'Location', 'northwest');
title('Rig 3 load log, read correctly');
xlabel('Time');
ylabel('Force (N)');
grid on;
