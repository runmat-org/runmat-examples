% An accessory bracket's first two modes against a 4-cylinder engine's second and fourth
% orders from idle to redline: each crossing is a speed where the bracket rings.
f1 = 185;  f2 = 412;                                % bracket modes (Hz)
rpm = linspace(700, 6500, 200);
fprintf('2nd order crosses the first mode at %.0f rpm\n', 60*f1/2);
fprintf('4th order crosses it at %.0f rpm and the second mode at %.0f rpm\n', 60*f1/4, 60*f2/4);

plot(rpm, 2*rpm/60, 'LineWidth', 2);
hold on;
plot(rpm, 4*rpm/60, 'LineWidth', 2);
plot([700 6500], [f1 f1], '--');
plot([700 6500], [f2 f2], '--');
legend('2nd order', '4th order', 'Mode 1', 'Mode 2');
title('Bracket modes against engine orders');
xlabel('Engine speed (rpm)');
ylabel('Frequency (Hz)');
