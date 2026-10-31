% Shock response spectrum of a pyroshock-like transient (Q = 10, maximax).
% Each natural frequency is a single-degree-of-freedom filter driven by the
% base acceleration, using Smallwood's ramp-invariant coefficients.
fs = 102400;  dt = 1 / fs;
t = (0:dt:0.02)';
rng(5);

% A sum of decaying tones, as measured near a separation event (g).
f0 = [450 1200 2600 4800 7300];
amp = [180 420 650 520 300];
base = zeros(size(t));
for k = 1:numel(f0)
    base = base + amp(k) * exp(-t / 0.0025) .* sin(2*pi*f0(k)*t + 2*pi*rand());
end

Q = 10;  zeta = 1 / (2 * Q);
fn = logspace(2, 4, 60);
srs = zeros(size(fn));
for i = 1:numel(fn)
    wn = 2 * pi * fn(i);
    wd = wn * sqrt(1 - zeta^2);
    E = exp(-zeta * wn * dt);  K = wd * dt;  C = E * cos(K);  S = E * sin(K);  Sp = S / K;
    b = [1 - Sp, 2 * (Sp - C), E^2 - Sp];
    a = [1, -2 * C, E^2];
    srs(i) = max(abs(filter(b, a, base)));
end

[peak, at] = max(srs);
fig = figure;
loglog(fn, srs, 'LineWidth', 2, 'Color', [0.31 0.55 1.00]); hold on;
loglog([100 10000], [1 1] * max(abs(base)), 'LineWidth', 1.4, 'Color', [0.55 0.58 0.65]);
legend('SRS, Q = 10', 'Peak input');
title('Shock response spectrum');
xlabel('Natural frequency (Hz)'); ylabel('Peak acceleration (g)');
xlim([100 10000]); grid on;
fprintf('peak input %.0f g\n', max(abs(base)));
fprintf('SRS peak %.0f g at %.0f Hz\n', peak, fn(at));
