# House: design notes

Dated 2026-11-10. These notes cover the skeleton, foundation, structural framing, envelope,
interior and MEP. The studies add their own sections as they are built.

The house is a two-story, wood-framed, stucco-clad single-family house on a 40 x 30 ft footprint
with a 6:12 gable roof, about 2,400 sq ft over two floors. It follows US residential practice:
IRC-style light-frame construction, with loads from ASCE 7-16 and wood design values from the NDS
(2018) and SDPWS (2021). All dimensions are in feet and inches; the model files write them with
`ft` and `in`.

## Coordinates, grids and levels

Building x runs east along grid A, y runs north along grid 1, z is up from the top of the slab. The
origin is the south-west corner of the outside face of the wall framing. `house_skeleton.part`
holds every value below as a plane or frame; every assembly attaches to its frames.

| Grid | Position | What is on it |
|---|---|---|
| A | y = 0 | South (front) wall |
| B | y = 12'-0" | Floor beam, posts |
| C | y = 18'-8" | Floor beam, posts; north edge of the stair opening |
| D | y = 30'-0" | North (rear) wall |
| 1 | x = 0 | West gable wall |
| 2 | x = 10'-0" | Posts B2, C2 |
| 3 | x = 19'-4" | Posts B3, C3 |
| 4 | x = 30'-0" | Posts B4, C4 |
| 5 | x = 40'-0" | East gable wall |

Grids B and C sit on the 16 in joist layout (144 and 224 in) so the posts and the beam-end posts
fall between studs and between hangers. Grid 3 is at 19'-4" rather than 20'-0" for the same reason:
a post at 20'-0" would stand under a joist hanger seat.

| Level | Elevation | Frame or plane |
|---|---|---|
| Top of footing | -1'-10" | `top_of_footing` |
| Finish grade at the walls | -0'-8" | `grade` |
| Top of slab (first floor) | 0'-0" | `top_of_slab` |
| Top of first-floor top plates | 9'-1 1/8" | `top_plate_l1` |
| Second floor (top of subfloor) | 10'-1 3/4" | `second_floor` |
| Top of second-floor top plates | 18'-2 7/8" | `top_plate` |
| Ridge (top of top chords) | 26'-4 5/16" | `ridge` |

First-floor walls are 9 ft nominal: a 1 1/2 in sill, 104 5/8 in precut studs and a double top plate,
9'-1 1/8" to the top of the plates. The floor framing is 11 7/8 in I-joists and 3/4 in
subfloor. Second-floor walls are 8 ft nominal with 92 5/8 in studs. The roof planes (`roof_south`,
`roof_north`) are the tops of the truss top chords at 6:12; they meet the outside face of walls A
and D at 18'-10 5/16" and each other at the ridge.

## Design loads

Assumed site: a suburban lot, Exposure C, ground snow 30 psf, seismic design category C, and a
clay-silt soil (CL/ML) with no geotechnical report. Risk Category II.

| Load | Value | Basis |
|---|---|---|
| Roof dead | 15 psf: 7 psf top chord (asphalt shingles, underlayment, 7/16 in OSB, framing), 8 psf bottom chord (1/2 in gypsum, R-38 insulation, framing) | Material weights |
| Floor dead | 20 psf: 12 psf construction (I-joists, subfloor, finish floor, gypsum ceiling) plus 8 psf partitions | Material weights; partition allowance carried as dead load |
| Exterior wall dead | 17 psf: 7/8 in three-coat stucco 10 psf, 2x6 framing, OSB, batts and gypsum 7 psf | Material weights |
| Floor live | 40 psf | ASCE 7 Table 4.3-1 (residential; 40 psf used for every room, including sleeping rooms) |
| Roof live | 20 psf | ASCE 7 Section 4.8; not concurrent with snow |
| Attic live | 10 psf on the bottom chord, not concurrent with other live loads | ASCE 7 Table 4.3-1, uninhabitable attic without storage |
| Snow | pg = 30 psf; Ce = 1.0, Ct = 1.1 (ventilated roof over an insulated ceiling), Is = 1.0; pf = 0.7 Ce Ct Is pg = 23.1 psf; Cs = 1.0 at 26.6 deg; design roof snow 25 psf. Unbalanced: 30 psf on the leeward side, 0 on the windward side (W = 15 ft <= 20 ft) | ASCE 7 Chapter 7 |
| Wind | V = 115 mph, Exposure C, Kzt = 1.0, Kd = 0.85, Ke = 1.0, mean roof height 22.3 ft, Kh = 0.93; qh = 26.8 psf. MWFRS (envelope procedure, theta = 26.6 deg): walls 25.2 psf net horizontal (zones 1 and 4), roof 9.4 psf on its vertical projection (zones 2 and 3) | ASCE 7 Chapters 26 and 28 |
| Seismic | SDS = 0.50 g, SD1 = 0.20 g (Site Class D assumed), SDC C, R = 6.5 (light-frame wood walls sheathed with wood structural panels), Ie = 1.0; Cs = SDS / (R / Ie) = 0.077. Seismic weight 80.5 kips; V = 6.2 kips at strength level | ASCE 7 Chapters 11 and 12, equivalent lateral force |

Load combinations are ASD (ASCE 7 Section 2.4). The governing gravity combination for walls,
headers and footings is D + 0.75 L + 0.75 S. Wind governs the lateral design in both directions:
ASD wind base shear is 9.7 kips across the building (wind on the 40 ft face) and 7.7 kips along it,
against 4.3 kips ASD for seismic (0.7 E).

## Load path

- **Gravity, roof.** Sheathing spans between trusses at 24 in o.c. The trusses span the full 30 ft
  to walls A and D and bear on their double top plates; each bearing has a truss tie. The
  second-floor studs of walls A and D carry the truss reactions to the floor, through the rim board
  and the first-floor studs to the sill, stem wall and perimeter footing. Headers over openings
  take the load to king and jack studs at each side.
- **Gravity, floor.** The I-joists span north-south: from wall A to beam B, between beams B and C,
  and from beam C to wall D. They bear on the top plates of walls A and D and hang from the beams on
  face-mount hangers. Beams B and C are flush LVLs, continuous over posts at grids 2, 3 and 4 and
  bearing at their ends on 3-ply 2x6 posts in walls 1 and 5. The posts stand on standoff bases on
  the slab over 30 in square pad footings.
- **Lateral.** The roof sheathing and the floor sheathing are horizontal diaphragms. They deliver
  wind and seismic forces to the shear walls on the four exterior wall lines through the top plates
  and the rim boards. Each wall line is a perforated shear wall: OSB sheathing nailed to the studs
  and plates, with hold-downs only at its ends. The second-floor sheathing runs down over the rim
  board to tie the floors. The shear goes into the foundation through the sill plate and the anchor
  bolts. Overturning goes down through the end posts and hold-downs: second-floor hold-downs tie
  to the first-floor end posts with a threaded rod through the floor, and first-floor hold-downs
  anchor into the stem wall and footing.

## Footings

- **Perimeter footing:** 20 in wide, 10 in deep, centred under the 8 in stem wall, with its bottom
  at 24 in below grade, the assumed frost depth. The heaviest line is walls A and D: D = 1,052 plf
  (roof, two walls, half of the A-B floor span, stem wall and footing), L = 240 plf, S = 413 plf.
  D + 0.75 L + 0.75 S = 1,542 plf, which gives 925 psf on a 20 in footing against 1,500 psf
  allowable (IRC Table R401.4.1 presumptive value for CL/ML soil). A 13 in footing would carry the
  load; 20 in gives 6 in of projection each side of the stem wall and room for the hold-down rods.
- **Pad footings:** 30 x 30 x 12 in under each post. Post B3 carries the most: 9.3 ft of floor
  (6 ft from bay A-B and 3.3 ft from bay B-C) over a 10 ft beam tributary length, 60 psf D + L, so
  5.8 kips with the beam. With the pad's own 940 lb, 6.74 kips on 6.25 sq ft is 1,080 psf against
  1,500 psf. A 24 in pad would give 1,600 psf, over the allowable value. Punching shear on the
  12 in pad is far below capacity (factored 8.5 kips against 75 kips at f'c = 2,500 psi).
- **Reinforcement (Grade 60, 3 in cover):** two #4 continuous each way in the perimeter footing,
  laid one direction over the other at the corners; three #4 each way in each pad; #4 dowels at
  48 in o.c. from the footing, lapping 18 in into the stem wall; one #4 continuous 3 in below the top
  of the stem wall. The model lays the footing bars as straight runs crossing at the corners; the
  field bends add corner bars lapping each way.
- **Stem wall:** 8 in cast-in-place concrete, f'c = 2,500 psi, from the top of the footing to the
  top of the slab, its outside face on the building line.
- **Slab on grade:** 4 in concrete on a 10 mil polyethylene vapor retarder, 2 in of XPS under the
  slab (R-10) and 4 in of compacted crushed-stone base. 1 in of XPS (R-5) lines the inside face of
  the stem wall from the top of the slab to the footing, about 2 ft deep, as the slab-edge thermal
  break. The pads come up through the base and insulation to the vapor retarder, which runs over
  them.

## Framing

Lumber is Douglas fir-larch No. 2 (Fb = 900 psi, Fv = 180 psi, Fc-perp = 625 psi, E = 1.6 x 10^6
psi, NDS Supplement Table 4A) except where noted. Sill plates on concrete are pressure-treated.

- **Studs:** 2x6 at 16 in o.c., in line with the joists of walls A and D, so every joist bears over a
  stud. A 2x6 wall at 16 in leaves room for R-21 batts and carries the two-story gravel loads with a
  wide margin: the most heavily loaded stud (wall A, first floor) takes 1.33 ft x 1,000 plf = 1.3
  kips, well under its column capacity of about 8 kips (Fc = 1,350 psi, Cp = 0.60 for buckling about the
  strong axis over 104 5/8 in, with the sheathing bracing the weak axis).
- **Corners:** walls A and D run the full 40 ft. Walls 1 and 5 fit between them. Each wall end has a
  2-ply end post for its hold-down; walls A and D add a backing stud for the interior finish at the
  inside corner. The upper top plates lap the corners: walls 1 and 5's upper plates run the full
  30 ft over the ends of walls A and D.
- **Beam-end posts:** walls 1 and 5 carry the ends of beams B and C on 3-ply 2x6 posts in the
  first-floor walls (end reaction about 2.2 kips; 90 psi on the post, 146 psi on the plate under the
  beam).
- **Floor:** 11 7/8 in I-joists at 16 in o.c. (2 5/16 in flanges); longest clear span 11 ft 5 in (bay
  A-B), well inside the published span tables for that depth at 40 psf live and 20 psf dead with
  an L/480 live-load deflection limit. 1 1/8 in rim board all round. 3/4 in tongue-and-groove
  subfloor, glued and nailed.
- **Floor beams B and C:** 3 1/2 x 11 7/8 in LVL (2.0E, Fb = 2,600 psi), flush with the joists. Beam B
  carries 9.3 ft of floor at 60 psf (560 plf). Over the longest post spacing, 10 ft 8 in, taken
  as simple span: M = 7.97 kip-ft, fb = 1,160 psi against 2,600 psi; live-load deflection 0.11 in
  (L/1,150).
- **Posts:** 6x6 Douglas fir-larch No. 1 (Posts and Timbers, Fc = 1,000 psi), 108 in long on 1 in
  standoff bases. Column stability factor 0.76; capacity 23 kips against 5.8 kips.
- **Stair opening:** 132 x 42 in in bay B-C, between
  x = 13'-8" and 24'-8", against beam C. Doubled I-joist trimmers at each end; a 1 3/4 x 11 7/8 in
  LVL header on its long side, hung from the trimmers; eight tail joists from beam B to the header.
  The stair (16 risers at 7.6 in, 15 treads at 10 in) runs east-west under it.
- **Roof trusses:** Fink (W) trusses, 2x4 chords and webs, 30 ft span, 6:12, 18 in overhangs, at
  24 in o.c.: 19 common trusses and a gable-end truss over each of walls 1 and 5, with studs at 16 in
  o.c. for the gable sheathing. Truss design loads: top chord 25 psf snow (and the unbalanced case
  above) plus 7 psf dead; bottom chord 8 psf dead plus 10 psf attic live, not concurrent. The truss
  fabricator designs the plates and members to ANSI/TPI 1; the model shows their geometry.

## Headers

Every header is an insulated 2-ply header: a 2x member at the outside face and one at the inside
face of the 2x6 wall with 2 1/2 in of XPS between them, so the header is not a full-depth thermal
bridge. Headers bear on jack studs at each side, against king studs.

The heaviest header load is in walls A and D on the first floor: roof (15 ft plus the 18 in
overhang), the second-floor wall and half of the A-B or C-D floor span. D = 506 plf, L = 240 plf,
S = 413 plf; D + 0.75 L + 0.75 S = 996 plf, taken as 1,000 plf. Spans are the rough opening plus a
1 1/2 in bearing.

| Rough opening width | Header (walls A and D, first floor) | Check |
|---|---|---|
| up to 38 1/2 in | 2-2x8 | 3.3 ft span: fb = 635 psi against F'b = 900 x 1.2 x 1.15 = 1,242 psi |
| up to 60 1/2 in | 2-2x10 | 5.2 ft span: fb = 937 psi against 1,138 psi; fv = 98 psi against 207 psi; deflection L/2,500 |
| up to 74 in | 2-2x12, two jack studs each side | 6.3 ft span: fb = 938 psi against 1,035 psi; fv = 98 psi; bearing 191 psi on two jacks |

- **Walls 1 and 5, first floor:** these gable walls carry the wall above, the rim and the gable-end
  truss, about 230 plf. 2-2x8 headers carry their 36 1/2 in openings with a large margin.
- **Second floor, all walls:** 2-2x12 headers set tight under the top plates, carrying the roof
  (661 plf on walls A and D). The deeper header fills the space above the opening, so no cripples are
  needed there; their heads are at 82 7/8 in above the subfloor.
- **First-floor heads:** 82 1/2 in above the slab, the door height plus the threshold.

## Shear walls

Sheathing: 7/16 in OSB on the outside face of every exterior wall, panels full height (no horizontal
joints, so every panel edge is on framing). Nailing: 8d common (0.131 x 2 1/2 in) at 6 in o.c. at
panel edges and 12 in o.c. in the field. SDPWS Table 4.3A nominal capacities: vw = 715 plf (wind),
vs = 510 plf (seismic); ASD wind 357 plf. Each wall line is a perforated shear wall (SDPWS 4.3.3.5):

| Wall line | ASD wind shear | Full-height sheathing | Co | ASD capacity |
|---|---|---|---|---|
| 1 or 5, first floor | 4.83 kips | 23.9 ft (80 %) | 0.83 | 7.08 kips |
| 1 or 5, second floor | 2.07 kips | 23.9 ft (80 %) | 0.91 | 7.76 kips |
| A, first floor | 3.84 kips | 25.7 ft (64 %) | 0.65 | 5.96 kips |
| D, first floor | 3.84 kips | 26.8 ft (67 %) | 0.67 | 6.40 kips |
| A or D, second floor | 1.77 kips | 27.8 ft (69 %) | 0.86 | 8.52 kips |

The `shear_wall` part names the panel edges `edge_nailing` and the panel faces `field_nailing`, with
each schedule in the region's label.

### Hold-downs

Uplift at each end of a perforated shear wall is t = V h / (Co sum Li) (SDPWS Equation 4.3-8),
summed down the building, with no credit taken for dead load:

- walls 1 and 5: second floor 0.78 kips; first floor 2.21 + 0.78 = 2.99 kips;
- walls A and D: second floor 0.60 kips; first floor 2.09 + 0.60 = 2.69 kips.

Foundation hold-downs (`hold_down`, configuration `foundation`) have an allowable tension of at least
4,000 lb, with a 5/8 in threaded rod into the footing. Floor-to-floor hold-downs (`floor_to_floor`)
have at least 1,500 lb, with a 5/8 in rod through the floor to an inverted bracket on the
first-floor end post. Every hold-down screws to a 2-ply end post.

### Anchor bolts

5/8 in diameter, 10 in embedment, with 3 x 3 x 0.229 in plate washers, at no more than 48 in o.c.
and within 12 in of every sill end, including each side of a door. The highest sill shear is on walls
1 and 5: 4.83 kips / (0.83 x 23.9 ft) = 243 plf, or 972 lb per bolt at 48 in. The NDS yield-limit
equations give about 1,300 lb for a 5/8 in bolt through a 1 1/2 in Douglas fir-larch sill into
concrete (mode Is), 2,100 lb with CD = 1.6. Bolt stations, from the start of each wall's local x:

- Wall A (south): 12, 60, 108, 156, 198, 252.75, 300.75, 346.5, 394.5, 442.5, 471.25 in from the wall start.
- Wall D (north): 12, 60, 108, 156, 204, 217, 309.25, 357.25, 405.25, 453.25, 471.25 in from the wall start.
- Wall 1 (west): 8, 56, 104, 152, 200, 245, 293, 341 in from the wall start.
- Wall 5 (east): 12, 58, 106, 154, 202, 250, 298, 342 in from the wall start.

### Other connectors

- Joist hangers: face-mount, 18 gauge, on every joist end at a beam or header (single, doubled-trimmer
  and LVL sizes).
- Truss ties: one at each bearing of every common truss, for wind uplift of about 330 lb per bearing
  (components and cladding, roof zone 1, less 0.6 D); ties rated at least 400 lb.
- Post bases: standoff bases with straps, anchored into the slab over the pads.

## Opening schedule (for the envelope lane)

H2's windows and doors must use these rough openings. The framing leaves exactly these openings,
and the skeleton publishes a frame at each one (`opening_<wall>_l<level>_<n>`): at the bottom corner
of the rough opening on the outside face of the studs, x along the wall, y inward, z up.

| Type | Unit | Unit size, in | Rough opening, in |
|---|---|---|---|
| W1 | Living-room window, fixed | 60 x 60 | 60.5 x 60.5 |
| W2 | Window, single hung | 36 x 60 | 36.5 x 60.5 |
| W3 | Bedroom window, casement (egress) | 36 x 48 | 36.5 x 48.5 |
| W4 | Bath window, casement, obscure glass | 24 x 36 | 24.5 x 36.5 |
| W5 | Kitchen window, slider | 48 x 36 | 48.5 x 36.5 |
| D1 | Entry door, insulated steel | 36 x 80 | 38 x 82.5 |
| D2 | Patio door, sliding | 72 x 80 | 74 x 82.5 |

Rough openings are the unit plus 1/2 in each way for windows, and the unit width plus 2 in by 82 1/2
in for doors. Wall-local x runs from each wall's start: wall A from the west end, wall D from the
east end, wall 1 from the north end, wall 5 from the south end, each 5 1/2 in in from the corner on
walls 1 and 5. Heights are from the bottom of the sill or bottom plate.

| Frame | Type | Wall | RO left, in | RO right, in | RO bottom, in | RO top, in | Header | Jacks each side | Building x, y (outside face) |
|---|---|---|---|---|---|---|---|---|---|
| opening_a_l1_1 | W1 | A, L1 | 53.75 | 114.25 | 22 | 82.5 | 2x10 | 1 | (53.75, 0) to (114.25, 0) |
| opening_a_l1_2 | D1 | A, L1 | 202.75 | 240.75 | 0 | 82.5 | 2x8 | 1 | (202.75, 0) to (240.75, 0) |
| opening_a_l1_3 | W2 | A, L1 | 311.75 | 348.25 | 22 | 82.5 | 2x8 | 1 | (311.75, 0) to (348.25, 0) |
| opening_a_l1_4 | W2 | A, L1 | 391.75 | 428.25 | 22 | 82.5 | 2x8 | 1 | (391.75, 0) to (428.25, 0) |
| opening_d_l1_1 | W5 | D, L1 | 75.75 | 124.25 | 46 | 82.5 | 2x10 | 1 | (355.75, 360) to (404.25, 360) |
| opening_d_l1_2 | D2 | D, L1 | 223.25 | 297.25 | 0 | 82.5 | 2x12 | 2 | (182.75, 360) to (256.75, 360) |
| opening_d_l1_3 | W2 | D, L1 | 381.75 | 418.25 | 22 | 82.5 | 2x8 | 1 | (61.75, 360) to (98.25, 360) |
| opening_1_l1_1 | W2 | 1, L1 | 71.75 | 108.25 | 22 | 82.5 | 2x8 | 1 | (0, 246.25) to (0, 282.75) |
| opening_1_l1_2 | W2 | 1, L1 | 249.75 | 286.25 | 22 | 82.5 | 2x8 | 1 | (0, 68.25) to (0, 104.75) |
| opening_5_l1_1 | W2 | 5, L1 | 62.75 | 99.25 | 22 | 82.5 | 2x8 | 1 | (480, 68.25) to (480, 104.75) |
| opening_5_l1_2 | W2 | 5, L1 | 271.75 | 308.25 | 22 | 82.5 | 2x8 | 1 | (480, 277.25) to (480, 313.75) |
| opening_a_l2_1 | W3 | A, L2 | 51.75 | 88.25 | 34.375 | 82.875 | 2x12 | 1 | (51.75, 0) to (88.25, 0) |
| opening_a_l2_2 | W3 | A, L2 | 151.75 | 188.25 | 34.375 | 82.875 | 2x12 | 1 | (151.75, 0) to (188.25, 0) |
| opening_a_l2_3 | W3 | A, L2 | 291.75 | 328.25 | 34.375 | 82.875 | 2x12 | 1 | (291.75, 0) to (328.25, 0) |
| opening_a_l2_4 | W3 | A, L2 | 391.75 | 428.25 | 34.375 | 82.875 | 2x12 | 1 | (391.75, 0) to (428.25, 0) |
| opening_d_l2_1 | W3 | D, L2 | 51.75 | 88.25 | 34.375 | 82.875 | 2x12 | 1 | (391.75, 360) to (428.25, 360) |
| opening_d_l2_2 | W4 | D, L2 | 157.75 | 182.25 | 46.375 | 82.875 | 2x12 | 1 | (297.75, 360) to (322.25, 360) |
| opening_d_l2_3 | W4 | D, L2 | 297.75 | 322.25 | 46.375 | 82.875 | 2x12 | 1 | (157.75, 360) to (182.25, 360) |
| opening_d_l2_4 | W3 | D, L2 | 391.75 | 428.25 | 34.375 | 82.875 | 2x12 | 1 | (51.75, 360) to (88.25, 360) |
| opening_1_l2_1 | W3 | 1, L2 | 71.75 | 108.25 | 34.375 | 82.875 | 2x12 | 1 | (0, 246.25) to (0, 282.75) |
| opening_1_l2_2 | W3 | 1, L2 | 249.75 | 286.25 | 34.375 | 82.875 | 2x12 | 1 | (0, 68.25) to (0, 104.75) |
| opening_5_l2_1 | W3 | 5, L2 | 62.75 | 99.25 | 34.375 | 82.875 | 2x12 | 1 | (480, 68.25) to (480, 104.75) |
| opening_5_l2_2 | W3 | 5, L2 | 271.75 | 308.25 | 34.375 | 82.875 | 2x12 | 1 | (480, 277.25) to (480, 313.75) |

## Envelope

The walls are clad in three-coat portland-cement stucco applied over the water-resistive barrier and
the OSB, the common light-frame wall in the western US. Stucco is a reservoir cladding: it absorbs
rain and releases it slowly, so the layers behind it have to drain and dry. Climate zone 3 is assumed (IECC 2018 Table R402.1.2:
ceiling R-38, wood-frame wall R-20 or R-13+5, fenestration U-0.32 and SHGC 0.25). Each layer in
`envelope/exterior_wall.part` is its own body with its material, so a section shows the build-up and
the thermal studies read conductivities from the model.

| Layer, outside to inside | Thickness | Why it is there | R (h ft2 F/Btu) |
|---|---|---|---|
| Outside air film (15 mph) | | | 0.17 |
| Stucco finish coat | 1/8 in | Color and texture; sheds most of the water | |
| Stucco brown coat | 3/8 in | Builds the 7/8 in total and trues the plane | 0.18 for the 7/8 in |
| Stucco scratch coat, keyed through the lath | 3/8 in | Bonds the plaster to the lath | |
| Self-furring expanded metal lath, 2.5 lb/sq yd, galvanized | in the scratch coat | Holds the plaster 1/4 in off the paper so the scratch coat keys behind it (IRC R703.7.1) | |
| Water-resistive barrier, outer layer: Grade D 60-minute building paper | 1/32 in drawn | Takes the water that passes the stucco and drains it down to the weep screed | 0.06 |
| Water-resistive barrier, inner layer: Grade D 60-minute building paper | 1/32 in drawn | The second layer IRC R703.7.3 requires over wood-based sheathing: the outer layer bonds to the stucco, so this inner layer forms the drainage plane | 0.06 |
| OSB sheathing (framing/shear_wall.part) | 7/16 in | Shear wall and nail base | 0.62 |
| 2x6 studs at 16 in o.c. with R-21 fiberglass batts | 5 1/2 in | Structure; cavity insulation (R-21 meets the R-20 prescriptive value) | 21 cavity, 6.88 stud |
| Variable-permeance vapor retarder (polyamide film) | 1/64 in drawn | Class II in winter, when the film is dry, which limits outward vapor drive into the cold sheathing. In humid summer weather it opens (Class III), so moisture that sun-driven vapor pushes in from wet stucco can dry to the inside. Polyethylene would trap that moisture against the gypsum. IRC R702.7 does not require a retarder in zone 3; this one reduces condensation risk at the OSB without adding the inward-drive risk | 0 |
| Gypsum board | 1/2 in | Interior finish; 15-minute thermal barrier | 0.45 |
| Inside air film | | | 0.68 |

Parallel-path U-factor (ASHRAE Fundamentals, Chapter 27). The wall model's framing fraction, measured
from the batt and framing areas over the opaque wall, is 25.6 % (studs, plates, end posts, kings,
jacks and headers). Cavity path R = 23.22, framing path R = 9.10:
U = 0.744 / 23.22 + 0.256 / 9.10 = 0.0602 Btu/h ft2 F, effective R-16.6. The wall complies by the
prescriptive R-value path (R-21 against R-20). Its U-factor sits at the limit of the U-factor
alternative (0.060). The `wall_thermal` study checks this number.

- **Weep screed:** galvanized, 26 gauge, with a 3 1/2 in nailing flange behind the outer paper. Its
  leg is at -2 in, 2 in below the sill plate line (IRC R703.7.2.1 asks for at least 1 in) and 6 in above
  finish grade (at least 4 in).
- **Openings:** every rough opening is cut through every layer. A galvanized sill pan lines the rough
  sill from 1/4 in proud of the stucco to 3 in into the wall, under the window on 1/4 in shims. A drip
  cap sits in a 1/16 in slot over the head and projects 1/2 in past the stucco face. In the field the
  pan's end dams, the jamb flashing tape and the window's nailing flange lap shingle-fashion with the
  two paper layers; the model omits those lapped pieces because they are thinner than the paper.
- **Corners:** walls A and D carry each outer layer past the corner by that layer's own depth. The
  outer layers of walls 1 and 5 stop at the outside face of the framing. The inside layers do the
  reverse: walls 1 and 5 run into the corner and walls A and D stop at the room face of the
  gypsum. No two layers overlap at a corner.
- **Second floor, walls A and D:** the truss ties' 18 gauge drop legs lap 3 in down the inside face of
  the top plates, so the retarder and board on those two walls are furred out 3/64 in to clear them.
- **Gables:** `gable_wall.part` carries the same OSB, paper, lath and stucco up the gable-end trusses to
  the roof plane.

## Roof and attic

| Layer, top down | Thickness | Notes |
|---|---|---|
| Laminated asphalt shingles, Class 3 wind | 1/4 in drawn | ASTM D7158 Class H or D3161 Class F for the 115 mph design wind |
| Synthetic underlayment | 1/32 in drawn | One layer, lapped 4 in; ice barrier is not required in zone 3 |
| OSB roof sheathing with H-clips | 7/16 in | Spans 24 in between trusses (APA 24/16) |
| Trusses, 2x4 at 24 in o.c. | | framing/roof_truss.part |
| Blown fiberglass, settled | 14 3/4 in | R-38 at R-2.6 per inch; between the bottom chords and over them |
| Gypsum ceiling board, sag-resistant | 1/2 in | Under the bottom chords at 24 in o.c. |

Ceiling U-factor: insulation path R = 0.61 + 0.45 + 38.4 + 0.61 = 40.1; bottom-chord path (6.25 %:
1 1/2 in in 24 in) R = 0.61 + 0.45 + 4.38 + 29.3 + 0.61 = 35.3; U = 0.0252, effective R-39.8 against the
zone 3 ceiling value of R-38 (U-0.030).

- **Attic ventilation (IRC R806.2):** attic floor 1,137 sq ft. With 40 to 50 % of the vent area in the
  upper attic, 1/300 applies: 3.79 sq ft (546 sq in) net free area. Ridge vent, 18 sq in per foot over
  39.3 ft: 708 sq in. Fully vented soffits, 10 sq in per foot over 80 ft: 800 sq in. The total,
  1,508 sq in (10.5 sq ft), also meets the 1/150 ratio (7.58 sq ft), and the ridge share is 47 %.
- **Baffles:** a polystyrene baffle in every truss bay, from over the wall plates to 4 ft up the slope,
  keeps a 1 1/2 in (vertical) air channel under the sheathing above the insulation (IRC R806.3 asks for
  at least 1 in).
- **Eave depth:** the trusses have a standard 3 1/2 in heel, so the insulation thins toward the eaves.
  It is 8 1/2 in deep over the inside face of the walls (about R-22) and full depth from 18 in in.
  A raised-heel truss would give full depth over the plates; the framing lane can make that change.
- **Eaves and rakes:** 2x6 fascia on the plumb-cut tails, vented aluminum soffits level with the tail
  ends, and stucco returns closing the soffit ends at the gables. Sheathing and shingles run 2 to
  2 1/2 in past the gable stucco.

## Windows and doors

Vinyl units, double-pane low-E with argon (two 1/8 in lites, 1/2 in space), NFRC-rated. Doors: D1
insulated steel; D2 vinyl sliding with tempered low-E glass.

| Type | Operation | U-factor | SHGC | Notes |
|---|---|---|---|---|
| W1 | Fixed | 0.25 | 0.25 | |
| W2 | Single hung | 0.28 | 0.25 | |
| W3 | Casement, egress | 0.27 | 0.25 | Clear opening about 31 x 43 in (9.3 sq ft), sill 36 in above the floor (IRC R310: 5.7 sq ft, 20 in wide, 24 in high, sill at most 44 in) |
| W4 | Casement, obscure | 0.27 | 0.25 | Tempered: the hall-bath unit is within 60 in of the tub (IRC R308.4.5) |
| W5 | Slider | 0.28 | 0.25 | Sill 46 in above the slab, over the 36 1/2 in countertop |
| D1 | Swing, insulated steel | 0.20 | | |
| D2 | Sliding glass | 0.30 | 0.25 | Tempered |

Every unit is at or under U-0.32 and SHGC 0.25. Glazing is 314 sq ft, about 13 % of the floor area. The
second-floor sills are 34 3/8 in above the subfloor, over the 24 in that IRC R312.2 asks of
operable windows above the first floor.

## Floor plan

Room faces are the gypsum faces: 6 in in from the outside face of the framing on all four walls. Interior
partitions are 2x4 with 1/2 in gypsum both sides, 4 1/2 in overall, and carry no load.

First floor. Sizes are clear dimensions between finished faces.

| Room | Extent (building x, y) | Size | Openings |
|---|---|---|---|
| Living room | x 0'-6" to 12'-2", y 0'-6" to 29'-6" | 11'-8" x 29'-0", open to the foyer and dining area | W1 (south), two W2 (west) |
| Foyer and stair hall | x 12'-2" to 24'-8", y 0'-6" to 14'-10" | 12'-6" x 14'-4" | D1 (south) |
| Stair | x 12'-2" to 24'-8", y 15'-2" to 18'-5" | 39 in wide, rising east | |
| Dining | x 12'-2" to 24'-8", y 18'-5" to 29'-6" | 12'-6" x 11'-1" | D2 (north) |
| Kitchen and breakfast area | x 24'-8" to 39'-6", y 11'-6" to 29'-6" | 14'-10" x 18'-0", tile | W5 (north), W2 (east) |
| Utility (laundry, furnace, water heater, panel) | x 25'-0" to 30'-0", y 0'-6" to 11'-2" | 5'-0" x 10'-8", tile | W2 (south) |
| Den | x 30'-4" to 39'-6", y 0'-6" to 11'-2" | 9'-2" x 10'-8" | W2 (south), W2 (east) |

Second floor:

| Room | Extent (building x, y) | Size | Openings |
|---|---|---|---|
| Bedroom 3 | x 0'-6" to 15'-10", y 0'-6" to 11'-10" | 15'-4" x 11'-4" | Two W3 (south), W3 (west) |
| Primary bedroom | x 16'-2" to 39'-6", y 0'-6" to 11'-10" | 23'-4" x 11'-4" | Two W3 (south), W3 (east) |
| Hall and landing | y 12'-2" to 18'-8", around the stair opening | 36 in past the opening on the south | |
| Bedroom 2 | x 0'-6" to 9'-2", y 19'-0" to 29'-6" | 8'-8" x 10'-6" | W3 (north), W3 (west) |
| Hall bath | x 9'-6" to 20'-0", y 19'-0" to 29'-6" | 10'-6" x 10'-6", tub, toilet, vanity | W4 (north) |
| Primary bath | x 20'-4" to 28'-4", y 19'-0" to 29'-6" | 8'-0" x 10'-6", shower, toilet, double vanity | W4 (north) |
| Primary closet | x 28'-8" to 39'-6", y 19'-0" to 29'-6" | 10'-10" x 10'-6", door to the primary bath | W3 (north), W3 (east) |

- The second-floor hall walls stand on beams B and C, so the partitions line up with the structure below.
- The first-floor partitions keep at least 2 3/4 in clear of the posts: post C3 stands at the open
  north side of the stair as its newel.
- Bedrooms 2 and 3 open onto the hall west of the stair, and the primary bedroom and closet open onto
  the landing east of it. The 36 in corridor south of the opening connects the two.
- Interior doors are 30 x 80 in hollow-core slabs in 32 x 82 1/2 in rough openings.

## Stair

| Item | Value | IRC R311.7 limit |
|---|---|---|
| Total rise, finish floor to finish floor | 121 3/4 in | |
| Risers | 16 at 7 39/64 in (7.609 in) | at most 7 3/4 in, uniform within 3/8 in |
| Treads | 15 at 10 in, with a 1 in nosing | at least 10 in; nosing 3/4 to 1 1/4 in |
| Total run | 150 in (12'-6"), from x = 12'-2" to the floor edge at x = 24'-8" | |
| Width | 39 in between the stair wall and post C3 | at least 36 in |
| Headroom | 85 1/2 in at the west edge of the floor opening (ceiling at 108 5/8 in, nosing line at 23 1/8 in) | at least 80 in |
| Handrail | Oak, 36 in above the nosing line, 1 1/2 in clear of the wall | 34 to 38 in |
| Guards | 36 in half walls on the south and west edges of the opening | at least 36 in (R312.1.2) |

The stair runs east-west under the 132 x 42 in opening in bay B-C. Its notched 2x12 stringers keep a
7 3/8 in throat below the notches. The top riser stands against the opening's east trimmer, and the
bottom tread lands 1 3/4 in past the west end of the stair wall.

## MEP

The house is all-electric: a heat pump with electric strip heat, an electric water heater, an
electric range and dryer. The utility room (x 25'-0" to 30'-0", y 0'-6" to 11'-2") holds the panel,
the air handler, the water heater and the PEX manifold. Everything in `mep/` is in building
coordinates; `mep/mep.assembly` places the four systems at the skeleton's building frame.

### Electrical service and load calculation

The service is 120/240 V, single phase, three wire, 200 A. The meter is on wall A outside the
utility room at x = 29'-10"; 4/0 Al XHHW-2 service-entrance conductors run in 2 in PVC straight
through the wall (bored through the sheathing and finishes, clear of the studs at x = 29'-4" and
30'-8") into the side of the surface-mounted 40-space panel with a 200 A main breaker. The
grounding electrode conductor is 4 AWG Cu to a concrete-encased electrode (20 ft of #4 footing
rebar, NEC 250.52(A)(3)) with a supplementary rod on 6 AWG Cu. `mep/electrical/service.circuit`
is the one-line and holds the panel schedule as its breakers.

Load calculation, NEC 220.82 (optional method, dwelling unit):

| Load | VA |
|---|---|
| General lighting and receptacles, 3 VA/sq ft x 2,400 sq ft | 7,200 |
| Two small-appliance circuits at 1,500 VA, and the laundry circuit | 4,500 |
| Range 12,000; dryer 5,000; water heater 4,500; dishwasher 1,200 (nameplate) | 22,700 |
| Subtotal, 220.82(B) | 34,400 |
| First 10 kVA at 100 % plus the rest at 40 % | 19,760 |
| Heat pump: compressor 4,080 (17 A x 240 V) and air handler fan 500 at 100 %, 10 kW strips at 65 % (220.82(C)(5)) | 11,080 |
| Total | 30,840 VA = 128.5 A at 240 V |

128.5 A on a 200 A service leaves about 70 A for later loads such as an EV charger. 4/0 Al
serves 200 A under NEC 310.12 (83 % of the service rating, 166 A, against 180 A for 4/0 Al at 75 C).

### Panel schedule and wire gauges

Circuit numbers are panel spaces. Cable is copper NM-B (60 C column, NEC 334.80), except where
noted. Every breaker is at or under the ampacity of its conductor (NEC 240.4(D) for 14, 12 and
10 AWG).

| Ckt | Breaker | Conductor | Ampacity | Load |
|---|---|---|---|---|
| 1/3 | 50 A 2P, GFCI | 6/3 | 55 A | Range, NEMA 14-50R (12 kW) |
| 5/7 | 30 A 2P, GFCI | 10/3 | 30 A | Dryer, NEMA 14-30R |
| 9/11 | 30 A 2P | 10/2 | 30 A | Water heater, 4,500 W: 18.8 A x 1.25 = 23.4 A |
| 13/15 | 60 A 2P | 4/2 | 70 A | Air handler, MCA 52 A, MOCP 60 A, through a 60 A disconnect |
| 17/19 | 30 A 2P | 10/2 | 30 A | Heat pump condenser, MCA 19.5 A, MOCP 30 A, through a disconnect at the unit |
| 2, 4 | 20 A AFCI | 12/2 | 20 A | Kitchen small-appliance circuits, GFCI at the first receptacle |
| 6 | 20 A AFCI | 12/2 | 20 A | Refrigerator |
| 8 | 20 A dual function | 12/2 | 20 A | Dishwasher and disposal |
| 10 | 20 A dual function | 12/2 | 20 A | Laundry receptacle (NEC 210.11(C)(2)) |
| 12, 14 | 20 A | 12/2 | 20 A | Hall and primary bath receptacles, GFCI receptacles (210.11(C)(3)) |
| 16 | 20 A | 12/2 | 20 A | Outdoor receptacles, front and back, GFCI, weather resistant |
| 18 to 28 | 15 A AFCI | 14/2 | 15 A | Lighting and receptacles by room; smoke and CO alarms on 22, 24, 26 and 28 |
| 30 | 15 A | 14/2 | 15 A | Bath lights and exhaust fans |

Two-pole breakers take spaces n and n + 2 on the left; one-pole breakers take the even spaces on
the right, 2 to 30, with 10 spaces left. Rows alternate between the L1 and L2 buses, so the
120 V loads split across both legs. AFCI protection covers every 120 V 15 and 20 A circuit in
living areas, bedrooms, the kitchen and the laundry (NEC 210.12); GFCI protection covers the
kitchen counters, baths, laundry, outdoors and the range and dryer outlets (NEC 210.8(A), 2023).
The longest 15 A run, the primary bedroom at about 75 ft, drops 2.4 % at 12 A on 14 AWG.

`mep/electrical/branch_circuits.circuit` draws each circuit as a sheet: the breaker's load
terminal, then each device in the order the cable reaches it. Receptacles downstream of a GFCI
receptacle connect to its load terminals. The devices are parts with no footprint
(`package = none`, from `mep/electrical/library/devices.circuit`), so the circuits are schematic
only. Both files pass ERC with no findings.

### Electrical placement and routing

`electrical.assembly` places the meter, the panel, device boxes recessed in the walls (single-gang
2 x 3 x 2 1/2 in; two-gang for the dryer outlet) with their devices, two ceiling boxes with their
luminaires, and the air-handler disconnect. Receptacles sit at 16 in to the box center in rooms, 42
in over counters and laundry, 30 in for the dryer. Cables leave the top of the panel, rise 31 in on
the utility-room wall into the floor joist space, and run in their own lanes in the I-joist web
zone. The routed set covers the utility room, the den and the kitchen's north and east walls:
circuits 1, 2, 4, 5, 6, 9, 10, 13 and 22. The range cable (6/3 NM-B, drawn 0.8 in round) runs in a
1 in hole; the others run in 3/4 in holes. The kitchen's east-wall runs go north at x = 27'-3 5/8"
and 27'-4 3/8", between the kitchen sink's hot line and the c2 lane, and drop through the east
wall's top plates between studs. The range receptacle sits behind the range, which stands 1 in off
the wall; the counter GFCI is south of the W2 window's jacks.

- **Bored holes:** 3/4 in holes for the cables in the I-joist webs (web zone 1 1/2 to 10 3/8 in up
  the joist, at least 6 in from a bearing), in the top plates of the walls and partitions they
  drop through, and in the LVL beams B and C at x = 27'-6" (in the middle third of the depth and
  32 in from the nearest post, at least twice the beam depth). The model cuts these holes into
  the framing parts as `mep_<configuration>_<n>` features, unsuppressed only in the configuration
  the run passes through.
- **Cut-outs:** each box cuts its opening in the gypsum (and the vapor retarder in exterior walls).
- **Cables in the utility room:** above the panel the cables run exposed on the wall, secured
  within 12 in of the panel (NEC 334.30).

### Plumbing: supply

3/4 in PEX enters through the slab in the utility room and feeds a home-run manifold on the
utility room's west partition. The 50 gal electric water heater feeds the manifold's hot side. 1/2
in PEX runs to each fixture: the washer box under the manifold and the kitchen sink. The kitchen
runs rise into the joist space, cross beams B and C in bored holes (1 in holes in the middle third,
32 in from the post at grid 4), and drop in wall D beside the window to stub-outs at the gypsum
face, 18 in above the floor.

| Fixture | Water supply fixture units (IPC Table E103.3(2), private) | Supply |
|---|---|---|
| Kitchen sink | 1.4 | 1/2 in hot and cold |
| Clothes washer | 1.4 | 1/2 in hot and cold |
| Dishwasher | 1.4 | 1/2 in hot |
| Lavatories (3) | 0.7 each | 1/2 in |
| Water closets (2), tank | 2.2 each | 1/2 in |
| Bathtub and shower | 1.4 each | 1/2 in |
| Total | 15.1 WSFU | 3/4 in PEX service and manifold (good for about 9 gpm at 60 psi over 100 ft) |

The second-floor baths take four more manifold ports: hall cold, hall hot, primary cold and
primary hot. Each 1/2 in run rises beside the manifold into the floor joist space, runs north in the
bay between the joists at x = 25'-4" and 26'-8", and crosses beams B and C in 1 in holes centered
4 7/8 in above the beam bottom (inside the middle third), 42 in or more from the post at grid 4. In bay C-D
each run turns into an east-west header at least 6 in from beam C (y = 19'-4 1/2" to 20'-0"),
bored through the I-joist webs, and branches between the joists to its fixtures:

| Fixture | Supply | Where it comes up |
|---|---|---|
| Tub valve | 1/2 in hot and cold | In wall D's stud cavity at the tub's drain end, 30 in above the floor |
| Toilets | 1/2 in cold | Stub up through the floor 6 in to the side of the flange, behind the bowl |
| Hall lavatory | 1/2 in hot and cold | Up through the vanity bottom |
| Shower valve | 1/2 in hot and cold | In the partition between the baths, 48 in above the floor |
| Primary lavatories (2) | 1/2 in hot and cold | Up through the vanity bottom under each basin |

The cold and hot headers sit at different heights (117.3 and 118.5 in), so a branch of one system
crosses the other's header with clearance. The runs stay in the web zone of the joists (1 1/2 in
from each flange).

### Plumbing: drain, waste and vent

`dwv.assembly` holds the kitchen sink's 1 1/2 in trap arm into wall D at 16 in above the floor,
sloped 1/4 in per ft (IPC 704.1), with a cleanout tee, and its 1 1/2 in vent. The vent crosses the
bored studs and cripples under and beside the W5 window at 30 in (2 1/8 in holes, 38 % of the 2x6
depth, under the 40 % IRC R602.6 allows in bearing studs), rises in wall D at x = 36'-8" through
both floors, runs across the attic just above the ceiling, and leaves through the roof at y = 25 ft,
12 in above the shingles (IPC 904.1 asks for 6 in). Drainage fixture units (IPC Table 709.1): kitchen
sink 2, dishwasher 2, clothes washer 2, two bath groups 6 each; 18 DFU on a 3 in building drain at
1/4 in per ft (42 DFU allowed).

The second-floor baths drain to two 3 in horizontal branches in floor bay C-D, on one line at
y = 28'-10" and sloped 1/8 in per ft (IPC 704.1 for 3 in and larger). The hall branch starts at the
tub's drain end and runs east past the hall toilet; the primary branch runs west from the primary
toilet. They meet at a 3 in stack at x = 23'-4". The toilets drop into the branches through 3 in
closet bends; the shower and the lavatories run 2 in and 1 1/2 in arms north along their joist bays
at 1/4 in per ft. The branches cross the I-joist webs in 3 3/4 in holes 10 ft from beam C and
8 1/2 in from the bearing on wall D. Those holes must fall inside the I-joist maker's web-hole
chart for 11 7/8 in joists; a chart that asks for more distance from the end bearing moves the
branch line south, and the toilets keep their flanges by lengthening the closet bends.

- **Stack and chase:** the stack drops through a framed chase in the dining room's north-east
  corner (x = 22'-6" to 24'-2", against wall D): 2x4 studs and plates with 1/2 in gypsum on the room
  faces, from the floor finish to the ceiling, with a cleanout at the base. The stack stays clear of
  wall D, which stands on the stem wall and has no room for a drain.
- **Building drain:** 3 in under the slab at 1/4 in per ft. It starts under the kitchen sink, which
  drains straight down through the sink base, takes the stack, and leaves through the north stem
  wall above the footing in a cast-in sleeve, toward the sewer.
- **Vents:** a 1 1/2 in vent rises from the upstream end of the hall branch in wall D's stud cavity at
  x = 11'-1 1/2" and a 2 in vent rises from the branch in the partition between the baths. Each
  passes the second-floor top plates in bored holes, runs south across the attic just above the
  ceiling and leaves through the roof at y = 25 ft, 12 in above the shingles. The toilets and the
  shower connect within the IPC Table 906.1 distances of these vents. The three lavatories, whose
  arms are longer than 6 ft to a vent, each vent through an air admittance valve in the vanity
  (IPC 918), where it stays accessible.

### HVAC

A 3 ton heat pump: the air handler with 10 kW heat strips stands on a 20 in return platform in the
utility room, and the condenser sits on a 36 x 36 x 4 in pad outside wall 5. The design load is
about 30 kBtu/h cooling and 34 kBtu/h heating (Manual J outline: 2,400 sq ft, the envelope above,
climate zone 3). The supply plenum feeds a 14 x 8 in trunk in a soffit at 8 ft along the utility
room and den, through a framed opening in the partition between them, with ceiling-height supply
registers. 1,200 cfm (400 cfm per ton) in a 14 x 8 in trunk is 1,540 ft/min, inside the
900 to 1,600 ft/min of a residential supply trunk at the plenum; branches reduce it room by room.
The return grille is in the platform's face, 20 x 14 in, 1,200 cfm at about 600 ft/min across the
filter. The insulated refrigerant line set (3/4 in suction, 3/8 in liquid) runs from the condenser
through wall 5, up the wall cavity, across the joist space in bored 2 in holes in the I-joist webs,
through beam B at x = 27'-9", and down to the air handler's coil.

The second floor is served from the same trunk. A 11 x 10 in riser leaves the top of the soffit trunk
at x = 30'-10" to 31'-10", runs north in the joist bay to the hall wall, and rises in a framed chase in
the primary bedroom's north-east corner (2x4 framing and 1/2 in gypsum) into the attic. There a
14 x 8 in trunk runs west along y = 15 ft, just above the bottom chords. At mid-span the Fink webs are
near the peak, so the trunk passes through every truss between the webs without touching a member.
6 in round branches run north and south between the trusses to a 10 x 6 in ceiling register in each
room: bedrooms 2 and 3, two in the primary bedroom, both baths and the primary closet. At about
85 cfm per branch the second floor takes about 600 cfm, 770 ft/min in the 14 x 8 in trunk. The
ducts run inside the attic insulation, which is blown over them.

### Clearance against the framing

`runmat-design check house.assembly --interference` checks every body of every part pair. The batts
and the attic's loose fill are compressible: a run through an insulated cavity displaces the fill
(the installer splits or cuts the batt around it), so the interference check leaves bodies of batt
and loose-fill materials out and counts them. Every run passes framing, sheathing, finishes and
concrete only through the holes and cut-outs above.

## Materials

The thermal study reads these properties. Conductivities come from California Energy Commission,
*2013 Reference Appendices*, Joint Appendix JA4, Table 4.6.1, "Physical Properties of Materials",
converted to SI (1 Btu/h·ft·°F = 1.7307 W/m·K, 1 lb/ft³ = 16.018 kg/m³, 1 Btu/lb·°F = 4,186.8 J/kg·K,
1 h·ft²·°F/Btu = 0.17611 m²·K/W). `simulation/wall_thermal.fea` repeats each value and its source.

| Material (model layer) | JA4 code | k, W/m·K | ρ, kg/m³ | cp, J/kg·K | Source and note |
|---|---|---|---|---|---|
| Stucco, three coats | SC01 | 0.721 | 1,858 | 837 | 0.4167 Btu/h·ft·°F, 116 lb/ft³, 0.20 Btu/lb·°F. 7/8 in gives R-0.18 |
| Building paper, each layer | BP01 | 0.0751 | 480 | 1,380 | JA4 lists R-0.06 per layer only. k carries R-0.06 over the modeled 1/32 in. ρ and cp: ASHRAE Handbook—Fundamentals 2005, Ch. 25, Table 4, "Laminated paperboard", a stand-in |
| OSB sheathing, 7/16 in | PW03 | 0.115 | 545 | 1,214 | JA4's plywood row (0.0667 Btu/h·ft·°F, 34 lb/ft³, 0.29 Btu/lb·°F). 7/16 in gives R-0.55 |
| Douglas fir studs | WD05 | 0.115 | 513 | 1,382 | Softwood (0.0667 Btu/h·ft·°F, 32 lb/ft³, 0.33 Btu/lb·°F). 5 1/2 in gives R-6.88 |
| R-21 fiberglass batt, 5 1/2 in | (rated) | 0.0378 | 19 | 960 | k from the product's rated R-21 (FTC R-value Rule, 16 CFR Part 460). ρ and cp: ASHRAE Handbook—Fundamentals 2005, Ch. 30, Table 19, "I05 batt insulation" |
| Gypsum board, 1/2 in | GP01 | 0.160 | 801 | 1,089 | 0.0926 Btu/h·ft·°F, 50 lb/ft³, 0.26 Btu/lb·°F. R-0.45 |

Surface films come from the same JA4 (Table 4.6.2) and match the Washington State Energy Code,
WAC 51-11C, Table A101.5: interior vertical surface R-0.68, so h = 8.35 W/m²·K; exterior surface
R-0.17, so h = 33.4 W/m²·K.

A steady solve uses conductivity only. The density, specific heat, expansion coefficient and
modulus temperature coefficient in the study file don't affect its result. The 0.7 study format
requires them in every thermal material. The two temperature coefficients are set to 0, meaning
the study models no expansion. These entries will be removed once FEA G41 lifts that requirement.

The envelope table above gives OSB as R-0.62. JA4's panel conductivity gives R-0.55 for 7/16 in,
and the study uses that value. The difference moves the whole-wall U-factor from 0.0602 to
0.0605 Btu/h·ft²·°F.

## Studies

### Wall heat loss and the stud thermal bridge (`simulation/wall_thermal.fea`)

- **Question.** How much heat leaves through the exterior wall in winter, what is its U-factor,
  and how much more heat crosses the wall at a stud than through the insulated cavity?
- **Model.** `simulation/wall_section.part` is a section through the wall's layers at their modeled
  thicknesses. From outside in: 7/8 in stucco in three coats, two 1/32 in layers of building
  paper, 7/16 in OSB, a 2x6 stud beside an R-21 batt, and 1/2 in gypsum. The section spans half
  of one 16 in stud bay, from the centre of a stud to the centre of the cavity. Both cut planes
  are planes of symmetry, so the half bay stands for a long run of wall away from plates,
  openings and corners. The metal lath (open mesh inside the scratch coat) and the vapor retarder
  (R-0) are left out. `wall_thermal.assembly` exports it to `simulation/geometry/wall_thermal.step`.
  The mesh uses quadratic tetrahedra, 10 mm, refined to 1.5 mm in the papers and 3 mm in the
  finish coat.
- **Boundary conditions.** Room air 21 °C on the gypsum face, h = 8.35 W/m²·K (inside film R-0.68).
  Outdoor air -10 °C on the stucco face, h = 33.4 W/m²·K (outside film R-0.17). Both films are from
  CEC JA4 Table 4.6.2 (see Materials). The cut planes carry no heat. The 31 K difference is a
  winter design condition.
- **Hand estimate** (1-D series resistances in h·ft²·°F/Btu, materials as in Materials):
  - The outside film, stucco, papers, OSB, gypsum and inside film sum to 2.15. Through the batt,
    R = 23.15 (4.077 m²·K/W), so U = 0.245 W/m²·K and the flux is 7.60 W/m² at 31 K.
  - Through the stud, R = 9.03 (1.590 m²·K/W), so U = 0.629 W/m²·K and the flux is 19.5 W/m², 2.56 ×
    the cavity's.
  - The stud is 9.4 % of the half bay's width. As parallel paths, U = 0.281 W/m²·K, 8.72 W/m², and
    0.00886 W through the 203.2 x 5 mm study slice.
- **Solved.** Solve pending.
- **Result.** Solve pending.

### Envelope heat loss at the design difference (hand estimate)

Walls, windows and doors at 31 K (21 °C inside, -10 °C outside). Areas are from the opening schedule and
the levels. The gross wall is 140 ft of perimeter by 18 ft 2 7/8 in (slab to the second-floor top
plates), 2,554 sq ft. The windows and doors are 334 sq ft at their unit sizes, which leaves 2,220
sq ft of opaque wall. U-factors are the window and door ratings in "Windows and doors". The wall
U-factor is the parallel-path 0.0605 Btu/h·ft²·°F at the whole wall's 25.6 % framing fraction.

| Element | Area, sq ft | U, Btu/h·ft²·°F | UA, W/K | Heat loss at 31 K, W |
|---|---|---|---|---|
| Opaque wall | 2,220 | 0.0605 | 70.8 | 2,196 |
| Windows W1 to W5 (one W1, seven W2, ten W3, two W4, one W5) | 274 | 0.25 to 0.28 | 39.4 | 1,221 |
| Doors D1 and D2 | 60 | 0.20 and 0.30 | 8.4 | 262 |
| Walls, windows and doors | 2,554 | | 118.6 | 3,679 |

The ceiling, the slab edge and air leakage are not included. The walls carry 60 % of this heat
and the windows a third, from 11 % of the area.

## Model notes

- `framing/wall_framing.part` and `framing/shear_wall.part` hold one configuration per wall line and
  level (`wall_a_l1` ... `wall_5_l2`). Each opening slot sets its rough opening, head, header depth
  and jack zone; unused slots are suppressed. Studs that fall inside an opening stay on layout as
  cripples above the header and below the rough sill.
- Connectors pass through holes in the parts they fasten, so the interference check reports no
  overlap for them. The sill, bottom plates, first-floor top plates and floor system have 11/16 in
  bored holes for the 5/8 in anchor bolts and hold-down rods. The stem wall, footing and slab hold
  cast-in voids around the anchor bolts, hold-down rods, footing dowels and post-base anchors, 1/32
  in over the bar diameter so the faces don't coincide. Each set of holes is a feature block marked
  "Connector holes" in its part, one per wall configuration.
- Joist-hanger seats sit 0.048 in under the joists they carry. The first-floor ceiling board is
  relieved 1/16 in deep over each seat, in a 1/32 in oversize pocket.
- Truss plates stop 1/16 in under the top-chord faces, so no plate reaches the roof sheathing.
- The pressure-treated sill, XPS, OSB, LVL, concrete, gravel and rebar each carry a material, so mass
  properties and the thermal studies read them from the model.
- `envelope/exterior_wall.part` holds the same eight configurations as the framing. Each layer is
  an output with its material and color, and the batts are one feature per wall: one body per
  cavity, between the studs, posts, end posts, king and jack studs, and around the headers and rough
  sills. The batts start 1 in above the first-floor sill plates to clear the anchor-bolt nuts and
  washers, and 2 1/2 in in from the wall ends to clear the hold-downs.
- Windows (`window.part`, configurations W1 to W5) and doors (`door.part`, D1 and D2) attach to the
  skeleton's opening frames. Interior doors, partitions and fixtures are placed in building
  coordinates in `interior/interior.assembly`.
- The primary bath's 60 in double vanity stands on the south wall, x = 20'-6" to 25'-6", clear of the
  closet door in the east partition.
- Kitchen and vanity cabinets are carcasses: 3/4 in sides and bottom, a 1/4 in back, 3/4 in doors
  and a toe kick 4 in high and 3 in deep. The sink base and the vanities have no back, so the
  supplies and drains come through the wall into the cabinet.
- Pipe, conduit, cable and line-set runs are swept along their centerlines with the profile
  following the path (`sweep(..., follow_path = true)`), mitred at the bends where the fittings
  are. Each run is one body per planar stretch: a run that leaves its plane starts a new body at
  that point.
- `interior/partitions.part` holds one configuration per partition. `floor_finishes.part` also holds
  the first-floor ceiling, and `envelope/roof.part` holds the second-floor ceiling.
