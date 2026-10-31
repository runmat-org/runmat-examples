t = 0:0.5:10;
y = 1 - exp(-0.5*t);

h = stairs(t, y);
set(h, 'LineWidth', 2);
title('First-Order Step Response');
xlabel('Time (s)');
ylabel('Output');
grid on;
