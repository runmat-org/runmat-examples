% Random vibration qualification: the GEVS component spectrum applied at the
% bracket's mounting face, and the response of its first mode (180 Hz, Q = 10).
f = logspace(log10(20), log10(2000), 800)';

% Input acceleration PSD (g^2/Hz): +6 dB/oct to 50 Hz, 0.16 flat to 800 Hz, -6 dB/oct to 2000 Hz.
in = zeros(size(f));
lo = f < 50;  mid = f >= 50 & f <= 800;  hi = f > 800;
in(lo)  = 0.026 * (f(lo) / 20).^2;
in(mid) = 0.16;
in(hi)  = 0.16 * (f(hi) / 800).^(-2);

% Base-excited single mode: transmissibility squared.
fn = 180;  Q = 10;  zeta = 1 / (2 * Q);
r = f / fn;
H2 = (1 + (2*zeta*r).^2) ./ ((1 - r.^2).^2 + (2*zeta*r).^2);
out = H2 .* in;

grms_in  = sqrt(trapz(f, in));
grms_out = sqrt(trapz(f, out));
grms_miles = sqrt(pi / 2 * fn * Q * 0.16);

fig = figure;
loglog(f, in,  'LineWidth', 1.8, 'Color', [0.55 0.58 0.65]); hold on;
loglog(f, out, 'LineWidth', 2.0, 'Color', [0.31 0.55 1.00]);
legend(sprintf('Input  %.1f g RMS', grms_in), sprintf('Response  %.1f g RMS', grms_out));
title('Random vibration qualification');
xlabel('Frequency (Hz)'); ylabel('PSD (g^2/Hz)');
xlim([20 2000]); ylim([1e-3 100]);
grid on;
fprintf('input %.1f g RMS, response %.1f g RMS\n', grms_in, grms_out);
fprintf('Miles'' equation %.1f g RMS, 3-sigma peak %.0f g\n', grms_miles, 3 * grms_miles);
