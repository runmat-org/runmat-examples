% Detection range against radar cross-section from the radar range equation, for an
% X-band radar integrating 64 pulses coherently. The signal-to-noise needed for a 90%
% probability of detection at a 1e-6 false-alarm rate comes from Albersheim's equation.
c = 3e8;  k = 1.38e-23;
Pt = 10e3;  G = 10^(35/10);  fc = 10e9;  lambda = c / fc;
tau = 10e-6;  B = 5e6;  T0 = 290;  F = 10^(4/10);  L = 10^(6/10);
npulses = 64;
pd = 0.9;  pfa = 1e-6;

A = log(0.62 / pfa);  Bp = log(pd / (1 - pd));
snr_req = (6.2 + 4.54/sqrt(1 + 0.44)) * log10(A + 0.12*A*Bp + 1.7*Bp);   % dB, one pulse (Albersheim)
snr_need = 10^(snr_req/10) / npulses;                % after coherent integration of 64 pulses

% R^4 = Pt G^2 lambda^2 sigma (tau B) / ((4 pi)^3 k T0 F B L SNR), with tau*B the compression gain
rcs = logspace(-3, 1, 200);
R = (Pt * G^2 * lambda^2 .* rcs * tau / ((4*pi)^3 * k * T0 * F * L * snr_need)).^(1/4);

loglog(rcs, R / 1000);
xlim([1e-3 10]); ylim([1 100]);
title('Detection range against target size');
xlabel('Radar cross-section (m^2)');
ylabel('Detection range (km)');

R1 = interp1(rcs, R, 1);  R01 = interp1(rcs, R, 0.01);
fprintf('Pd 0.9 at Pfa 1e-6 needs %.1f dB from one pulse, %.1f dB per pulse when 64 are integrated\n', snr_req, snr_req - 10*log10(npulses));
fprintf('detects a 1 m^2 target at %.1f km and a 0.01 m^2 small drone at %.1f km\n', R1/1000, R01/1000);
