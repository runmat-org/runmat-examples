time = linspace(0, 12, 300);
fast = exp(-0.85*time);
slow = exp(-0.38*time);

h1 = semilogy(time, fast);
set(h1, 'LineWidth', 2, 'DisplayName', 'Fast decay');
hold on;
h2 = semilogy(time, slow, '--');
set(h2, 'LineWidth', 2, 'DisplayName', 'Slow decay');
hold off;
title('Decay Rate Comparison');
xlabel('Time (s)');
ylabel('Normalized response');
legend();
grid on;
