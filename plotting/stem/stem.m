n = 0:31;
x = sin(2*pi*n/16) .* (0.9 .^ n);

stem(n, x);
title('Sampled Decaying Sinusoid');
xlabel('Sample index n');
ylabel('x[n]');
grid on;
