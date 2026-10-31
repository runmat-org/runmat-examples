% Bode plot of a second-order low-pass filter with its -3 dB bandwidth marked
wn = 10;                                  % natural frequency, rad/s
zeta = 1/sqrt(2);                         % this damping puts the -3 dB point near wn
G = tf(wn^2, [1 2*zeta*wn wn^2]);

wb = bandwidth(G);                        % where the gain has fallen 3 dB
[mag, phase, w] = bode(G, logspace(0, 2, 400));
mag = 20*log10(squeeze(mag));
phase = squeeze(phase);
pb = interp1(w, phase, wb);

subplot(2, 1, 1);
semilogx(w, mag, 'LineWidth', 1.5);
hold on;
semilogx(wb, -3, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
yline(-3, '--', '-3 dB');
xline(wb, ':');
hold off;
ylim([-40 5]);
ylabel('Magnitude (dB)');
title(sprintf('Second-order low-pass: -3 dB at %.2f rad/s', wb));
grid on;

subplot(2, 1, 2);
semilogx(w, phase, 'LineWidth', 1.5);
hold on;
semilogx(wb, pb, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
xline(wb, ':');
hold off;
ylabel('Phase (deg)');
xlabel('Frequency (rad/s)');
grid on;
