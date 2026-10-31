% Newton-Raphson power flow on the IEEE 14-bus test case, checked against the
% published solution.
% bus: number, type (3 slack, 2 generator, 0 load), voltage set point (pu),
%      load MW, load Mvar, generation MW, shunt susceptance (pu)
% br:  from, to, resistance, reactance, charging (pu), transformer ratio
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

[V, th, S] = powerflow(bus, br);
fprintf('slack bus supplies %.1f MW and %.1f Mvar\n', 100*real(S(1)), 100*imag(S(1)));
fprintf('bus 14 at %.3f pu, %.2f degrees (published 1.036 pu, -16.04)\n', V(14), th(14)*180/pi);

bar(1:14, V);
hold on;
plot([0.5 14.5], [1.05 1.05], '--');
plot([0.5 14.5], [0.95 0.95], '--');
ylim([0.9 1.12]);
title('Bus voltages, IEEE 14-bus case');
xlabel('Bus');
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
