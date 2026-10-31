% Prepare a timestamped sensor export, then compute its FFT
% sensor_log.csv has columns: time_s, acceleration_g

data = readmatrix('sensor_log.csv', 'NumHeaderLines', 1);
t_recorded = data(:, 1);
x_recorded = data(:, 2);

% Inspect the export before treating it as uniformly sampled.
sample_intervals = diff(t_recorded);
nominal_dt = median(sample_intervals);
nominal_dt = nominal_dt(1);
sample_rate_hz = round(1 / nominal_dt);
sample_rate_hz = sample_rate_hz(1);
timestamp_gap_count = sum(sample_intervals > 1.5 * nominal_dt);
timestamp_gap_count = timestamp_gap_count(1);
missing_value_count = sum(isnan(x_recorded));
missing_value_count = missing_value_count(1);

% Interpolate valid measurements onto a uniform time grid.
valid_samples = ~isnan(x_recorded);
uniform_sample_count = round((t_recorded(end) - t_recorded(1)) / nominal_dt) + 1;
uniform_sample_count = uniform_sample_count(1);
t = linspace(t_recorded(1), t_recorded(end), uniform_sample_count)';
x = interp1(t_recorded(valid_samples), x_recorded(valid_samples), t, 'linear');
prepared_sample_count = length(x);

% Use an even sample count so DC and Nyquist scaling is explicit.
if mod(prepared_sample_count, 2) ~= 0
    t = t(1:end-1);
    x = x(1:end-1);
end

N = length(x);
x = x - mean(x);
Y = fft(x);
two_sided_amplitude = abs(Y) / N;
single_sided_amplitude = two_sided_amplitude(1:N/2+1);
single_sided_amplitude(2:end-1) = 2 * single_sided_amplitude(2:end-1);
frequency_hz = sample_rate_hz * (0:N/2) / N;

fprintf('Sample rate: %.0f Hz\n', sample_rate_hz);
fprintf('Gaps fixed: %d timestamp gap, %d missing value\n', timestamp_gap_count, missing_value_count);

subplot(3, 1, 1);
plot(t_recorded, x_recorded);
title('Recorded CSV data');
xlabel('Time (s)');
ylabel('Acceleration (g)');

subplot(3, 1, 2);
plot(t, x);
title('Prepared uniform signal');
xlabel('Time (s)');
ylabel('Acceleration (g)');

subplot(3, 1, 3);
plot(frequency_hz, single_sided_amplitude);
title('Single-sided amplitude spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude (g)');
