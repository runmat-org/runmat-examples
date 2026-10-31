% Fill dropouts and replace spikes in a sampled temperature trace
rng(9);
t = (0:299)';
x = 20 + 3*sin(2*pi*t/120) + 0.3*randn(size(t));
x([40 41 42 150 220]) = NaN;          % dropouts
x([75 190 260]) = [45 -10 60];        % spikes

filled = fillmissing(x, 'linear');
isSpike = isoutlier(filled, 'movmedian', 15);
clean = filloutliers(filled, 'linear', 'movmedian', 15);
smooth = movmean(clean, 9);
fprintf('%d dropouts filled, %d spikes replaced\n', sum(ismissing(x)), sum(isSpike));

subplot(2, 1, 1);
plot(t, x, 'LineWidth', 1);
title('Raw trace: dropouts and spikes');
xlabel('Sample');
ylabel('Temperature (C)');
grid on;

subplot(2, 1, 2);
plot(t, clean, 'LineWidth', 1);
hold on;
plot(t, smooth, 'LineWidth', 2);
hold off;
legend('cleaned', '9-sample moving mean');
title('Cleaned trace');
xlabel('Sample');
ylabel('Temperature (C)');
grid on;
