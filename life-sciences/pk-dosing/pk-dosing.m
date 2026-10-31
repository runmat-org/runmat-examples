% One-compartment oral dosing, 500 mg every 12 hours (absorption 1.2 per hour,
% elimination 0.17 per hour, volume 40 L): concentration to steady state.
ka = 1.2;  ke = 0.17;  V = 40;  dose = 500;  tau = 12;  doses = 8;
f = @(t, x) [-ka*x(1); ka*x(1) - ke*x(2)];
tt = zeros(doses*200, 1);  cc = zeros(doses*200, 1);  x0 = [dose; 0];
for n = 1:doses
    [ts, xs] = ode45(f, linspace((n-1)*tau, n*tau, 200), x0);
    rows = (n-1)*200 + (1:200)';
    tt(rows) = ts;  cc(rows) = xs(:, 2) / V;
    x0 = xs(end, :)' + [dose; 0];
end
late = tt > (doses-1)*tau;
fprintf('steady-state peak %.1f mg/L, trough %.1f mg/L\n', max(cc(late)), min(cc(late)));
first = cc(find(tt <= tau, 1, 'last'));
fprintf('trough accumulation %.2f against the first dose (closed form %.2f)\n', min(cc(late)) / first, 1 / (1 - exp(-ke*tau)));

plot(tt, cc);
title('Plasma concentration, 500 mg every 12 h');
xlabel('Time (h)');
ylabel('Concentration (mg/L)');
