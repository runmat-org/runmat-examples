% Plate modal analysis app
% Natural frequencies and mode shapes of a simply supported aluminum
% plate. Pick a mode to see its shape; the table lists the first eight.

% Plate: 600 x 400 x 5 mm aluminum, simply supported on all edges
a = 0.600;  b = 0.400;  h = 0.005;            % m
E = 69e9;   nu = 0.33;  rho = 2700;           % Pa, -, kg/m^3
D = E*h^3 / (12*(1 - nu^2));                  % flexural rigidity, N*m

% Natural frequencies f_mn = (pi/2) ((m/a)^2 + (n/b)^2) sqrt(D/(rho h))
[M, N] = meshgrid(1:5, 1:5);
f = (pi/2) * ((M/a).^2 + (N/b).^2) * sqrt(D/(rho*h));
[f, order] = sort(f(:));
M = M(order);  N = N(order);
nModes = 8;
f = f(1:nModes);  M = M(1:nModes);  N = N(1:nModes);

[x, y] = meshgrid(linspace(0, a, 61), linspace(0, b, 41));

% ---- Window and layout ------------------------------------------------
fig = uifigure('Name', 'Plate Modal Analysis', 'Position', [80 80 1280 760]);
root = uigridlayout(fig, [1 2]);
root.ColumnWidth = {320, '1x'};
root.Padding = [12 12 12 12];
root.ColumnSpacing = 12;

% Left column: model summary, mode picker, frequency table
side = uigridlayout(root, [3 1]);
side.RowHeight = {176, 120, '1x'};
side.Padding = [0 0 0 0];
side.RowSpacing = 12;

model = uipanel(side, 'Title', 'Model');
mg = uigridlayout(model, [4 2]);
mg.ColumnWidth = {110, '1x'};
mg.RowHeight = {22, 22, 22, 22};
uilabel(mg, 'Text', 'Plate');
uilabel(mg, 'Text', '600 \times 400 \times 5 mm', 'Interpreter', 'tex');
uilabel(mg, 'Text', 'Material');
uilabel(mg, 'Text', 'Al 6061, E = 69 GPa', 'Interpreter', 'tex');
uilabel(mg, 'Text', 'Density');
uilabel(mg, 'Text', '\rho = 2700 kg/m^3', 'Interpreter', 'tex');
uilabel(mg, 'Text', 'Supports');
uilabel(mg, 'Text', 'Simply supported, 4 edges');

% Classic uicontrol controls sit in a panel at pixel positions
% measured from the panel's lower-left corner.
pick = uipanel(side, 'Title', 'Mode');
names = cell(1, nModes);
for k = 1:nModes
    names{k} = sprintf('Mode %d  (%d,%d)  %.1f Hz', k, M(k), N(k), f(k));
end
uilabel(pick, 'Text', 'Mode shape', 'Position', [8 52 96 24]);
modeMenu = uicontrol(pick, 'Style', 'popupmenu', 'String', names, 'Value', 3, ...
    'Position', [104 52 184 26]);
uilabel(pick, 'Text', 'Amplitude', 'Position', [8 14 96 24]);
ampSlider = uicontrol(pick, 'Style', 'slider', 'Min', 0.2, 'Max', 1.5, 'Value', 1, ...
    'Position', [104 18 184 18]);

freq = uipanel(side, 'Title', 'Natural frequencies');
fg = uigridlayout(freq, [nModes + 1, 3]);
fg.ColumnWidth = {50, 70, '1x'};
fg.RowHeight = repmat({24}, 1, nModes + 1);
fg.RowSpacing = 2;
uilabel(fg, 'Text', 'Mode', 'FontWeight', 'bold');
uilabel(fg, 'Text', '(m, n)', 'FontWeight', 'bold');
uilabel(fg, 'Text', 'Frequency', 'FontWeight', 'bold');
for k = 1:nModes
    uilabel(fg, 'Text', sprintf('%d', k));
    uilabel(fg, 'Text', sprintf('(%d, %d)', M(k), N(k)));
    uilabel(fg, 'Text', sprintf('f_{%d%d} = %.1f Hz', M(k), N(k), f(k)), 'Interpreter', 'tex');
end

% Right column: 3-D mode shape above, nodal-line contour below
plots = uigridlayout(root, [2 1]);
plots.RowHeight = {'1.5x', '1x'};
plots.Padding = [0 0 0 0];
plots.RowSpacing = 12;
ax3 = uiaxes(plots);
ax2 = uiaxes(plots);

draw = @(src, event) drawMode(ax3, ax2, x, y, a, b, M, N, f, modeMenu, ampSlider);
modeMenu.Callback = draw;
ampSlider.Callback = draw;
drawMode(ax3, ax2, x, y, a, b, M, N, f, modeMenu, ampSlider);

function drawMode(ax3, ax2, x, y, a, b, M, N, f, modeMenu, ampSlider)
    k = modeMenu.Value;
    amp = ampSlider.Value;
    w = amp * sin(M(k)*pi*x/a) .* sin(N(k)*pi*y/b);
    surf(ax3, x*1000, y*1000, w*120, w);
    shading(ax3, 'interp');
    colormap(ax3, turbo);
    clim(ax3, [-1.5 1.5]);
    view(ax3, -38, 32);
    title(ax3, sprintf('Mode %d  (m, n) = (%d, %d)   f = %.1f Hz', k, M(k), N(k), f(k)));
    xlabel(ax3, 'x (mm)');
    ylabel(ax3, 'y (mm)');

    contourf(ax2, x*1000, y*1000, w, 16);
    colormap(ax2, turbo);
    clim(ax2, [-1.5 1.5]);
    axis(ax2, 'equal');
    title(ax2, 'Displacement contours (nodal lines at w = 0)');
    xlabel(ax2, 'x (mm)');
    ylabel(ax2, 'y (mm)');
end
