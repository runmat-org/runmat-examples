% Fit a degree-9 polynomial three ways; the normal equations square the condition number
t = (0:0.02:1)';
y = cos(4*t) + 0.01*randn(size(t));
A = t .^ (0:9);

c1 = (A' * A) \ (A' * y);         % normal equations
c2 = A \ y;                        % QR, through backslash
c3 = pinv(A) * y;                  % SVD

fprintf('cond(A) = %.1e, cond(A''*A) = %.1e\n', cond(A), cond(A' * A));
fprintf('Off from QR: normal equations %.1e, pinv %.1e\n', norm(c1 - c2), norm(c3 - c2));

plot(t, y, '.');
hold on;
plot(t, A*c2);
legend('data', 'degree-9 fit');
title('Least-squares polynomial fit');
xlabel('t');
ylabel('y');
