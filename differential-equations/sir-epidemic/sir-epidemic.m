% SIR epidemic model: susceptible, infected, recovered (fractions of the population)
beta = 0.3;  gamma = 0.1;                    % contact rate and recovery rate per day
f = @(t, y) [-beta*y(1)*y(2); beta*y(1)*y(2) - gamma*y(2); gamma*y(2)];

[t, y] = ode45(f, 0:0.5:160, [0.999; 0.001; 0]);    % report twice a day

[peak, k] = max(y(:, 2));
fprintf('Peak: %.1f%% infected on day %.0f\n', 100*peak, t(k));
fprintf('Never infected: %.1f%% of the population\n', 100*y(end, 1));

plot(t, y(:, 1));
hold on;
plot(t, y(:, 2));
plot(t, y(:, 3));
legend('susceptible', 'infected', 'recovered');
title('SIR epidemic');
xlabel('Day');
ylabel('Fraction of population');
