function pressure = gaussianPulse(time, peak, center, width)
arguments
    time (:,1) double
    peak (1,1) double
    center (1,1) double
    width (1,1) double
end

z = (time - center) ./ width;
pressure = peak .* exp(-0.5 .* z .* z);
end
