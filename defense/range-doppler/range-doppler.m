% Range-Doppler map of an X-band pulse-Doppler radar: 64 pulses of a 10 us chirp,
% matched-filtered in range and transformed across pulses into closing speed.
% Two moving targets, one stationary target and ground clutter at zero speed.
c = 3e8;  fc = 10e9;  lambda = c / fc;       % X band
fs = 20e6;  T = 10e-6;  B = 5e6;              % sample rate, pulse width, chirp bandwidth
prf = 10e3;  M = 64;  nfast = 1024;           % pulses and range samples per pulse
t = (0:round(T*fs)-1)' / fs;
pulse = exp(1i*pi*(B/T)*(t - T/2).^2);

R0 = [3000; 4200; 4300];                      % target ranges (m)
v = [56; -35; 0];                             % range rate (m/s); negative is closing
amp = [1; 0.6; 2];
rng(2);
X = 0.3 * (randn(nfast, M) + 1i*randn(nfast, M));
clutter = ifft(fft(0.012 * (randn(nfast, 1) + 1i*randn(nfast, 1))) .* fft(pulse, nfast));
X = X + repmat(clutter, 1, M);
for m = 1:M
    for q = 1:numel(R0)
        R = R0(q) + v(q) * (m - 1) / prf;
        d = round(2*R/c*fs);
        idx = (d+1:d+numel(pulse))';
        X(idx, m) = X(idx, m) + amp(q) * pulse * exp(-1i*4*pi*R/lambda);
    end
end

% Matched filter (Hamming-weighted) along range, then a Doppler FFT across pulses.
H = conj(fft(pulse .* hamming(numel(pulse)), nfast));
Y = ifft(fft(X) .* repmat(H, 1, M));
RD = fftshift(fft(Y .* repmat(hann(M)', nfast, 1), [], 2), 2);
P = 20*log10(abs(RD) / max(abs(RD(:))));
range_km = (0:nfast-1)' * c / (2*fs) / 1000;
closing = (-M/2:M/2-1) * prf / M * lambda / 2;    % closing speed (m/s)

shown = find(range_km >= 2.5 & range_km <= 5);
imagesc([closing(1) closing(end)], [range_km(shown(1)) range_km(shown(end))], P(shown, :));
axis xy;
xlim([-70 70]); xticks(-60:20:60);
ylim([2.5 5]);
clim([-50 0]);
colorbar;
title('Range-Doppler map');
xlabel('Closing speed (m/s)');
ylabel('Range (km)');

% Measured: the strongest cell, then the strongest moving cells outside it.
[~, k] = max(P(:));
[r1, c1] = ind2sub(size(P), k);
moving = P;
moving(:, abs(closing) < 5) = -Inf;
[~, k] = max(moving(:));
[r2, c2] = ind2sub(size(P), k);
moving(max(r2-20, 1):min(r2+20, nfast), :) = -Inf;
[~, k] = max(moving(:));
[r3, c3] = ind2sub(size(P), k);
fprintf('stationary target at %.2f km, %.0f m/s\n', range_km(r1), abs(closing(c1)));
way = {'opening', 'closing'};
fprintf('moving targets: %.2f km %s at %.0f m/s, %.2f km %s at %.0f m/s\n', range_km(r2), way{(closing(c2) > 0) + 1}, abs(closing(c2)), range_km(r3), way{(closing(c3) > 0) + 1}, abs(closing(c3)));
