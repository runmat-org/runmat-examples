% A one-RC equivalent circuit fitted to a 10 s, 50 A discharge pulse and its relaxation.
% The measured voltage comes from pulse_test at the end of the file.
[t, V] = pulse_test();
ocv = 3.65;                                % open-circuit voltage here (V)
on = @(t) t >= 5 & t < 15;
fall = @(t, tau) (t >= 15).*(1 - exp(-10/tau)).*exp(-(t - 15)/tau);
rise = @(t, tau) on(t).*(1 - exp(-(t - 5)/tau)) + fall(t, tau);
% Parameters: R0 and R1 in milliohms, the RC time constant in seconds.
model = @(p, t) ocv - p(1)/1000*50*on(t) - p(2)/1000*50*rise(t, p(3));
p = lsqcurvefit(model, [1 1 5], t, V);
fprintf('R0 %.2f mOhm, R1 %.2f mOhm\n', p(1), p(2));
fprintf('time constant %.1f s\n', p(3));

plot(t, V, '.');
hold on;
plot(t, model(p, t), 'LineWidth', 2);
title('Pulse test and the fitted cell model');
xlabel('Time (s)');
ylabel('Terminal voltage (V)');

function [t, V] = pulse_test()
% A cell built with R0 = 2.10 mOhm, R1 = 1.50 mOhm and a 13.5 s time constant, sampled
% at 10 Hz with 0.3 mV of noise.
R0 = 0.0021;  R1 = 0.0015;  tau = 13.5;  ocv = 3.65;
t = (0:0.1:60)';  I = 50*(t >= 5 & t < 15);
v1 = zeros(size(t));
for k = 2:numel(t)
    v1(k) = v1(k-1)*exp(-0.1/tau) + R1*(1 - exp(-0.1/tau))*I(k-1);
end
rng(2);
V = ocv - R0*I - v1 + 0.0003*randn(size(t));
end
