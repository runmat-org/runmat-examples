% An outer-race fault on a 6205 bearing at 1,797 rpm, in the envelope spectrum.
% The accelerometer signal comes from test_signal at the end of the file.
fs = 12000;  fr = 1797/60;                % sample rate, shaft speed (Hz)
n = 9;  d = 7.94;  D = 39.04;  phi = 0;   % balls; ball and pitch diameter (mm)
bpfo = n/2 * fr * (1 - d/D*cos(phi));
x = test_signal(fs, fr, bpfo);

% Band-pass around the resonance, take the envelope, then its spectrum.
[b, a] = butter(4, [2000 4000]/(fs/2));
env = abs(hilbert(filtfilt(b, a, x)));
E = abs(fft(env - mean(env))) / numel(env);
f = (0:numel(env)-1)' * fs / numel(env);
inband = E;
inband(f < 50 | f > 300) = 0;
[~, j] = max(inband);
fprintf('outer-race defect frequency %.1f Hz from the bearing geometry\n', bpfo);
fprintf('envelope spectrum peaks at %.1f Hz\n', (j - 1) * fs / numel(env));

show = f < 500;
plot(f(show), 1000*E(show));
top = double(1000*max(E(show)));
hold on;
for h = 1:4
    plot(horzcat(h*bpfo, h*bpfo), horzcat(0, top), '--');
end
title('Envelope spectrum, outer-race fault');
xlabel('Frequency (Hz)');
ylabel('Envelope amplitude (milli-g)');

function x = test_signal(fs, fr, bpfo)
% Two seconds at 12 kHz: each impact rings a 3 kHz housing resonance, under shaft
% vibration and noise.
t = (0:1/fs:2)';
impacts = zeros(size(t));
hit = round((0:1/bpfo:2)' * fs) + 1;
impacts(hit(hit <= numel(t))) = 1;
tr = (0:1/fs:0.01)';
x = conv(impacts, exp(-1500*tr) .* sin(2*pi*3000*tr));
x = x((1:numel(t))') + 0.5*sin(2*pi*fr*t) + 0.3*randn(size(t));
end
