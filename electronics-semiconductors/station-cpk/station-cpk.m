% Capability of one test (a 3.30 V rail, limits 3.15 to 3.45 V) across six test
% stations. One station reads high; its Cpk drops below the others.
rng(2);
station = repmat((1:6)', 400, 1);
offset = [0 0.02 -0.01 0.08 0 0.03]';
volts = 3.30 + offset(station) + 0.04*randn(numel(station), 1);
T = table(station, volts, 'VariableNames', {'station', 'volts'});
LSL = 3.15;  USL = 3.45;
mu = accumarray(T.station, T.volts, [], @mean);
sd = accumarray(T.station, T.volts, [], @std);
cpk = min((USL - mu) ./ (3*sd), (mu - LSL) ./ (3*sd));
[worst, k] = min(cpk);
fprintf('station %d has Cpk %.2f; the other stations range %.2f to %.2f\n', k, worst, min(cpk(cpk > worst)), max(cpk));
fprintf('station %d reads %.0f mV high against the mean of the rest\n', k, 1000*(mu(k) - mean(mu(cpk > worst))));

bar(1:6, cpk);
yline(1.33);
ylim([0 1.6]);
title('Cpk of the 3.3 V rail by test station');
xlabel('Station');
ylabel('Cpk');
