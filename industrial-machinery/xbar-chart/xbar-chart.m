% X-bar chart for a bore diameter: 25 subgroups of 5 parts, limits set from the first
% 15 subgroups, and a 6 micrometre shift in the process from subgroup 18 on.
rng(4);
bore = 25.000 + 0.004*randn(25, 5);
bore(18:25, :) = bore(18:25, :) + 0.006;
xbar = mean(bore, 2);  range = max(bore, [], 2) - min(bore, [], 2);
A2 = 0.577;                                    % for subgroups of 5
center = mean(xbar(1:15));  Rbar = mean(range(1:15));
ucl = center + A2*Rbar;  lcl = center - A2*Rbar;
out = find(xbar > ucl | xbar < lcl);
fprintf('control limits %.4f to %.4f mm\n', lcl, ucl);
fprintf('first subgroup out of control: %d of 25\n', out(1));

um = @(v) 1000*(v - 25);                       % deviation from 25 mm, in micrometres
plot(1:25, um(xbar), '-o');
hold on;
plot([1 25], [um(ucl) um(ucl)], '--');
plot([1 25], [um(center) um(center)], ':');
plot([1 25], [um(lcl) um(lcl)], '--');
title('X-bar chart, bore diameter');
xlabel('Subgroup');
ylabel('Deviation from 25 mm (um)');
