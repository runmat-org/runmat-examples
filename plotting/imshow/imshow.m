[X, Y] = meshgrid(linspace(-3, 3, 220), linspace(-2, 2, 150));
field = exp(-0.8*((X-1).^2 + Y.^2)) - 0.7*exp(-((X+1).^2 + (Y-0.4).^2));

imshow(field, []);
title('Autoscaled Grayscale Field');
