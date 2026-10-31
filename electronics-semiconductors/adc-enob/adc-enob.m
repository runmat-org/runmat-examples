% A 12-bit ADC at 1 MS/s, characterized from a coherently sampled sine
% (IEEE 1241 style): SINAD, ENOB and SFDR from one FFT.
% The captured codes come from adc_capture at the end of the file.
fs = 1e6;  N = 4096;  cycles = 127;        % rate, record length, sine cycles
codes = adc_capture(fs, N, cycles);
X = abs(fft(codes - mean(codes))) / (N/2);
P = X(1:N/2).^2;                           % one-sided power
k = cycles + 1;                            % the tone's bin, no leakage
signal = P(k);
rest = sum(P) - signal - P(1);             % noise plus distortion
sinad = 10*log10(signal / rest);
enob = (sinad - 1.76) / 6.02;
spurs = P;  spurs(k) = 0;  spurs(1) = 0;
sfdr = 10*log10(signal / max(spurs));
fprintf('SINAD %.1f dB, ENOB %.2f bits\n', sinad, enob);
fprintf('SFDR %.1f dB\n', sfdr);

f = (0:N/2 - 1)' * fs / N / 1000;
dbfs = 10*log10(P / signal + 1e-20);
plot(f, dbfs);
ylim([-140 5]);
title('Output spectrum, 12-bit ADC, 31 kHz tone');
xlabel('Frequency (kHz)');
ylabel('Power relative to the tone (dB)');

function codes = adc_capture(fs, N, cycles)
% A near-full-scale tone into a 12-bit converter, with a little third-harmonic
% distortion and input noise, rounded to codes.
t = (0:N - 1)' / fs;  f0 = cycles * fs / N;
rng(11);
v = 0.97*sin(2*pi*f0*t) + 0.0004*sin(2*pi*3*f0*t) + 0.00012*randn(N, 1);
codes = round((v + 1) / 2 * 4095);
end
