% Ramp response of the unity-feedback loop; a type-1 loop lags a ramp by 1/Kv
s = tf('s');
G = 10/(s*(s + 1)*(s + 5));
T = feedback(G, 1);

t = (0:0.01:20)';
r = t;                                   % ramp reference, 1 unit per second
y = lsim(T, r, t);

Kv = 10/(1*5);                           % lim s->0 of s*G(s)
fprintf('Velocity constant Kv = %.1f, so the lag settles to 1/Kv = %.2f\n', Kv, 1/Kv);
fprintf('Simulated lag at t = %.0f s: %.3f\n', t(end), r(end) - y(end));

plot(t, r, '--', t, y, 'LineWidth', 1.5);
legend('reference', 'output');
title(sprintf('Ramp response: steady lag %.2f', r(end) - y(end)));
xlabel('Time (s)');
ylabel('Position');
grid on;
