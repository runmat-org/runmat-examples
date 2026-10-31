% An EV on the EPA urban cycle (UDDS, 1 Hz): road load at the wheels, regen, accessories,
% then battery energy per kilometre and range from a 75 kWh pack.
d = readmatrix('cycles/udds.txt', 'NumHeaderLines', 2);
t = d(:, 1);  v = d(:, 2) * 0.44704;                % mph to m/s
m = 1800;  Crr = 0.009;  CdA = 0.62;  rho = 1.2;  g = 9.81;
eta = 0.85;  regen = 0.6;  aux = 400;               % drivetrain, regen share, accessories (W)
a = vertcat(diff(v), 0);
P = (m*a + m*g*Crr*(v > 0) + 0.5*rho*CdA*v.^2) .* v;
Pb = P/eta .* (P > 0) + P*eta*regen .* (P < 0) + aux;
km = trapz(t, v) / 1000;  Wh = trapz(t, Pb) / 3600;
fprintf('%.1f km in %d s at %.0f Wh/km from the battery\n', km, round(t(end)), Wh/km);
fprintf('about %.0f km from a 75 kWh pack on this cycle\n', 75000/(Wh/km));

plot(t, Pb/1000);
title('Battery power over the EPA urban cycle');
xlabel('Time (s)');
ylabel('Battery power (kW)');
