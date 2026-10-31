% A VAR(1) in inflation, the output gap and the policy rate, estimated by least
% squares on 400 quarters, and the responses to a policy-rate shock.
rng(5);
T = 400;
A = [0.7 0.1 -0.1; 0.2 0.8 -0.15; 0.3 0.2 0.8];
S = [0.3 0 0; 0.05 0.4 0; 0.05 0.05 0.2];
Y = zeros(T, 3);
for t = 2:T
    Y(t, :) = (A * Y(t-1, :)' + S * randn(3, 1))';
end
X = Y(1:end-1, :);
Ahat = (X \ Y(2:end, :))';
res = Y(2:end, :) - X * Ahat';
P = chol(cov(res), 'lower');
h = 20;
irf = zeros(h, 3);
shock = P(:, 3);
for k = 1:h
    irf(k, :) = shock';
    shock = Ahat * shock;
end
[low, when] = min(irf(:, 1));
fprintf('largest coefficient error %.3f against the true model\n', max(abs(Ahat(:) - A(:))));
fprintf('a rate shock lowers inflation most after %d quarters, by %.3f points\n', when - 1, -low);

q = (0:h-1)';
plot(q, irf(:, 1), q, irf(:, 2), q, irf(:, 3));
yline(0);
legend('Inflation', 'Output gap', 'Policy rate');
title('Responses to a policy-rate shock');
xlabel('Quarters');
ylabel('Percentage points');
