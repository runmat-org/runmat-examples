% Heart-rate variability from two minutes of ECG: find the R peaks, take the beat-to-beat
% intervals, and compute SDNN and RMSSD. Breathing at 15 a minute modulates the rate.
rng(1);
fs = 250;  T = 120;  t = (0:1/fs:T-1/fs)';
rr = 0.85 + 0.05*sin(2*pi*0.25*(1:200)') + 0.02*randn(200, 1);
beats = cumsum(rr);  beats = beats(beats < T);
ecg = zeros(size(t));
for k = 1:numel(beats)
    ecg = ecg + exp(-((t - beats(k))/0.012).^2);
end
ecg = ecg + 0.05*randn(size(t));
% R peaks: local maxima above 0.6, at least 0.3 s apart.
mid = ecg(2:end-1);
cand = find(mid > ecg(1:end-2) & mid >= ecg(3:end) & mid > 0.6) + 1;
keep = true(size(cand));  last = -Inf;
for k = 1:numel(cand)
    if t(cand(k)) - last < 0.3
        keep(k) = false;
    else
        last = t(cand(k));
    end
end
r = t(cand(keep));
nn = diff(r);
fprintf('%d beats, mean heart rate %.1f per minute\n', numel(r), 60/mean(nn));
fprintf('SDNN %.1f ms, RMSSD %.1f ms\n', 1000*std(nn), 1000*rms(diff(nn)));

plot(r(2:end), 1000*nn);
title('Beat-to-beat intervals');
xlabel('Time (s)');
ylabel('RR interval (ms)');
