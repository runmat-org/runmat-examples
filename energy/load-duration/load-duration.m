% A year of hourly load for a utility with a 2,400 MW peak: the load-duration
% curve, the load factor and the hours the system runs near its peak.
rng(3);
h = (0:8759)';
hour = h - 24*floor(h/24);
day = (h - hour) / 24;
weekend = (day - 7*floor(day/7)) >= 5;
seasonal = 0.75 + 0.20*cos(2*pi*(h - 4900)/8760).^2;
daily = 0.85 + 0.15*sin(pi*(hour - 7)/14).^2;
load = 2400 * seasonal .* daily .* (1 - 0.08*weekend) .* (1 + 0.03*randn(8760, 1));
sorted = sort(load, 'descend');
fprintf('peak %.0f MW, load factor %.0f%%\n', sorted(1), 100*mean(load)/sorted(1));
fprintf('%d hours a year above 90%% of peak\n', sum(load > 0.9*sorted(1)));

plot((1:8760)', sorted, 'LineWidth', 2);
title('Load-duration curve');
xlabel('Hours in the year');
ylabel('Load (MW)');
