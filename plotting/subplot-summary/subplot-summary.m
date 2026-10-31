rng(2);
t = 0:0.01:10;
speed = 30*(1 - exp(-0.6*t)) + 0.6*randn(size(t));
temp = 20 + 1.8*t + 1.5*sin(0.8*t);

subplot(2, 2, 1);
plot(t, speed);
title('Shaft speed');
xlabel('Time (s)');
ylabel('rad/s');

subplot(2, 2, 2);
plot(t, temp, 'LineWidth', 1.5);
title('Bearing temperature');
xlabel('Time (s)');
ylabel('°C');

subplot(2, 2, 3);
histogram(speed(t > 5), 25);
title('Speed after 5 s');
xlabel('rad/s');
ylabel('Count');

subplot(2, 2, 4);
scatter(speed(1:20:end), temp(1:20:end), 18, t(1:20:end), 'filled');
title('Temperature against speed');
xlabel('rad/s');
ylabel('°C');

sgtitle('Run 14 summary');
