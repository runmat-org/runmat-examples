% Bode plot of a lightly damped mass-spring-damper and its resonant peak
m = 1; c = 2; k = 100;                   % kg, N s/m, N/m
G = tf(1, [m c k]);                       % displacement per unit force

wn = sqrt(k/m); zeta = c/(2*sqrt(k*m));
[mag, ~, w] = bode(G, logspace(0, 2, 4000));
[peak, i] = max(squeeze(mag));
fprintf('Natural frequency %.2f rad/s, damping ratio %.2f\n', wn, zeta);
fprintf('Peak at %.2f rad/s (%.2f Hz): %.2f times the static deflection (%.1f dB)\n', ...
    w(i), w(i)/(2*pi), peak*k, 20*log10(peak*k));

bode(G);
grid on;
title('Bode diagram of a mass-spring-damper, zeta = 0.1');
