% Three second-order systems with wn = 2 rad/s and damping ratios 0.2, 0.5 and 0.8
s = tf('s');
wn = 2;
zeta = [0.2 0.5 0.8];
G = cell(1, 3);
for i = 1:3
    G{i} = wn^2/(s^2 + 2*zeta(i)*wn*s + wn^2);
    S = stepinfo(G{i});
    fprintf('zeta = %.1f: poles %.2f +/- %.2fi, overshoot %.0f%% (formula %.0f%%)\n', zeta(i), ...
        -zeta(i)*wn, wn*sqrt(1 - zeta(i)^2), S.Overshoot, 100*exp(-pi*zeta(i)/sqrt(1 - zeta(i)^2)));
end

subplot(1, 2, 1);
pzmap(G{1}, G{2}, G{3});
title('Poles on a circle of radius wn');
subplot(1, 2, 2);
step(G{1}, G{2}, G{3}, 8);
legend('zeta = 0.2', 'zeta = 0.5', 'zeta = 0.8');
title('Step responses');
grid on;
