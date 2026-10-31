% A 4-cylinder run-up from 1,000 to 6,000 rpm: the vibration signal resampled to shaft
% angle, so the engine orders stand still in the spectrum.
fs = 10000;  t = (0:1/fs:10)';
rpm = 1000 + 500*t;  phase = 2*pi*cumtrapz(t, rpm/60);
rng(5);
x = sin(2*phase) + 0.3*sin(4*phase) + 0.2*sin(2*pi*350*t) + 0.2*randn(size(t));
ppr = 64;  revs = floor(phase(end)/(2*pi));
theta = (0:revs*ppr - 1)' * 2*pi/ppr;
xa = interp1(phase, x, theta);
X = 2*abs(fft(xa)) / numel(xa);  order = (0:numel(xa) - 1)' / revs;
lo = round(1.5*revs) + 1;  hi = round(2.5*revs) + 1;
[~, j] = max(X(lo:hi));
fprintf('%d revolutions resampled at %d points each\n', revs, ppr);
fprintf('largest order %.2f, the firing order of a 4-cylinder\n', order(lo + j - 1));

show = order < 8;
plot(order(show), X(show));
title('Order spectrum, 1,000 to 6,000 rpm run-up');
xlabel('Engine order');
ylabel('Amplitude');
