rng(3);
groups = {'Batch A', 'Batch B', 'Batch C', 'Batch D'};
strength = [52 55 49 54] + randn(40, 4) .* [3 2 4 2.5];
strength(5, 3) = 34;
strength(12, 2) = 63;

boxplot(strength, 'Labels', groups);
title('Tensile Strength by Batch');
xlabel('Batch');
ylabel('Strength (MPa)');
grid on;
