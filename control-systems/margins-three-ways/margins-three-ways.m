% Gain margin of G(s) = 10/(s(s + 1)(s + 5)) from margin, from the Routh array and
% from the gain at which the root locus reaches the imaginary axis
s = tf('s');
G = 10/(s*(s + 1)*(s + 5));

[Gm, Pm, Wcg, Wcp] = margin(G);
fprintf('Gain margin %.3f (%.2f dB) at %.4f rad/s; phase margin %.1f deg at %.3f rad/s\n', ...
    Gm, 20*log10(Gm), Wcg, Pm, Wcp);

% Routh: s^3 + 6s^2 + 5s + 10K stays stable while 6*5 > 10K
fprintf('Routh limit: K < %.3f\n', 6*5/10);

% At that gain two closed-loop poles sit on the imaginary axis
p = roots([1 6 5 10*Gm]);
fprintf('Closed-loop poles at K = %.0f: %.4f, +/-%.4fi\n', Gm, real(p(abs(imag(p)) < 1e-6)), max(imag(p)));

rlocus(G);
hold on;
plot([0 0], [-1 1]*Wcg, 'ro', 'MarkerSize', 8);
hold off;
title(sprintf('Root locus: crosses the imaginary axis at %.2f rad/s', Wcg));
