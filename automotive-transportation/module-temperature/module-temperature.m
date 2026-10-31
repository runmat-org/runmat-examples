% A 12-cell module on a cold plate over three back-to-back EPA US06 cycles: I^2 R heat in
% each cell, coolant warming along the plate, heat shared with neighboring cells.
d = readmatrix('cycles/us06.txt', 'NumHeaderLines', 2);
v = repmat(d(:, 2) * 0.44704, 3, 1);  n = numel(v);
P = 1800*vertcat(diff(v), 0).*v + 1800*9.81*0.009*v + 0.31*1.2*v.^3 + 400;
I = P / 350 / 3;                                    % current per parallel string (A)
cells = 12;  R = 0.0021;  Cth = 900;  hc = 0.8;  hn = 1.0;   % ohm, J/K, W/K to plate and neighbor
Tc = 25 + 0.4*(0:cells - 1)';                       % coolant warms along the plate (C)
T = 25*ones(cells, 1);  mid = (2:cells - 1)';
hist = zeros(n, cells);
for k = 1:n
    lap = vertcat(T(2) - T(1), T(mid + 1) - 2*T(mid) + T(mid - 1), T(cells - 1) - T(cells));
    T = T + (I(k)^2*R - hc*(T - Tc) + hn*lap) / Cth;
    hist(k, :) = T';
end
fprintf('hottest cell %.1f C after three US06 cycles, coolest %.1f C\n', max(T), min(T));
fprintf('spread across the module %.1f K\n', max(T) - min(T));

minutes = (1:n)'/60;
hold on;
for c = 1:cells
    plot(minutes, hist(:, c));
end
title('Cell temperatures, three US06 cycles');
xlabel('Time (min)');
ylabel('Temperature (C)');
