categories = {'Q1', 'Q2', 'Q3', 'Q4'};
revenue = [42 51 63 58; 38 45 52 61; 29 34 48 55];

bar(revenue');
title('Quarterly Revenue by Region');
xlabel('Quarter');
ylabel('Revenue ($M)');
legend('North', 'South', 'West');
grid on;
