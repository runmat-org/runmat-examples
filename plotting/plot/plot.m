t = linspace(0, 4*pi, 500);
envelope = exp(-0.3*t);
signal = envelope .* sin(5*t);

h1 = plot(t, signal);
set(h1, 'DisplayName', 'Damped signal', 'LineWidth', 1.5);
hold on;
h2 = plot(t, envelope, '--');
set(h2, 'DisplayName', 'Envelope', 'LineWidth', 1.5, 'Color', [0.85 0.33 0.1]);
h3 = plot(t, -envelope, '--');
set(h3, 'DisplayName', '-Envelope', 'LineWidth', 1.5, 'Color', [0.85 0.33 0.1]);
hold off;

title('Damped Oscillation');
xlabel('Time (s)');
ylabel('Amplitude');
legend();
grid on;
