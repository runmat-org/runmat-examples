% Shadow prices of the production plan: the profit one more machine hour would add
f = -[3 5];
A = [1 0; 0 2; 3 2];
b = [4; 12; 18];
[x, fval, flag, output, lambda] = linprog(f, A, b, [], [], [0 0]);
fprintf('Best plan: %.0f and %.0f units, profit %.0f\n', x, -fval);
used = A*x;
for k = 1:3
    fprintf('Machine %d: %.0f of %.0f hours used; one more hour adds %.2f\n', k, used(k), b(k), lambda.ineqlin(k));
end

bar(lambda.ineqlin);
xticks(1:3);
xticklabels({'Machine 1', 'Machine 2', 'Machine 3'});
ylabel('Profit per extra hour');
title('Shadow prices of the three machine limits');
grid on;
