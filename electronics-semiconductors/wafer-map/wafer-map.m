% Die yield across a 300 mm wafer with 10 x 10 mm dies, where defect density
% rises toward the edge, and the yield by radial zone.
rng(6);
pitch = 10;  radius = 150;
[cx, cy] = meshgrid(-145:pitch:145, -145:pitch:145);
on = sqrt(cx.^2 + cy.^2) + pitch*0.7 < radius;
x = cx(on);  y = cy(on);  rr = sqrt(x.^2 + y.^2) / radius;
density = 0.02 + 0.25*rr.^6;                      % defects per die
good = rand(numel(x), 1) < exp(-density);
fprintf('%d dies, yield %.1f%%\n', numel(x), 100*mean(good));
fprintf('center yield %.1f%%, outer ring %.1f%%\n', 100*mean(good(rr < 0.5)), 100*mean(good(rr > 0.85)));

scatter(x(good), y(good), 40, 'filled');
hold on;
scatter(x(~good), y(~good), 40, [0.9 0.3 0.25], 'filled');
th = linspace(0, 2*pi, 200);
plot(radius*cos(th), radius*sin(th));
hold off;
axis equal;
xlim([-160 160]); ylim([-160 160]);
legend('Good die', 'Failed die', 'Wafer edge');
title('Wafer map, 300 mm');
xlabel('x (mm)');
ylabel('y (mm)');
