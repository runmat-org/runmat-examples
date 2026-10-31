% Beam pattern of a 16-element half-wavelength array steered to 20 degrees, uniform
% weights against a Hamming taper: the taper trades a wider beam for lower sidelobes.
N = 16;  d = 0.5;                            % elements, spacing in wavelengths
steer = 20;
theta = (-90:0.1:90)';
n = (0:N-1)';
A = exp(1i*2*pi*d*n*sind(theta'));           % steering vectors, one column per angle
s = exp(1i*2*pi*d*n*sind(steer));
uniform = abs((s / N)' * A)';
tapered = abs((hamming(N) .* s / sum(hamming(N)))' * A)';
gu = 20*log10(uniform / max(uniform));
gt = 20*log10(tapered / max(tapered));

plot(theta, gu, theta, gt);
xlim([-90 90]); xticks(-90:30:90); ylim([-60 0]);
legend('Uniform', 'Hamming taper');
title('16-element array steered to 20 deg');
xlabel('Angle (deg)');
ylabel('Gain (dB)');

% Measured: pointing and beamwidth of the tapered beam; peak sidelobe of each.
[~, k] = max(gt);
main = theta(gt > -3);
first_null_u = 2*asin(1/(N*d))*180/pi / cosd(steer);   % main-lobe width to first nulls, uniform
side_u = max(gu(abs(theta - steer) > first_null_u/2 + 1));
side_t = max(gt(abs(theta - steer) > first_null_u + 2));
fprintf('tapered beam points at %.1f deg, 3 dB width %.1f deg\n', theta(k), max(main) - min(main));
fprintf('peak sidelobe %.1f dB uniform, %.1f dB with the Hamming taper\n', side_u, side_t);
