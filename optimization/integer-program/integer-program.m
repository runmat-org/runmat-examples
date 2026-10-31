% Whole units only: an integer program next to its linear relaxation
f = -[5 4];                               % maximize 5x + 4y
A = [6 4; 1 2]; b = [24; 6];
lb = [0 0];
xr = linprog(f, A, b, [], [], lb);
[xi, fi] = intlinprog(f, [1 2], A, b, [], [], lb);
fprintf('Relaxation: x = %.2f, y = %.2f, value %.2f\n', xr, -f*xr);
fprintf('Integer:    x = %.0f, y = %.0f, value %.0f\n', xi, -fi);

fill([0 4 3 0], [0 0 1.5 3], [0.3 0.55 0.9], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
hold on;
[gx, gy] = meshgrid(0:4, 0:3);
ok = 6*gx + 4*gy <= 24 & gx + 2*gy <= 6;
plot(gx(ok), gy(ok), '.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 14);
plot(xr(1), xr(2), 'bs', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
plot(xi(1), xi(2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
hold off;
axis([-0.2 4.5 -0.2 3.3]);
legend('relaxation feasible region', 'integer points', 'relaxation optimum', 'integer optimum');
title('Integer optimum and relaxation optimum');
xlabel('x');
ylabel('y');
grid on;
