h = animatedline('LineWidth', 1.5);
title('Live Sensor Reading');
xlabel('Time (s)');
ylabel('Displacement (mm)');
grid on;
for k = 1:400
    t = k/40;
    addpoints(h, t, exp(-0.25*t)*sin(4*t));
    drawnow;
end
