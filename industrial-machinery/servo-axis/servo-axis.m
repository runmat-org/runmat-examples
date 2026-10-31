% A linear axis on a servo motor: PI velocity loop inside a P position loop, then a
% 10 mm step. Inertia and damping referred to the motor; gains from a first tuning pass.
J = 2e-3;  b = 1e-3;                            % kg m^2, N m s
Kv = 0.8;  Ki = 20;  Kp = 300;
s = tf('s');
plant = 1 / (J*s + b);
velocity = feedback((Kv + Ki/s) * plant, 1);
position = feedback(Kp * velocity / s, 1);
[y, t] = step(10 * position, 0.2);
fprintf('overshoot %.1f%% on a 10 mm step\n', 100*(max(y) - 10)/10);
fprintf('within 0.1 mm of target after %.0f ms\n', 1000*t(find(abs(y - 10) > 0.1, 1, 'last') + 1));

plot(1000*t, y);
title('Position step, servo axis');
xlabel('Time (ms)');
ylabel('Position (mm)');
