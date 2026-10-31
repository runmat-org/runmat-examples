% Hosting capacity: how much solar bus 14 takes at light load before its voltage
% rises 3% above its level with no solar, a common planning limit.
bus = [ 1 3 1.060  0     0    232.4 0;     2 2 1.045 21.7 12.7 40 0;
        3 2 1.010 94.2  19.0  0     0;        4 0 1     47.8 -3.9  0  0;
        5 0 1      7.6   1.6  0     0;        6 2 1.070 11.2  7.5  0  0;
        7 0 1      0     0    0     0;        8 2 1.090  0    0    0  0;
        9 0 1     29.5  16.6  0     0.19;    10 0 1      9.0  5.8  0  0;
       11 0 1      3.5   1.8  0     0;       12 0 1      6.1  1.6  0  0;
       13 0 1     13.5   5.8  0     0;       14 0 1     14.9  5.0  0  0];
br = [ 1  2 .01938 .05917 .0528 0;     1  5 .05403 .22304 .0492 0;
       2  3 .04699 .19797 .0438 0;     2  4 .05811 .17632 .0340 0;
       2  5 .05695 .17388 .0346 0;     3  4 .06701 .17103 .0128 0;
       4  5 .01335 .04211 0     0;     4  7 0      .20912 0     .978;
       4  9 0      .55618 0     .969;  5  6 0      .25202 0     .932;
       6 11 .09498 .19890 0     0;     6 12 .12291 .25581 0     0;
       6 13 .06615 .13027 0     0;     7  8 0      .17615 0     0;
       7  9 0      .11001 0     0;     9 10 .03181 .08450 0     0;
       9 14 .12711 .27038 0     0;    10 11 .08205 .19207 0     0;
      12 13 .22092 .19988 0     0;    13 14 .17093 .34802 0     0];

light = bus;
light(:, 4:5) = bus(:, 4:5) * 0.4;
pvs = 0:4:100;
v14 = zeros(size(pvs));
for k = 1:numel(pvs)
    b = light;
    b(14, 6) = pvs(k);
    V = powerflow(b, br);
    v14(k) = V(14);
end
cap = 1.03 * v14(1);
limit = pvs(find(v14 > cap, 1) - 1);
fprintf('bus 14 sits at %.3f pu at 40%% load with no solar; the limit is %.3f pu\n', v14(1), cap);
fprintf('it takes %d MW of solar before passing the limit\n', limit);

plot(pvs, v14, 'LineWidth', 2);
hold on;
plot([0 100], [cap cap], '--');
title('Bus 14 voltage against solar at the bus');
xlabel('Solar at bus 14 (MW)');
ylabel('Voltage (pu)');

function [V, th, S] = powerflow(bus, br)
% Newton-Raphson power flow: S = V .* conj(Y*V) at every bus.
    n = size(bus, 1);
    Y = diag(1i*bus(:, 7));
    for k = 1:size(br, 1)
        f = br(k, 1);  t = br(k, 2);
        y = 1 / (br(k, 3) + 1i*br(k, 4));  b = 1i*br(k, 5)/2;
        a = br(k, 6) + (br(k, 6) == 0);
        Y(f, f) = Y(f, f) + (y + b)/a^2;  Y(t, t) = Y(t, t) + y + b;
        Y(f, t) = Y(f, t) - y/a;          Y(t, f) = Y(t, f) - y/a;
    end
    P = (bus(:, 6) - bus(:, 4)) / 100;  Q = -bus(:, 5) / 100;
    pv = find(bus(:, 2) == 2);  pq = find(bus(:, 2) == 0);  ns = vertcat(pv, pq);
    V = bus(:, 3);  th = zeros(n, 1);  S = zeros(n, 1);
    for it = 1:20
        E = V .* exp(1i*th);
        S = E .* conj(Y*E);
        mis = vertcat(P(ns) - real(S(ns)), Q(pq) - imag(S(pq)));
        if max(abs(mis)) < 1e-8, break; end
        dSdth = 1i*diag(E)*conj(diag(Y*E) - Y*diag(E));
        dSdV = diag(E)*conj(Y*diag(E./V)) + diag(conj(Y*E).*(E./V));
        J = vertcat(horzcat(real(dSdth(ns, ns)), real(dSdV(ns, pq))), ...
                    horzcat(imag(dSdth(pq, ns)), imag(dSdV(pq, pq))));
        dx = J \ mis;
        m = numel(ns);
        th(ns) = th(ns) + dx((1:m)');
        V(pq) = V(pq) + dx((m+1:numel(dx))');
    end
end
