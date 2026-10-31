% Ten years of month-end yield curves through a policy cycle: rates near zero,
% a hiking cycle that inverts the curve, then cuts that steepen it again.
rng(8);
months = 120;
mat = [0.25 0.5 1 2 3 5 7 10 15 20 30];
t = (1:months)';
policy = 0.25 + 4.75 ./ (1 + exp(-(t - 45)/5)) - 1.75 ./ (1 + exp(-(t - 95)/4));
longrun = 2.0 + 1.6 ./ (1 + exp(-(t - 40)/10)) + 0.15*cumsum(randn(months, 1))/sqrt(months);
lam = 2.5;
Y = zeros(months, numel(mat));
for m = 1:months
    w = exp(-mat / lam);
    hump = 0.4 * (mat/lam) .* exp(1 - mat/lam);
    Y(m, :) = policy(m)*w + longrun(m)*(1 - w) + 0.3*hump*(policy(m) > longrun(m));
end
Y = Y + 0.03*randn(size(Y));

spread = Y(:, 8) - Y(:, 4);           % 10-year minus 2-year
fprintf('2s10s spread from %+.2f to %+.2f points\n', max(spread), min(spread));
fprintf('curve inverted in %d of %d months\n', sum(spread < 0), months);

[MM, TT] = meshgrid(mat, t/12);
surf(MM, TT, Y);
view(-40, 28);
title('Ten years of yield curves');
xlabel('Maturity (years)');
ylabel('Years');
zlabel('Yield (%)');
