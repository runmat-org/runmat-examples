% Band-pass an amplitude-modulated carrier, then recover envelope and frequency
Fs = 8000;
t = 0:1/Fs:0.25-1/Fs;
msg = 0.5 + 0.4*sin(2*pi*20*t);
x = msg .* sin(2*pi*1000*t) + 0.05*randn(size(t));

N = 65;
bLow = fir1(N-1, 1200/(Fs/2), 'low');
bHigh = fir1(N-1, 800/(Fs/2), 'low');
b = bLow - bHigh;                 % band-pass as the difference of two low-pass designs
xb = filter(b, 1, x);

z = hilbert(xb);
env = abs(z);
phase = unwrap(angle(z));
instFreq = diff(phase) * Fs / (2*pi);

% Ignore the filter's start-up and the transform's edges
mid = 200:numel(env) - 200;
fprintf('Envelope: %.2f to %.2f (message 0.10 to 0.90)\n', min(env(mid)), max(env(mid)));
fprintf('Carrier: %.0f Hz (median instantaneous frequency)\n', median(instFreq(mid)));

subplot(3, 1, 1);
plot(t, x);
title('Modulated carrier with noise');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(t, xb);
hold on;
plot(t, env);
legend('band-passed', 'envelope');
title('Band-passed carrier and its envelope');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(t(2:end), instFreq);
ylim([800 1200]);
xlabel('Time (s)');
ylabel('Hz');
title('Instantaneous frequency');
