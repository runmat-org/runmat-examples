% Pitch attitude from flight-test IMU data: a gyro that drifts and an
% accelerometer that is noisy, combined with a two-state Kalman filter.
fs = 100;  dt = 1 / fs;
t = (0:dt:60)';
n = numel(t);
rng(3);

% Reference pitch: a climb, then a pitch doublet (deg).
pitch = 2 + 6 * (t > 8) .* (1 - exp(-(t - 8) / 3));
pitch = pitch + 5 * ((t > 30 & t < 33) - (t >= 33 & t < 36));
rate = [0; diff(pitch)] / dt;

gyro  = rate + 0.4 + 0.3 * randn(n, 1);       % deg/s, with a 0.4 deg/s bias
accel = pitch + 2.5 * randn(n, 1);            % deg, tilt from the accelerometer

% Kalman filter, state x = [pitch; gyro bias].
F = [1 -dt; 0 1];   B = [dt; 0];   H = [1 0];
Q = diag([1e-4 1e-6]);   R = 2.5^2;
x = [accel(1); 0];   P = diag([10 1]);
est = zeros(n, 1);   integ = zeros(n, 1);   integ(1) = accel(1);
for k = 2:n
    x = F * x + B * gyro(k);                  % predict with the gyro
    P = F * P * F' + Q;
    K = P * H' / (H * P * H' + R);            % correct with the accelerometer
    x = x + K * (accel(k) - H * x);
    P = (eye(2) - K * H) * P;
    est(k) = x(1);
    integ(k) = integ(k-1) + gyro(k) * dt;     % gyro alone, for comparison
end
est(1) = accel(1);

fig = figure;
plot(t(1:5:end), accel(1:5:end), 'LineWidth', 0.8, 'Color', [0.78 0.80 0.84]); hold on;
plot(t, integ, 'LineWidth', 1.6, 'Color', [0.94 0.45 0.20]);
plot(t, pitch, 'LineWidth', 1.6, 'Color', [0.55 0.58 0.65]);
plot(t, est,   'LineWidth', 2.0, 'Color', [0.31 0.55 1.00]);
legend('Accelerometer tilt', 'Gyro integrated', 'Reference', 'Kalman estimate', 'Location', 'northwest');
title('Pitch attitude from IMU data');
xlabel('Time (s)'); ylabel('Pitch (deg)');
xlim([0 60]); ylim([-10 40]);
grid on;
fprintf('pitch error (RMS), Kalman estimate: %.2f deg\n', sqrt(mean((est - pitch).^2)));
fprintf('gyro alone %.2f deg, accelerometer alone %.2f deg\n', sqrt(mean((integ - pitch).^2)), sqrt(mean((accel - pitch).^2)));
