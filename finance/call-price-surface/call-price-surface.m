% Black-Scholes call price across spot and time to expiry
K = 100;  r = 0.03;  sigma = 0.25;
[S, T] = meshgrid(60:2:140, 0.05:0.05:2);
C = blsprice(S, K, r, T, sigma);

surf(S, T, C);
shading interp;
colormap('turbo');
colorbar;
title('Call price');
xlabel('Spot');
ylabel('Years to expiry');
zlabel('Price');
view(-35, 28);

fprintf('At the money, one year: %.2f\n', blsprice(100, K, r, 1, sigma));
fprintf('Spot 140, two years: %.2f\n', blsprice(140, K, r, 2, sigma));
