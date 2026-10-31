% The NREL 5-MW reference turbine's tower against rotor (1P) and blade-passing (3P)
% excitation. Values from Jonkman et al. (2009), NREL/TP-500-38060, Table 6-1.
H = 87.6;  top = 110000 + 240000;                % tower height (m); rotor and nacelle (kg)
frac = (0:0.1:1)';
mden = [5590.87 5232.43 4885.76 4550.87 4227.75 3916.41 3616.83 3329.03 3053.01 2788.75 2536.27]';
EI = 1e9 * [614.34 534.82 463.27 399.13 341.88 291.01 246.03 206.46 171.85 141.78 115.82]';
ne = 30;  L = H / ne;  mid = ((1:ne)' - 0.5) / ne;
m = interp1(frac, mden, mid);  k = interp1(frac, EI, mid);
K = zeros(2*ne + 2);  M = zeros(2*ne + 2);
for e = 1:ne
    ke = k(e)/L^3 * [12 6*L -12 6*L; 6*L 4*L^2 -6*L 2*L^2; -12 -6*L 12 -6*L; 6*L 2*L^2 -6*L 4*L^2];
    me = m(e)*L/420 * [156 22*L 54 -13*L; 22*L 4*L^2 13*L -3*L^2; 54 13*L 156 -22*L; -13*L -3*L^2 -22*L 4*L^2];
    d = (2*e - 1:2*e + 2)';
    K(d, d) = K(d, d) + ke;  M(d, d) = M(d, d) + me;
end
M(end-1, end-1) = M(end-1, end-1) + top;
free = (3:2*ne + 2)';
f1 = sqrt(min(eig(K(free, free), M(free, free)))) / (2*pi);
fprintf('first tower mode %.3f Hz (report: 0.324 Hz, full turbine model)\n', f1);
fprintf('1P reaches %.3f Hz at 12.1 rpm; 3P starts at %.3f Hz at 6.9 rpm\n', 12.1/60, 3*6.9/60);

rpm = 0:0.1:14;
plot(rpm, rpm/60, 'LineWidth', 2);
hold on;
plot(rpm, 3*rpm/60, 'LineWidth', 2);
plot(rpm, f1 * ones(size(rpm)), '--', 'LineWidth', 2);
plot([6.9 6.9], [0 0.7], ':');
plot([12.1 12.1], [0 0.7], ':');
legend('1P', '3P', 'Tower first mode', 'Cut-in', 'Rated');
title('Tower frequency against rotor excitation');
xlabel('Rotor speed (rpm)');
ylabel('Frequency (Hz)');
