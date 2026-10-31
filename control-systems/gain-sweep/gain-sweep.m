% Closed-loop step responses of G(s) = 10/(s(s + 1)(s + 5)) for three proportional gains
s = tf('s');
G = 10/(s*(s + 1)*(s + 5));

K = [0.5 1 2];
for k = K
    S = stepinfo(feedback(k*G, 1));
    fprintf('K = %.1f: rise %.2f s, overshoot %.0f%%, settling %.1f s\n', ...
        k, S.RiseTime, S.Overshoot, S.SettlingTime);
end

step(feedback(K(1)*G, 1), feedback(K(2)*G, 1), feedback(K(3)*G, 1), 40);
legend('K = 0.5', 'K = 1', 'K = 2');
title('Closed-loop step response for three gains');
grid on;
