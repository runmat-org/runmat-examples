% Tracking a target from radar range and bearing with an extended Kalman filter.
% The target flies straight, turns, then flies straight; the radar measures range to
% 15 m and bearing to 0.5 deg once a second. Constant-velocity model, state [x vx y vy].
dt = 1;  n = 120;
sr = 15;  sb = 0.5 * pi/180;
truth = zeros(n, 4);
truth(1, :) = [-20000 200 15000 0];
for k = 2:n
    s = truth(k-1, :);
    w = 0.02 * (k > 40 & k <= 80);            % 0.02 rad/s turn between 40 s and 80 s
    vx = s(2)*cos(w*dt) - s(4)*sin(w*dt);
    vy = s(2)*sin(w*dt) + s(4)*cos(w*dt);
    truth(k, :) = [s(1) + vx*dt, vx, s(3) + vy*dt, vy];
end
rng(5);
rho_m = sqrt(truth(:,1).^2 + truth(:,3).^2) + sr*randn(n, 1);
bearing_m = atan2(truth(:,3), truth(:,1)) + sb*randn(n, 1);
z = horzcat(rho_m, bearing_m);
mx = rho_m .* cos(bearing_m);
my = rho_m .* sin(bearing_m);
meas = horzcat(mx, my);

F = [1 dt 0 0; 0 1 0 0; 0 0 1 dt; 0 0 0 1];
qa = 3;                                      % process noise, m/s^2
G = [dt^2/2 0; dt 0; 0 dt^2/2; 0 dt];
Q = G * (qa^2 * eye(2)) * G';
R = diag([sr^2 sb^2]);
x = [meas(1,1); 0; meas(1,2); 0];
P = diag([sr^2 300^2 sr^2 300^2]);
est = zeros(n, 4);  est(1, :) = x';
for k = 2:n
    x = F * x;  P = F * P * F' + Q;
    rho = sqrt(x(1)^2 + x(3)^2);
    h = [rho; atan2(x(3), x(1))];
    Hk = [x(1)/rho 0 x(3)/rho 0; -x(3)/rho^2 0 x(1)/rho^2 0];
    innov = z(k, :)' - h;
    innov(2) = atan2(sin(innov(2)), cos(innov(2)));
    S = Hk * P * Hk' + R;
    K = P * Hk' / S;
    x = x + K * innov;
    P = (eye(4) - K * Hk) * P;
    est(k, :) = x';
end

plot(meas(:,1)/1000, meas(:,2)/1000, '.', est(:,1)/1000, est(:,3)/1000, truth(:,1)/1000, truth(:,3)/1000);
legend('Measurements', 'Track', 'Truth');
title('Extended Kalman filter track');
xlabel('East (km)');
ylabel('North (km)');

settled = 11:n;
err_meas = sqrt(mean(sum((meas(settled,:) - truth(settled,[1 3])).^2, 2)));
err_track = sqrt(mean(sum((est(settled,[1 3]) - truth(settled,[1 3])).^2, 2)));
err_v = sqrt(mean(sum((est(settled,[2 4]) - truth(settled,[2 4])).^2, 2)));
fprintf('position error %.0f m from single measurements, %.0f m from the track\n', err_meas, err_track);
fprintf('velocity error %.1f m/s, through a 0.02 rad/s turn\n', err_v);
