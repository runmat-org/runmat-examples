% Flight test: equipment-shelf vibration at three test points against the
% GEVS component qualification limit (GSFC-STD-7000B, 14.1 g RMS).
fs = 4096;                          % accelerometer sample rate (Hz)
T = 30;                             % seconds recorded per test point
n = fs * T;
points = {'Takeoff roll', 'Climb', 'Cruise'};
levels = [1.0, 0.55, 0.25];         % relative broadband level per test point
rng(7);

% A shelf mode near 180 Hz shapes the broadband input from the airframe.
[bs, as] = butter(2, [150 210] / (fs/2), 'bandpass');
[bh, ah] = butter(4, [20 1500] / (fs/2), 'bandpass');

fig = figure;
grms = zeros(1, 3);
colors = [0.94 0.45 0.20; 0.31 0.55 1.00; 0.20 0.70 0.45];
for k = 1:3
    w = randn(n, 1);
    a = 5.6 * levels(k) * (filter(bh, ah, w) + 1.3 * filter(bs, as, w));
    a = a + 0.4 * levels(k) * sin(2*pi*112*(0:n-1)' / fs);   % propeller blade pass
    [p, f] = pwelch(a, hann(4096), 2048, 4096, fs);
    keep = f >= 20 & f <= 2000;
    loglog(f(keep), p(keep), 'LineWidth', 1.4, 'Color', colors(k, :));
    hold on;
    grms(k) = sqrt(trapz(f(keep), p(keep)));
    if k == 1
        fk = f(keep);  pk = p(keep);
        lim = 0.16 * ones(size(fk));
        lim(fk < 50) = 0.026 * (fk(fk < 50) / 20).^2;
        lim(fk > 800) = 0.16 * (fk(fk > 800) / 800).^(-2);
        [margin, at] = min(10 * log10(lim ./ pk));
        margin_hz = fk(at);
    end
end

% GEVS component qualification limit (g^2/Hz).
fl = [20 50 800 2000];
pl = [0.026 0.16 0.16 0.026];
loglog(fl, pl, 'LineWidth', 2, 'Color', [0.55 0.58 0.65]);

legend(sprintf('%s  %.1f g', points{1}, grms(1)), ...
       sprintf('%s  %.1f g', points{2}, grms(2)), ...
       sprintf('%s  %.1f g', points{3}, grms(3)), ...
       'Limit  14.1 g', 'Location', 'southwest');
title('Shelf vibration by test point');
xlabel('Frequency (Hz)'); ylabel('PSD (g^2/Hz)');
xlim([20 2000]); ylim([1e-5 1]);
grid on;
fprintf('takeoff roll %.1f g RMS, climb %.1f, cruise %.1f\n', grms);
fprintf('smallest margin to the limit: %.1f dB at %.0f Hz\n', margin, margin_hz);
