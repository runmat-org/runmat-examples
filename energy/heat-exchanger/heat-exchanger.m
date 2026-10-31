% A counterflow heat exchanger sized by effectiveness-NTU: hot water at 90 C,
% 2 kg/s; cold water at 20 C, 3 kg/s; overall coefficient 1,200 W/m^2 K.
cp = 4180;  Ch = 2*cp;  Cc = 3*cp;  U = 1200;  Thi = 90;  Tci = 20;
Cmin = min(Ch, Cc);  Cr = Cmin / max(Ch, Cc);
area = (1:0.5:60)';
NTU = U * area / Cmin;
eff = (1 - exp(-NTU*(1 - Cr))) ./ (1 - Cr*exp(-NTU*(1 - Cr)));
q = eff * Cmin * (Thi - Tci);
Tho = Thi - q/Ch;  Tco = Tci + q/Cc;
need = fzero(@(a) interp1(area, Tco, a) - 55, 20);
fprintf('cold side reaches 55 C with %.1f m^2 of area\n', need);
fprintf('at 60 m^2: %.0f kW, hot side out at %.1f C\n', q(end)/1000, Tho(end));

plot(area, Tho, 'LineWidth', 2);
hold on;
plot(area, Tco, 'LineWidth', 2);
legend('Hot outlet', 'Cold outlet');
title('Outlet temperatures against heat-transfer area');
xlabel('Area (m^2)');
ylabel('Temperature (C)');
