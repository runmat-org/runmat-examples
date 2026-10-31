% Junction temperature of a power device through its thermal resistance chain,
% across the power range, against its 150 C limit at 40 C ambient.
P = linspace(0, 30, 121);
R = [1.5 0.5 2.4];                 % junction-case, interface, heat sink (K/W)
Ta = 40;  Tmax = 150;
Tj = Ta + P * sum(R);
Pmax = (Tmax - Ta) / sum(R);
fprintf('junction temperature %.0f C at 10 W, %.1f K/W in total\n', Ta + 10*sum(R), sum(R));
fprintf('the device reaches 150 C at %.1f W\n', Pmax);

plot(P, Tj);
yline(Tmax);
ylim([30 180]);
title('Junction temperature against power');
xlabel('Power (W)');
ylabel('Junction temperature (C)');
