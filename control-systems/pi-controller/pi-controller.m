% P and PI control of a two-lag thermal plant, G(s) = 2/((10s + 1)(2s + 1))
s = tf('s');
G = 2/((10*s + 1)*(2*s + 1));

Kp = 1.25;
C = pid(Kp, Kp/10);                     % PI zero placed on the slow pole at -0.1
P = feedback(Kp*G, 1);
T = feedback(C*G, 1);

ST = stepinfo(T);
fprintf('P only: settles at %.3f (error %.1f%%)\n', dcgain(P), 100*(1 - dcgain(P)));
fprintf('PI:     settles at %.3f, overshoot %.1f%%, settling %.1f s\n', dcgain(T), ST.Overshoot, ST.SettlingTime);

step(P, T, 40);
legend('P, Kp = 1.25', 'PI, Kp = 1.25, Ki = 0.125');
title('Step response under P and PI control');
grid on;
