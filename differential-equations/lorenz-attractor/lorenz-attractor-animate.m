% Lorenz system with the classic parameters, drawn live one Runge-Kutta step at a time.
% lorenz-attractor-ode.m solves the same system with ode45 and plots it at the end.
sigma = 10;  rho = 28;  b = 8/3;
f = @(u) [sigma*(u(2) - u(1)); u(1)*(rho - u(3)) - u(2); u(1)*u(2) - b*u(3)];

h = animatedline('LineWidth', 1);
title('Lorenz attractor');
xlabel('x');
ylabel('y');
zlabel('z');
grid on;
view(35, 20);
axis([-25 25 -30 30 0 50]);

u = [1; 1; 1];  dt = 0.02;
for k = 1:2000
    % one classic Runge-Kutta step
    k1 = f(u);  k2 = f(u + dt/2*k1);  k3 = f(u + dt/2*k2);  k4 = f(u + dt*k3);
    u = u + dt/6*(k1 + 2*k2 + 2*k3 + k4);
    addpoints(h, u(1), u(2), u(3));
    if mod(k, 5) == 0
        drawnow;
    end
end
