rng(7);
a = 2 + 1.2*randn(1, 5000);
b = 4 + 0.8*randn(1, 5000);

h1 = histogram(a, 'BinEdges', -2:0.25:8, 'Normalization', 'probability');
set(h1, 'DisplayName', 'Process A');
hold on;
h2 = histogram(b, 'BinEdges', -2:0.25:8, 'Normalization', 'probability');
set(h2, 'DisplayName', 'Process B');
hold off;

title('Distribution Comparison');
xlabel('Measurement');
ylabel('Probability');
legend();
grid on;
