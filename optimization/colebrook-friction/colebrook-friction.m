% Pipe friction factor from the Colebrook equation, solved with fzero, across
% Reynolds numbers and wall roughness: a small Moody chart
colebrook = @(f, Re, rr) 1/sqrt(f) + 2*log10(rr/3.7 + 2.51/(Re*sqrt(f)));

[fd, ~, ~, out] = fzero(@(f) colebrook(f, 1e5, 1e-4), [0.005 0.1]);
fprintf('Re = 1e5, relative roughness 1e-4: f = %.5f after %d evaluations\n', fd, out.funcCount);
fh = 1/(-1.8*log10((1e-4/3.7)^1.11 + 6.9/1e5))^2;
fprintf('Haaland explicit approximation: f = %.5f\n', fh);

Re = logspace(3.6, 8, 60);
roughness = [1e-5 1e-4 1e-3 1e-2];
f = zeros(numel(roughness), numel(Re));
for i = 1:numel(roughness)
    for j = 1:numel(Re)
        f(i, j) = fzero(@(x) colebrook(x, Re(j), roughness(i)), [0.004 0.2]);
    end
end
loglog(Re, f, 'LineWidth', 1.5);
legend('roughness 1e-5', '1e-4', '1e-3', '1e-2');
xlabel('Reynolds number');
ylabel('Darcy friction factor');
title('Colebrook friction factor, one fzero call per point');
grid on;
