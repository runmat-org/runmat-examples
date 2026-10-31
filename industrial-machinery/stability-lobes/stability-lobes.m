% Stability lobes for a milling spindle with one dominant mode (650 Hz, 2% damping,
% 50 N/um), three teeth, cutting stiffness 700 N/mm^2; single-mode model after
% Schmitz and Smith, Machining Dynamics.
fn = 650;  zeta = 0.02;  k = 5e7;  Ks = 7e8;  N = 3;
fc = linspace(1.001, 1.5, 500)' * fn;           % chatter frequencies (Hz)
r = fc / fn;
G = 1 ./ (k * (1 - r.^2 + 2i*zeta*r));
re = real(G);  im = imag(G);
blim = -1 ./ (2*Ks*re);                        % limiting axial depth (m)
eps = 2*pi - 2*atan(re ./ im);
rpm = zeros(numel(fc), 4);
for lobe = 0:3
    rpm(:, lobe + 1) = 60 * fc ./ (N * (lobe + eps/(2*pi)));
end
fprintf('stable at any speed below %.2f mm depth of cut\n', 1000*min(blim));
fprintf('the first lobe peaks near %.0f rpm\n', rpm(1, 1));

hold on;
for lobe = 1:4
    plot(rpm(:, lobe), 1000*blim);
end
xlim([2000 14000]);
ylim([0 12]);
title('Stability lobes, one spindle mode');
xlabel('Spindle speed (rpm)');
ylabel('Limiting depth of cut (mm)');
