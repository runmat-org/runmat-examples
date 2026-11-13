# Design notes: disc cam

## Motion law
- The follower rises over 150 deg, dwells 30 deg at full lift, returns over 150 deg and dwells 30 deg on the base circle.
- Rise and return use the cycloidal law `s(u) = u - sin(2πu)/(2π)`. Its velocity and acceleration are zero at both ends of each segment, so the follower has no jerk spike where the segments meet. This suits moderate-speed machinery where the follower spring has to hold contact through the return.

## Base circle and pressure angle
- A cycloidal rise of lift `h` over `β` radians peaks in slope at mid-rise, at `ds/dθ = 2h/β`.
- For a translating roller follower with no offset, the pressure angle there is `tan φ = (ds/dθ) / (r_b + s)` with `s = h/2`.
- `camBaseRadius.m` solves that for the smallest base radius `r_b` that keeps `φ` at the limit (30 deg by default, a common limit for translating followers).
- At 8 mm of lift over 150 deg, the pitch-curve base radius is 6.6 mm. A real cam adds the roller radius and a hub, so this part models the pitch curve.

## Profile
- The profile is a closed spline through the pitch radius at 12 stations, 30 deg apart.
- Twelve stations follow the cycloidal rise within a few percent of area. The test that ships with the part checks the extruded volume against the motion law's pitch-curve prism within 5 %.
- More stations give a closer fit at the cost of regeneration time.

## Thickness
- 10 mm wide, set by `thickness`. Size it from the contact stress between roller and cam, which this part doesn't compute.
