% Local and global minima: fminunc from a grid of starting points on peaks.
% Each start is colored by the value where fminunc stops.
pk = @(v) 3*(1 - v(1))^2*exp(-v(1)^2 - (v(2) + 1)^2) ...
    - 10*(v(1)/5 - v(1)^3 - v(2)^5)*exp(-v(1)^2 - v(2)^2) - exp(-(v(1) + 1)^2 - v(2)^2)/3;
opts = optimoptions('fminunc', 'Display', 'off');
[gx, gy] = meshgrid(-2:0.5:2, -2:0.5:2);
starts = [gx(:) gy(:)];
fend = zeros(size(starts, 1), 1);
for k = 1:size(starts, 1)
    [~, fend(k)] = fminunc(pk, starts(k, :), opts);
end
reached = fend < -0.5;                    % the flat outer region has f near 0
values = unique(round(fend(reached), 2));
fprintf('%d of %d starts reach a minimum; %d slide into the flat outer region\n', ...
    sum(reached), numel(fend), sum(~reached));
for v = values'
    fprintf('f = %6.2f from %2d starts\n', v, sum(round(fend, 2) == v));
end

[X, Y] = meshgrid(-3:0.05:3);
contour(X, Y, peaks(X, Y), 24);
hold on;
scatter(starts(:, 1), starts(:, 2), 36, round(fend, 2), 'filled');
hold off;
colorbar;
xlabel('x');
ylabel('y');
title('Starting points colored by where fminunc stops');
