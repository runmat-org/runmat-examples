x = 1:8;
y = [2.1 3.4 4.2 5.8 5.5 6.1 7.3 8.0];
neg = [0.3 0.4 0.2 0.5 0.6 0.3 0.4 0.3];
pos = [0.4 0.3 0.3 0.6 0.5 0.4 0.5 0.4];

errorbar(x, y, neg, pos, 'o-', 'LineWidth', 1.5);
title('Tensile Strength vs. Sample');
xlabel('Sample #');
ylabel('Strength (MPa)');
grid on;
