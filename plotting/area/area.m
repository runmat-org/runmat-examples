years = 2018:2025;
solar   = [5  8  12 18 25 33 42 50];
wind    = [10 14 18 22 28 32 36 40];
hydro   = [30 30 29 28 27 27 26 26];
mix = [solar; wind; hydro]';

area(years, mix);
title('Energy Generation Mix');
xlabel('Year');
ylabel('TWh');
legend('Solar', 'Wind', 'Hydro');
grid on;
