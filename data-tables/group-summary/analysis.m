% Mean and spread of force per fixture, after dropping gaps and an outlier
T = readtable('rig_clean.csv');
T = rmmissing(T);
spike = isoutlier(T.Force_N);
fprintf('%d readings kept, %d outlier removed\n', height(T) - sum(spike), sum(spike));
T = T(~spike, :);

G = groupsummary(T, 'Fixture', {'mean', 'std'}, 'Force_N')

bar(G.mean_Force_N, 0.6);
hold on;
errorbar(1:height(G), G.mean_Force_N, G.std_Force_N, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
hold off;
xticks(1:height(G));
xticklabels(string(G.Fixture));
xlabel('Fixture');
ylim([900 1200]);
title('Force by fixture');
ylabel('Mean force (N), with one standard deviation');
grid on;
