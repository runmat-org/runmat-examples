# Multi-drone SLAM

Four drones fly over mountain terrain that none of them has a map of. Each drone scans the ground below it with a spinning LIDAR and adds the hits to a shared point-cloud map. The drones place those points using their own odometry, which drifts, so the map smears as the run goes on. When a drone comes back within 15 m of track that is already mapped, it detects a loop closure. A sparse least-squares solve over every drone's pose history then corrects all four trajectories at once, and the map snaps back into alignment.

Press Run to watch the finished run play back: the drones fly their routes at 15 simulation steps per second, the map fills in behind them, and it snaps into place when the pose graph is solved. Drag the 3D map to orbit it and scroll to zoom while it plays. Playback of the 180 steps takes about 12 seconds. Simulating them takes about a minute in the browser, so the project computes a run once, saves it and plays the saved copy until the simulation code changes.

## Entry points

`runmat.toml` declares two entry points. The Run button runs `main`.

| Entry point | Script | What it does |
| --- | --- | --- |
| `main` | `main/multi_drone_slam.m` | Plays the saved run in `results/slam_run.mat`. If the simulation code or the step count changed since that file was saved, or the file is missing, it simulates first, saves the new run and then plays it. |
| `simulate` | `main/simulate_slam.m` | Always simulates, saves the run to `results/slam_run.mat` and plays it. |

While it simulates, the console prints a line per stage and one every 30 LIDAR steps, each with the time since the run started. Then it prints the run report: the terrain size, the number of rays cast and hit, the number of map points and loop closures, one line per correction event with the mean position error before and after the solve, the final coverage and the simulation time. Playback of a saved run prints the report saved with it.

Changes to the drawing code (`graphics/`, `playback/`) or to the playback settings never need a new simulation: the next run plays the saved results with the new drawing.

### How the saved run is matched

`playback/slam_run_key.m` computes a key from the step count and from the name and text of every file that decides the result: `main/slam_config.m`, `main/slam_simulate.m` and the `.m` files in `terrain/`, `flight/`, `sensors/` and `slam/`. A simulating run stores the key in the saved run (`S.key`). Before playing, `main/multi_drone_slam.m` computes the key again and plays the file only when the two keys match. When they differ, the console prints both.

The key is a checksum: two 31-bit sums of the character codes, computed in exact integer arithmetic, so it comes out the same on every machine. Carriage returns are dropped before hashing, so a file saved with Windows line endings keeps its key. The key does not cover the RunMat version; after a RunMat upgrade, run `simulate` to refresh the saved results.

### Playback

`playback/slam_play.m` builds the three figures once (`graphics/slam_scene.m`) and then changes only the data of the moving objects (`graphics/slam_scene_step.m`), so the camera of figure 1 stays wherever the viewer puts it. The pace follows the wall clock. Playback draws up to 10 frames per second, and each frame shows the step that is due at that moment: step $f$ is due $(f - 1)/15$ seconds after playback starts. When a frame takes longer to draw, the next frame skips ahead to the step that is due, so the 180 steps always take 12 seconds. After the last step, `graphics/slam_scene_finish.m` redraws the map as one `scatter3` cloud, the way `graphics/slam_draw.m` draws it. `rate` and `fps` in `main/slam_settings.m` set the pace and the frame rate.

The figures redraw while the script pauses, so every frame pauses for at least 40 ms (`minPause`). RunMat shows live changes only for the current figure, so figure 1 stays current during playback; figures 2 and 3 show their curves when the run ends. The command-line runtime (`runmat run main/multi_drone_slam.m`) shows figures only when the script ends.

## Project layout

```
multi-drone-slam/
  runmat.toml     package, source folders and entry points
  README.md
  main/           entry points, settings and the simulation driver
  terrain/        procedural heightfield
  flight/         true routes, drifting odometry, dead reckoning
  sensors/        LIDAR ray marching
  slam/           loop closures, pose-graph solve, shown estimate
  graphics/       figures
  playback/       saved-run key, load or simulate, real-time playback
  results/        slam_run.mat, the saved run
```

`runmat.toml` lists each code folder as its own source root (`[sources] roots`), so any file calls a function in another folder by its plain name. Function names, including local functions, are unique across the project.

## What happens in a run

`main/slam_simulate.m` runs the stages in this order. Each stage lives in its own file.

1. `terrain/make_terrain.m` builds the heightfield.
2. `flight/fly_routes.m` computes the true trajectory of each drone.
3. `flight/make_odometry.m` produces the drifting motion measurements the drones report.
4. `sensors/cast_lidar.m` casts every LIDAR ray against the heightfield and records map points and coverage.
5. `slam/detect_closures.m` finds loop closures and groups them into correction events.
6. `slam/solve_pose_graph.m` solves the pose graph once per event.

All random draws come from `rng(20261103)` in that stage order, so the same number of steps always gives the same run.

## Terrain

The world is a 512 m square sampled on a 256 by 256 grid, so each cell is 2 m across. The heights come from two diamond-square fractals.

Diamond-square fills a grid by repeated midpoint refinement. It starts with one square the size of the grid. At each level it sets the center of every square to the mean of the square's four corners plus random noise, then sets the midpoint of every edge to the mean of its four neighbors plus noise. The squares then halve in size and the noise amplitude shrinks by a factor of $2^{-r}$, where $r$ is the roughness. A larger $r$ removes fine detail faster and gives smoother terrain. Indices wrap around the grid edges, so each fractal tiles seamlessly.

`make_terrain` draws a smooth field $B$ with $r = 0.62$ and a second field $S$ with $r = 0.48$, both scaled to $[0, 1]$. It folds $S$ into sharp ridges and blends the two:

$$
R = \bigl(1 - |2S - 1|\bigr)^{2.2}, \qquad H = 0.6\,B + 0.4\,R
$$

The fold turns the mid-level values of $S$ into crests. The blend is then smoothed with a 5 by 5 box filter, rescaled to $[0, 1]$ and shaped into heights:

$$
h = 110\,H^{1.35} \ \text{m}
$$

The exponent flattens the valleys and steepens the peaks. Heights run from 0 to 110 m. The returned grid has 257 by 257 samples, with the first row and column repeated at the far edges, and is indexed as `H(row = y, col = x)`.

## Truth trajectories

Each drone flies a series of petals from a launch pad. The four pads sit 7 m from the center of the world, one in each diagonal direction. A petal goes out along one leg, rounds a tip about 215 m from the pad and comes back along a second leg past the launch area.

Drone $d$ runs on its own clock $s = t - 6(d - 1)$, so the drones pass through the launch area 6 steps apart. Each petal lasts 140 steps. With the petal index $k = \lfloor s / 140 \rfloor$ and the phase $u = s/140 - k$ in $[0, 1)$, the position is

$$
\rho = 215 \sin(\pi u), \qquad
\phi = \phi_k - 0.2 \cos(\pi u), \qquad
(x, y) = \text{pad}_d + \rho\,(\cos\phi, \sin\phi)
$$

where the petal heading is $\phi_k = 90^\circ (d - 1) + 25^\circ k$. The radius $\rho$ grows from zero to 215 m and back over one petal. The angle $\phi$ swings from 0.2 rad on one side of the petal heading to 0.2 rad on the other, which separates the outbound and return legs. Each new petal turns 25 degrees, so it flies over new ground, and only the legs near the launch area cross earlier track.

The altitude is $z = 150 + 4d + 5 \sin(2\pi u)$ m, so the drones fly at slightly different heights with a gentle climb and descent over each petal. The yaw $\psi$ is the direction of travel, computed from the gradient of the path and unwrapped so that it changes continuously.

## Odometry and drift

A real drone estimates its motion from inertial and visual odometry, and those estimates drift. `make_odometry` simulates them from the truth. Over each step, drone $d$ moves by $(\Delta x, \Delta y)$. The simulated odometry adds a constant world-frame velocity bias $\mathbf{b}_d$, of 0.07 to 0.08 m per step, to that motion, the way an uncorrected wind would. It then rotates the result into the drone's body frame using the true yaw at the start of the step:

$$
\begin{aligned}
f &= \cos\psi\,(\Delta x + b_x) + \sin\psi\,(\Delta y + b_y) \\
\ell &= -\sin\psi\,(\Delta x + b_x) + \cos\psi\,(\Delta y + b_y)
\end{aligned}
$$

Here $f$ is the forward motion and $\ell$ the motion to the left. Each drone also gets a small scale error $\varepsilon_d$ of about 0.5 %, a yaw-rate bias $\beta_d$ of about $10^{-4}$ rad per step and white noise. The measured increments are

$$
\tilde f = (1 + \varepsilon_d) f + 0.03\,n_1, \qquad
\tilde \ell = \ell + 0.03\,n_2, \qquad
\widetilde{\Delta\psi} = \Delta\psi + \beta_d + 0.0008\,n_3
$$

with $n_i$ standard normal draws, distances in meters and angles in radians.

`flight/dead_reckon.m` integrates the increments from a known starting pose:

$$
\begin{aligned}
x_t &= x_{t-1} + \cos\psi_{t-1}\,\tilde f_t - \sin\psi_{t-1}\,\tilde \ell_t \\
y_t &= y_{t-1} + \sin\psi_{t-1}\,\tilde f_t + \cos\psi_{t-1}\,\tilde \ell_t \\
\psi_t &= \psi_{t-1} + \widetilde{\Delta\psi}_t
\end{aligned}
$$

The noise averages out, but the bias adds up step after step. A bias of 0.08 m per step puts a drone about 12 m off after 150 steps, and the error keeps growing until a correction.

## LIDAR ray marching

Each drone carries a LIDAR fan of 16 beams at elevations from $-60^\circ$ to $-87^\circ$, below the horizon, and 72 azimuths per revolution. That makes 1,152 rays per drone and 4,608 rays per step. The fan is fixed to the drone's yaw and spins an extra 0.21 rad each step. A ray at elevation $\theta$ and azimuth $\alpha$ points along

$$
\mathbf{u} = (\cos\theta\cos\alpha,\ \cos\theta\sin\alpha,\ \sin\theta)
$$

`cast_lidar` casts all 4,608 rays of a step at once from the drones' true poses. It samples each ray at distances $s_k = 2k$ m for $k = 1, \dots, 110$, a range of 220 m, and computes the height of each sample above the terrain:

$$
g_k = z_0 + u_z s_k - h(x_0 + u_x s_k,\ y_0 + u_y s_k)
$$

The terrain height $h$ is a bilinear interpolation of the four grid samples around the point. Points outside the world return a very low height, so a ray that leaves the world never hits. The first sample with $g_k < 0$ is below the ground. The code finds it for every ray with one `max` over the logical matrix `gap < 0`. It then refines the crossing by linear interpolation between that sample and the one before it:

$$
s^{*} = s_k - \Delta s + \Delta s\,\frac{g_{k-1}}{g_{k-1} - g_k}, \qquad \Delta s = 2 \ \text{m}
$$

The hit point is $\mathbf{p}_0 + s^{*}\mathbf{u}$. A ray with no sample below ground is a miss.

Each step also does three pieces of bookkeeping:

- **Coverage.** The world is divided into 2 m coverage cells. A cell counts as mapped once any ray hits it, and the coverage is the percentage of cells mapped so far.
- **Map points.** For each drone, 55 rays are kept at random, with hits preferred over misses. Each hit is stored in the drone's body frame, as an offset rotated by $-\psi$. Storing body-frame offsets lets the map be redrawn through any later pose estimate.
- **Drawn rays.** For each drone, 24 rays evenly spaced around the fan are kept for the figure. A miss is stored as NaN.

## Loop closures and sync events

A loop closure says that two poses saw the same place, so their relative position is known. `detect_closures` decides when a drone recognizes a place. It uses the true positions as a stand-in for a place-recognition front end with a range of 15 m.

At every step $t$, each drone compares its current position with every mapped pose, measuring distance in the horizontal plane. A pose counts as mapped when it is

- on another drone's track, at any step up to and including $t$, or
- on the drone's own track, at least 60 steps old.

The 60-step minimum age keeps a drone from matching the track it has just flown. If the nearest mapped pose is within 15 m, the step is even and $t > 60$, the code adds a closure edge between that pose and the current one. No closures are detected in the first 60 steps, while the drones leave the launch area together. If the nearest pose on another drone's track is also within 15 m and differs from the first match, a second edge links the two drones' graphs. Shared edges let a correction on one drone's track pull the other drones' tracks into line.

Closures are grouped into events:

1. The first closure detected more than 60 steps after the previous solve opens an event.
2. The pose-graph solve for the event runs 22 steps later. All closures detected up to that step are included.
3. A drone "pings" at its first detection in an event. Its partner is the first other drone it matched, or itself if it only matched its own track.

With the default parameters, the first event solves near step 156 and later events follow about every 140 steps, once per petal.

## The pose graph

At each event's solve step $t_e$, `solve_pose_graph` builds a graph over every pose of every drone up to that step.

- **Nodes.** One node per drone per step: $4 t_e$ nodes, each with an unknown position $(x, y)$ and heading $\psi$. Node $(d, t)$ has index $(d - 1)\,t_e + t$.
- **Odometry edges.** One edge between each pair of consecutive poses of a drone. Its measurement is that step's odometry increment $(\tilde f, \tilde \ell, \widetilde{\Delta\psi})$.
- **Closure edges.** One edge per loop closure detected so far. The example simulates the scan matcher a real system would run here. Each closure measures the true relative pose between the two nodes, in the frame of the earlier node, plus noise of 0.25 m in each direction and 0.003 rad in heading.
- **Anchors.** One extra row per drone fixes its first pose to the known launch pose. Anchor rows have a weight of $10^6$.

All edges share one sparse incidence matrix $A$. Each row has $+1$ in the column of the edge's end node $j$ and $-1$ in the column of its start node $i$, so $A\mathbf{q}$ gives the differences $q_j - q_i$ for any per-node quantity $\mathbf{q}$. The matrix has one row per edge plus the anchor rows and one column per node.

## The solve

The full problem is nonlinear, because a body-frame displacement depends on the heading of the node it starts from. The code splits it into two linear least-squares problems and solves each one once, with no iteration.

**1. Headings.** Each edge measures a heading difference $\psi_j - \psi_i = \theta_{ij}$. Stacking these gives $A\boldsymbol\psi \approx \boldsymbol\theta$. The code solves the weighted normal equations

$$
\bigl(A^\top W_\psi A\bigr)\,\boldsymbol\psi = A^\top W_\psi\,\boldsymbol\theta
$$

with weights $1/\sigma^2$, where $\sigma = 0.0008$ rad for odometry edges and $0.003$ rad for closures.

**2. Positions.** With the headings fixed at their solved values $\hat\psi$, the code rotates each edge's body-frame measurement $(m_x, m_y)$ into the world frame at its start node:

$$
\begin{pmatrix} b_x \\ b_y \end{pmatrix} =
\begin{pmatrix} \cos\hat\psi_i & -\sin\hat\psi_i \\ \sin\hat\psi_i & \cos\hat\psi_i \end{pmatrix}
\begin{pmatrix} m_x \\ m_y \end{pmatrix}
$$

The positions then satisfy $A\mathbf{x} \approx \mathbf{b}_x$ and $A\mathbf{y} \approx \mathbf{b}_y$. Both share the normal matrix $N = A^\top W_p A$, with $\sigma = 0.05$ m for odometry edges and $0.30$ m for closures:

$$
N\mathbf{x} = A^\top W_p\,\mathbf{b}_x, \qquad N\mathbf{y} = A^\top W_p\,\mathbf{b}_y
$$

Each system is solved with backslash (`\`) on the sparse normal matrix. The weights make the solve trust odometry over short distances and closures over long ones. A closure is less precise than one odometry step, but it ties together poses that are hundreds of steps apart, where the odometry error has piled up.

After event $e$, the estimate for steps up to $t_e$ comes from the solve. After $t_e$, the estimate is dead reckoning from the solved pose at $t_e$, so drift starts to build again until the next event. The first estimate, before any event, is dead reckoning from the launch poses.

`slam/slam_estimate.m` returns the estimate shown at step $f$. It takes the latest solve reached by step $f$ and blends it in from the previous estimate over 12 steps, using the smoothstep $a^2(3 - 2a)$, so the map moves into place instead of jumping. The error plot and the map both use this estimate.

## Reading the figures

**Figure 1: the map.** The 3D scene at the current step.

- The terrain wireframe is the ground truth.
- The flat grid under the terrain is the ground plane, with lines every 50 m. The red and green numbers along the terrain's back edges are x and y in meters; the blue numbers are altitude in meters.
- The colored points are the map, colored by height. Each point is placed through the drone's estimated pose at the step it was scanned. While a drone's estimate drifts, its points land in the wrong place and the map smears. After a solve they line up with the wireframe again.
- Dashed gray lines are the true paths. Solid colored lines are the estimated paths. Both show the last 150 steps.
- Thin lines from each drone are a sample of its LIDAR rays for the current step. The colored discs are the drones at their true positions.

While it plays, the map is drawn as 16 height bands of short strokes, one line object per band, and each drone as a small flat spiral. RunMat's `set` changes the data of line objects but not of `scatter3` objects, and `plot3` draws no markers, so the moving parts are all lines. When playback ends, the map becomes a `scatter3` cloud, as in `graphics/slam_draw.m`, which draws one step from scratch and makes the home-page video.

**Figure 2: position error.** For each drone, the horizontal distance between the estimated and true position at each step, in meters. The error climbs while the drones fly on odometry alone, then drops after each solve.

**Figure 3: map coverage.** The percentage of the world's 2 m cells hit by at least one LIDAR ray so far.

In figures 2 and 3, a dotted vertical line labeled "sync" marks each pose-graph solve. At that step the drones' shared map corrects their poses, and the position error in figure 2 starts to fall.

## Files

| File | What it does |
| --- | --- |
| `main/multi_drone_slam.m` | Entry point `main`: plays the saved run, and simulates first when the saved run no longer matches the code. |
| `main/simulate_slam.m` | Entry point `simulate`: simulates, saves and plays. |
| `main/slam_settings.m` | Step count, playback rate, theme and text size, shared by both entry points. |
| `main/slam_config.m` | All model parameters: world size, drones, routes, place recognition, event timing, LIDAR fan and coverage grid. |
| `main/slam_simulate.m` | Runs the stages in order, prints progress and the run report, and packs the results. |
| `terrain/make_terrain.m` | Diamond-square heightfield. |
| `flight/fly_routes.m` | True petal trajectories: position, altitude and yaw. |
| `flight/make_odometry.m` | Biased, noisy body-frame odometry increments. |
| `flight/dead_reckon.m` | Integrates odometry increments into poses. |
| `sensors/cast_lidar.m` | Ray marching, map points, drawn rays and coverage. |
| `slam/detect_closures.m` | Place recognition, closure edges, events and pings. |
| `slam/solve_pose_graph.m` | Builds the pose graph and runs the two-stage sparse least-squares solve for each event. |
| `slam/slam_estimate.m` | The pose estimate shown at a given step, blended between solves. |
| `playback/slam_results.m` | Loads the saved run when its key matches; otherwise simulates and saves. |
| `playback/slam_run_key.m` | The key of the current code and step count. |
| `playback/slam_play.m` | Plays a run in real time. |
| `graphics/slam_scene.m` | Builds figures 1 to 3 once for playback and returns their handles. |
| `graphics/slam_scene_step.m` | Moves the playback figures to a given step. |
| `graphics/slam_scene_finish.m` | Redraws the finished map as a `scatter3` cloud when playback ends. |
| `graphics/slam_draw.m` | Draws figures 1 to 3 for one step from scratch; the home-page video uses it. |
| `graphics/slam_map_points.m` | Places the map points through a pose estimate. |
| `graphics/slam_ground_grid.m`, `graphics/slam_terrain_wire.m` | The ground grid and the terrain wireframe. |
| `graphics/slam_style.m` | Dark and light color palettes. |
| `graphics/draw_sync_marks.m` | The dotted "sync" lines in `slam_draw`'s figures 2 and 3. |
| `results/slam_run.mat` | The saved run that `main` plays. |

## Parameters to try

In `main/slam_settings.m`:

- `steps`: the length of the run. The default of 180 includes one correction, near step 156. Each extra 140 steps adds one more correction. The home-page video uses 480. A new step count makes `main` simulate once and then play.
- `rate`: playback speed in simulation steps per second.
- `fps`: playback frames per second.
- `light`: set to `true` to draw with the light-theme palette.

In `main/slam_config.m` (each change makes `main` simulate again):

- `closeRange`: place-recognition range in meters. A smaller range detects fewer closures, later.
- `minAge`: how old a drone's own track must be before it can close a loop on it.
- `eventWindow` and `refractory`: the delay from an event's first detection to its solve, and the minimum gap between a solve and the next event.
- `petal`, `petalReach`, `petalTurn` and `stagger`: route shape and timing. A shorter `petal` brings the drones home more often.
- `nAz`, `nEl`, `dt` and `nMarch`: LIDAR resolution, march step and range. More rays or a finer step costs more time per step.
- `keepPerDrone`: map points kept per drone per step.

In `flight/make_odometry.m`, `biasWorld` sets each drone's drift. Doubling it roughly doubles the error that builds up between corrections. In `slam/solve_pose_graph.m`, the closure noise (0.25 m and 0.003 rad) and the edge sigmas set how much the solve trusts closures over odometry.
