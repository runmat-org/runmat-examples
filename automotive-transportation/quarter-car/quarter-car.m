% Ride on an ISO 8608 class C road at 72 km/h: body acceleration RMS of a quarter car
% against damping, from the road spectrum and the frequency response.
ms = 290;  mu = 15;  ks = 16200;  kt = 191000;  V = 20;      % kg, kg, N/m, N/m, m/s
Gd0 = 256e-6;  n0 = 0.1;                                    % class C at 0.1 cycles/m
f = linspace(0.1, 50, 4000)';  s = 1i*2*pi*f;
Gz = Gd0 * (f/V/n0).^(-2) / V;                              % road input PSD (m^2/Hz)
damping = linspace(500, 3000, 26);
rms = zeros(size(damping));
for j = 1:numel(damping)
    c = damping(j);
    den = (ms*s.^2 + c*s + ks).*(mu*s.^2 + c*s + ks + kt) - (c*s + ks).^2;
    H = s.^2 .* kt.*(c*s + ks) ./ den;
    rms(j) = sqrt(trapz(f, abs(H).^2 .* Gz));
end
[best, k] = min(rms);
fprintf('lowest body acceleration %.2f m/s^2 RMS at %.0f N s/m\n', best, damping(k));
fprintf('%.2f m/s^2 at 3,000 N s/m\n', rms(end));

plot(damping, rms, 'LineWidth', 2);
title('Body acceleration against damping, class C road');
xlabel('Damping (N s/m)');
ylabel('Body acceleration (m/s^2 RMS)');
