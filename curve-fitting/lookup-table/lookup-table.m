% Refine a coarse efficiency map measured on a speed-torque grid
speed = 1000:1000:6000;                % rpm
torque = 50:50:300;                    % N m
[S, T] = meshgrid(speed, torque);
eff = 0.92 - 0.10*((S - 3200)/2800).^2 - 0.12*((T - 190)/160).^2 - 0.02*(S/6000).*(T/300);

[Sq, Tq] = meshgrid(linspace(1000, 6000, 60), linspace(50, 300, 60));
effq = interp2(S, T, eff, Sq, Tq, 'spline');
[best, k] = max(effq(:));
fprintf('Measured points: %d; refined grid: %d\n', numel(eff), numel(effq));
fprintf('Best efficiency %.3f at %.0f rpm and %.0f N m\n', best, Sq(k), Tq(k));
fprintf('At 2500 rpm and 120 N m: %.3f\n', interp2(S, T, eff, 2500, 120, 'spline'));

contourf(Sq, Tq, effq, 16);
hold on;
scatter(S(:), T(:), 22, 'k', 'filled');
hold off;
colorbar;
title('Efficiency map: 36 measurements, spline in between');
xlabel('Speed (rpm)');
ylabel('Torque (N m)');
