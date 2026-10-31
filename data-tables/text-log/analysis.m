% Pull the level and the load out of each line of a controller log, then count by level
lines = readlines('controller.log');
lines = lines(strlength(lines) > 0);

tok = regexp(lines, '\[(\w+)\].*load=([\d.]+)', 'tokens', 'once');
tok = vertcat(tok{:});
level = categorical(tok(:, 1), {'INFO', 'WARN', 'ERROR'});
loadN = str2double(tok(:, 2));
fprintf('%d lines; mean load %.1f; max load %.1f\n', numel(lines), mean(loadN), max(loadN));

[counts, names] = groupcounts(level)
warnLoad = mean(loadN(level == 'WARN'));
fprintf('Mean load on WARN lines: %.1f\n', warnLoad);

bar(counts, 0.6);
xticks(1:numel(names));
xticklabels(string(names));
title('Controller log lines by level');
xlabel('Level');
ylabel('Lines');
grid on;
