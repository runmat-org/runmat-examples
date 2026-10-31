% A wearable on the wrist: 0.35 W from its electronics, a two-node model of the
% board and the skin-contact case, against a 43 C limit for skin contact.
P = 0.35;  Cb = 4;  Cc = 12;            % W, J/K board, J/K case
Rbc = 25;  Rskin = 60;  Rair = 90;      % K/W board-case, case-skin, case-air
Tskin = 33;  Tair = 25;
f = @(t, T) [(P - (T(1) - T(2))/Rbc) / Cb;
             ((T(1) - T(2))/Rbc - (T(2) - Tskin)/Rskin - (T(2) - Tair)/Rair) / Cc];
[t, T] = ode45(f, linspace(0, 3600, 600), [Tair; Tair]);
Rpar = 1 / (1/Rskin + 1/Rair);
steady = (Tskin/Rskin + Tair/Rair + P) * Rpar;
fprintf('case %.1f C after an hour, %.1f C at steady state\n', T(end, 2), steady);
fprintf('margin to the 43 C skin-contact limit %.1f K\n', 43 - max(T(:, 2)));

plot(t/60, T(:, 1), t/60, T(:, 2));
yline(43);
legend('Board', 'Case on skin', '43 C limit');
title('Wearable temperature on the wrist');
xlabel('Time (min)');
ylabel('Temperature (C)');
