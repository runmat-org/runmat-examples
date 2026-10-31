% Nyquist plots of K*G for K = 1 and K = 4, with the closed-loop poles for each
s = tf('s');
G = 10/(s*(s + 1)*(s + 5));

for K = [1 4]
    [re, im] = nyquist(K*G, sqrt(5));            % where the curve crosses the real axis
    unstable = sum(real(pole(feedback(K*G, 1))) > 0);
    fprintf('K = %d: crosses the real axis at %.3f; %d closed-loop poles in the right half-plane\n', ...
        K, re, unstable);
end

nyquist(G);
hold on;
nyquist(4*G);
hold off;
axis([-3 1 -2 2]);
legend('K = 1', 'K = 4');
title('Nyquist plots for K = 1 and K = 4');
