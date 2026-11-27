% Circuit board thermal explorer
% Steady temperature of a 120 x 80 mm board carrying three chips, cooled
% by air on both faces. Change the processor power, the air temperature
% or the colormap; the field is re-solved on each change.

fig = uifigure('Name', 'Board Thermal Explorer', 'Position', [80 80 1280 720]);
root = uigridlayout(fig, [1 2]);
root.ColumnWidth = {300, '1x'};
root.Padding = [12 12 12 12];
root.ColumnSpacing = 12;

side = uigridlayout(root, [3 1]);
side.RowHeight = {250, 150, '1x'};
side.Padding = [0 0 0 0];
side.RowSpacing = 12;

% Controls sit at pixel positions from the panel's lower-left corner.
op = uipanel(side, 'Title', 'Operating point');
powerLabel = uilabel(op, 'Text', 'Processor  P_1 = 6.0 W', 'Interpreter', 'tex', ...
    'Position', [8 186 280 24]);
powerSlider = uicontrol(op, 'Style', 'slider', 'Min', 1, 'Max', 12, 'Value', 6, ...
    'Position', [8 164 280 18]);
uilabel(op, 'Text', 'Regulator  P_2', 'Interpreter', 'tex', 'Position', [8 124 120 24]);
uilabel(op, 'Text', '2.5 W', 'Position', [132 124 156 24]);
uilabel(op, 'Text', 'Air temperature', 'Position', [8 88 120 24]);
ambient = uieditfield(op, 'numeric', 'Value', 25, 'Limits', [-20 70], ...
    'ValueDisplayFormat', '%.0f °C', 'Position', [132 88 156 26]);
uilabel(op, 'Text', 'Heat transfer h', 'Position', [8 52 120 24]);
uilabel(op, 'Text', '25 W/(m^2 K)', 'Interpreter', 'tex', 'Position', [132 52 156 24]);
uilabel(op, 'Text', 'Colormap', 'Position', [8 16 120 24]);
cmapMenu = uicontrol(op, 'Style', 'popupmenu', 'String', {'hot', 'turbo', 'parula', 'jet'}, ...
    'Position', [132 16 156 26]);

res = uipanel(side, 'Title', 'Results');
rg = uigridlayout(res, [3 2]);
rg.ColumnWidth = {120, '1x'};
rg.RowHeight = {24, 24, 24};
uilabel(rg, 'Text', 'Hot spot', 'FontWeight', 'bold');
tmax = uilabel(rg, 'Text', '', 'Interpreter', 'tex', 'FontWeight', 'bold');
uilabel(rg, 'Text', 'Board mean');
tmean = uilabel(rg, 'Text', '', 'Interpreter', 'tex');
uilabel(rg, 'Text', 'Limit (T_j 105 °C)', 'Interpreter', 'tex');
margin = uilabel(rg, 'Text', '');

notes = uipanel(side, 'Title', 'Board');
ng = uigridlayout(notes, [4 1]);
ng.RowHeight = {22, 22, 22, 22};
uilabel(ng, 'Text', 'FR-4, 1.6 mm, 2 oz copper planes');
uilabel(ng, 'Text', 'k_{in-plane} = 18 W/(m K)', 'Interpreter', 'tex');
uilabel(ng, 'Text', 'Chips: processor, regulator, memory');
uilabel(ng, 'Text', 'Solved on a 97 \times 65 grid', 'Interpreter', 'tex');

plots = uigridlayout(root, [2 2]);
plots.RowHeight = {'1.3x', '1x'};
plots.ColumnWidth = {'1x', '1x'};
plots.Padding = [0 0 0 0];
plots.RowSpacing = 12;
plots.ColumnSpacing = 12;
ax3 = uiaxes(plots);
ax3.Layout.Column = [1 2];
ax2 = uiaxes(plots);
ax1 = uiaxes(plots);

ui = struct('power', powerSlider, 'powerLabel', powerLabel, 'ambient', ambient, ...
    'cmap', cmapMenu, 'ax3', ax3, 'ax2', ax2, 'ax1', ax1, 'tmax', tmax, 'tmean', tmean, 'margin', margin);
update = @(src, event) solveBoard(ui);
powerSlider.Callback = update;
cmapMenu.Callback = update;
ambient.ValueChangedFcn = update;
solveBoard(ui);

function solveBoard(ui)
    Lx = 0.120;  Ly = 0.080;  nx = 97;  ny = 65;
    dx = Lx/(nx - 1);  dy = Ly/(ny - 1);
    k = 18;  tk = 1.6e-3;  h = 25;
    Ta = ui.ambient.Value;
    P1 = ui.power.Value;

    [X, Y] = meshgrid(linspace(0, Lx, nx), linspace(0, Ly, ny));
    q = zeros(ny, nx);                                % W/m^2
    chips = [0.040 0.045 0.020 0.020 P1;              % x, y, w, h, power
             0.090 0.022 0.012 0.010 2.5;
             0.092 0.058 0.016 0.012 1.2];
    for c = 1:size(chips, 1)
        in = abs(X - chips(c,1)) <= chips(c,3)/2 & abs(Y - chips(c,2)) <= chips(c,4)/2;
        q(in) = chips(c,5) / (chips(c,3)*chips(c,4));
    end

    % k t lap(T) - 2 h (T - Ta) + q = 0, insulated edges
    ex = ones(nx, 1);  ey = ones(ny, 1);
    Dx = spdiags([ex -2*ex ex], -1:1, nx, nx);  Dx(1,2) = 2;  Dx(nx,nx-1) = 2;
    Dy = spdiags([ey -2*ey ey], -1:1, ny, ny);  Dy(1,2) = 2;  Dy(ny,ny-1) = 2;
    L = kron(Dx/dx^2, speye(ny)) + kron(speye(nx), Dy/dy^2);
    A = k*tk*L - 2*h*speye(nx*ny);
    T = Ta + reshape(A \ (-q(:)), ny, nx);

    maps = struct('hot', hot(256), 'turbo', turbo(256), 'parula', parula(256), 'jet', jet(256));
    names = ui.cmap.String;
    cmap = maps.(names{ui.cmap.Value});

    surf(ui.ax3, X*1000, Y*1000, T, T);
    shading(ui.ax3, 'interp');
    colormap(ui.ax3, cmap);
    view(ui.ax3, -35, 38);
    title(ui.ax3, 'Board temperature');
    xlabel(ui.ax3, 'x (mm)');
    ylabel(ui.ax3, 'y (mm)');
    zlabel(ui.ax3, 'T (°C)');

    contourf(ui.ax2, X*1000, Y*1000, T, 18);
    colormap(ui.ax2, cmap);
    colorbar(ui.ax2);
    axis(ui.ax2, 'equal');
    title(ui.ax2, 'Isotherms (°C)');
    xlabel(ui.ax2, 'x (mm)');
    ylabel(ui.ax2, 'y (mm)');

    % Section through the processor, y = 45 mm
    row = round(0.045/dy) + 1;
    plot(ui.ax1, X(row,:)*1000, T(row,:), 'Color', [0.80 0.20 0.10], 'LineWidth', 2);
    hold(ui.ax1, 'on');
    plot(ui.ax1, [0 120], [105 105], '--', 'Color', [0.45 0.45 0.50]);
    hold(ui.ax1, 'off');
    grid(ui.ax1, 'on');
    xlim(ui.ax1, [0 120]);
    ylim(ui.ax1, [Ta 110]);
    title(ui.ax1, 'Section at y = 45 mm');
    xlabel(ui.ax1, 'x (mm)');
    ylabel(ui.ax1, 'T (°C)');

    ui.powerLabel.Text = sprintf('Processor  P_1 = %.1f W', P1);
    ui.tmax.Text = sprintf('T_{max} = %.1f °C', max(T(:)));
    ui.tmean.Text = sprintf('T_{mean} = %.1f °C', mean(T(:)));
    ui.margin.Text = sprintf('%.1f K margin', 105 - max(T(:)));
end
