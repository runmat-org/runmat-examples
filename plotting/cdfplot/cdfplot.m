rng(9);
lifetime_a = -1200*log(rand(300, 1));
lifetime_b = 900 + 250*randn(300, 1);

cdfplot(lifetime_a);
hold on;
cdfplot(lifetime_b);
hold off;
title('Bearing Lifetimes');
xlabel('Hours to failure');
ylabel('Fraction failed');
legend('Supplier A', 'Supplier B', 'Location', 'southeast');
