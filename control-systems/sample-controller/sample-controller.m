% The loop with K = 0.5, discretized with a zero-order hold at two sample times
s = tf('s');
G = 5/(s*(s + 1)*(s + 5));               % the loop with K = 0.5

for Ts = [0.1 0.5]
    Gd = c2d(G, Ts, 'zoh');
    S = stepinfo(feedback(Gd, 1));
    fprintf('Ts = %.1f s: overshoot %.0f%%, settling %.1f s\n', Ts, S.Overshoot, S.SettlingTime);
end
S = stepinfo(feedback(G, 1));
fprintf('Continuous:  overshoot %.0f%%, settling %.1f s\n', S.Overshoot, S.SettlingTime);

step(feedback(G, 1), feedback(c2d(G, 0.1, 'zoh'), 1), feedback(c2d(G, 0.5, 'zoh'), 1), 25);
legend('continuous', 'Ts = 0.1 s', 'Ts = 0.5 s');
title('Step response, continuous and sampled');
grid on;
