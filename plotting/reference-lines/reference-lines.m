time = 0:0.25:12;
temperature = 62 + 1.4*time + 5*sin(0.55*time).*exp(-0.08*time);

plot(time, temperature, 'LineWidth', 2);
xline(6, '--', 'Control change', 'LineWidth', 1.5);
yline(76, ':r', 'Alarm limit', 'LineWidth', 1.5);
title('Temperature During Test Run');
xlabel('Time (min)');
ylabel('Temperature (C)');
ylim([60 80]);
grid on;
