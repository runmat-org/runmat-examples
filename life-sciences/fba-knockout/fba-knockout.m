% Flux balance analysis of a small metabolic network, then single-reaction knockouts:
% which reactions the cell can lose and still grow, and how much growth it keeps.
% Reactions: 1 glucose uptake, 2 oxygen uptake, 3 glycolysis, 4 respiration,
% 5 fermentation, 6 biomass. Metabolites: glucose, oxygen, pyruvate, ATP.
S = [ 1  0 -1  0  0   0;     % glucose
      0  1  0 -1  0   0;     % oxygen
      0  0  2 -1 -1  -1;     % pyruvate
      0  0  2 14  1 -10];    % ATP
c = [0 0 0 0 0 -1]';         % maximize biomass
lb = zeros(6, 1);  ub = [10; 20; 1000; 1000; 1000; 1000];
[~, fval] = linprog(c, [], [], S, zeros(4, 1), lb, ub);
wild = -fval;
names = {'glucose', 'oxygen', 'glycolysis', 'respiration', 'fermentation'};
kept = zeros(1, 5);
for r = 1:5
    ko = ub;  ko(r) = 0;
    [~, fk] = linprog(c, [], [], S, zeros(4, 1), lb, ko);
    kept(r) = 100 * max(0, -fk) / wild;
end
fprintf('wild-type growth %.2f per hour\n', wild);
fprintf('growth: %.0f%% without respiration, %.0f%% without glucose\n', kept([4 1]));

bar(1:5, kept);
xticks(1:5);
xticklabels(names);
title('Growth kept after each knockout');
ylabel('Growth (% of wild type)');
