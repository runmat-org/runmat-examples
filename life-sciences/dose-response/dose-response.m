% A four-parameter Hill fit to a dose-response assay (eight doses, triplicates),
% giving the EC50 and the Hill slope.
rng(9);
dose = repmat(logspace(-2, 2, 8), 3, 1);  dose = dose(:);
hill = @(p, x) p(1) + (p(2) - p(1)) ./ (1 + (p(3) ./ x).^p(4));
truth = [5 95 1.8 1.3];
resp = hill(truth, dose) + 4*randn(size(dose));
p = lsqcurvefit(hill, [0 100 1 1], dose, resp);
fprintf('EC50 %.2f uM (true %.2f), Hill slope %.2f (true %.2f)\n', p(3), truth(3), p(4), truth(4));
fprintf('bottom %.1f%%, top %.1f%% response\n', p(1), p(2));

xx = logspace(-2, 2, 200);
semilogx(dose, resp, 'o', xx, hill(p, xx));
legend('Measured', 'Hill fit');
title('Dose-response');
xlabel('Dose (uM)');
ylabel('Response (%)');
