% Two weeks of hourly enclosure temperature on a time axis, with the mean of the last 24 hours
rng(3);
time = datetime(2026, 9, 1) + hours(0:24*14 - 1)';
daily = 4*sin(2*pi*(hour(time) - 9)/24);
temp = 24 + daily + 0.15*days(time - time(1)) + 0.8*randn(size(time));

TT = timetable(time, temp, 'VariableNames', {'Temp_C'});
TT.Daily_C = movmean(TT.Temp_C, [23 0]);
head(TT, 3)

[hi, k] = max(TT.Daily_C);
fprintf('Warmest 24 hours end %s at %.1f C\n', string(TT.time(k), 'yyyy-MM-dd HH:mm'), hi);

plot(TT.time, TT.Temp_C, 'LineWidth', 0.8);
hold on;
plot(TT.time, TT.Daily_C, 'LineWidth', 2.2);
hold off;
legend('Hourly reading', 'Mean of the last 24 hours', 'Location', 'northwest');
title('Enclosure temperature');
xlabel('Date');
ylabel('Temperature (C)');
grid on;
