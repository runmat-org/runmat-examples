% Center, width and height of a peak in noisy counts, with a sloping background
rng(12);
ch = (1:200)';
counts = 40 + 0.05*ch + 220*exp(-(ch - 112).^2/(2*6.5^2));
counts = counts + sqrt(counts).*randn(size(ch));

model = @(p, x) p(1)*exp(-(x - p(2)).^2/(2*p(3)^2)) + p(4) + p(5)*x;
p0 = [max(counts) - median(counts), 100, 10, median(counts), 0];
p = lsqcurvefit(model, p0, ch, counts, [0 1 0.5 -Inf -Inf], [Inf 200 50 Inf Inf]);
fprintf('Peak at channel %.2f, sigma %.2f, height %.1f counts\n', p(2), p(3), p(1));
fprintf('FWHM %.2f channels\n', 2*sqrt(2*log(2))*p(3));

plot(ch, counts, '.', 'MarkerSize', 9);
hold on;
plot(ch, model(p, ch), 'LineWidth', 2);
plot(ch, p(4) + p(5)*ch, '--', 'LineWidth', 1.2);
hold off;
legend('counts', 'peak fit', 'background');
title('Fitting a peak');
xlabel('Channel');
ylabel('Counts');
grid on;
