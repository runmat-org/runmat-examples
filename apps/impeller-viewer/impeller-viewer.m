% Impeller geometry viewer
% A seven-blade centrifugal pump impeller built as a triangle mesh: hub,
% back shroud and swept blades. Turn the part, change its finish and read
% its surface area and mesh size.

[V, F] = buildImpeller(7);

fig = uifigure('Name', 'Impeller Viewer', 'Position', [80 80 1280 760]);
partMenu = uimenu(fig, 'Text', 'Part');
uimenu(partMenu, 'Text', 'Import mesh...', 'Accelerator', 'I');
uimenu(partMenu, 'Text', 'Export STL...', 'Accelerator', 'E');
viewMenu = uimenu(fig, 'Text', 'View');

root = uigridlayout(fig, [1 2]);
root.ColumnWidth = {'1x', 300};
root.Padding = [12 12 12 12];
root.ColumnSpacing = 12;

ax = uiaxes(root);

side = uigridlayout(root, [3 1]);
side.RowHeight = {160, 190, '1x'};
side.Padding = [0 0 0 0];
side.RowSpacing = 12;

% Controls sit at pixel positions from the panel's lower-left corner.
cam = uipanel(side, 'Title', 'Camera');
isoBtn = uibutton(cam, 'Text', 'Iso', 'Position', [8 88 88 30]);
topBtn = uibutton(cam, 'Text', 'Top', 'Position', [104 88 88 30]);
sideBtn = uibutton(cam, 'Text', 'Side', 'Position', [200 88 88 30]);
uilabel(cam, 'Text', 'Azimuth', 'Position', [8 52 80 24]);
azSlider = uicontrol(cam, 'Style', 'slider', 'Min', -180, 'Max', 180, 'Value', -30, ...
    'Position', [96 56 192 18]);
uilabel(cam, 'Text', 'Elevation', 'Position', [8 16 80 24]);
elSlider = uicontrol(cam, 'Style', 'slider', 'Min', -90, 'Max', 90, 'Value', 35, ...
    'Position', [96 20 192 18]);

look = uipanel(side, 'Title', 'Appearance');
uilabel(look, 'Text', 'Finish', 'Position', [8 120 80 24]);
finish = uicontrol(look, 'Style', 'popupmenu', ...
    'String', {'Bronze', 'Stainless steel', 'Anodized blue', 'Titanium'}, ...
    'Position', [96 120 192 26]);
uilabel(look, 'Text', 'Light', 'Position', [8 84 80 24]);
lightMenu = uicontrol(look, 'Style', 'popupmenu', ...
    'String', {'Headlight', 'Studio (upper left)'}, 'Value', 2, 'Position', [96 84 192 26]);
edges = uicheckbox(look, 'Text', 'Show mesh edges', 'Position', [8 48 200 24]);
shadeBtn = uibutton(look, 'Text', 'Render', 'Icon', 'info', 'Position', [8 8 280 30]);

info = uipanel(side, 'Title', 'Part properties');
ig = uigridlayout(info, [6 2]);
ig.ColumnWidth = {100, '1x'};
ig.RowHeight = repmat({22}, 1, 6);
e1 = V(F(:,2),:) - V(F(:,1),:);
e2 = V(F(:,3),:) - V(F(:,1),:);
area = 0.5 * sum(sqrt(sum(cross(e1, e2, 2).^2, 2)));
ext = max(V) - min(V);
uilabel(ig, 'Text', 'Blades');
uilabel(ig, 'Text', '7, backswept 28°');
uilabel(ig, 'Text', 'Outer diameter');
uilabel(ig, 'Text', sprintf('%.0f mm', ext(1)));
uilabel(ig, 'Text', 'Height');
uilabel(ig, 'Text', sprintf('%.0f mm', ext(3)));
uilabel(ig, 'Text', 'Wetted area');
uilabel(ig, 'Text', sprintf('%.0f cm^2', area/100), 'Interpreter', 'tex');
uilabel(ig, 'Text', 'Mesh');
uilabel(ig, 'Text', sprintf('%d triangles', size(F, 1)));
uilabel(ig, 'Text', 'Vertices');
uilabel(ig, 'Text', sprintf('%d', size(V, 1)));

ui = struct('ax', ax, 'az', azSlider, 'el', elSlider, 'finish', finish, ...
    'light', lightMenu, 'edges', edges);
render = @(src, event) drawPart(ui, V, F);
azSlider.Callback = render;
elSlider.Callback = render;
finish.Callback = render;
lightMenu.Callback = render;
edges.ValueChangedFcn = render;
shadeBtn.ButtonPushedFcn = render;
isoBtn.ButtonPushedFcn = @(src, event) setView(ui, V, F, -30, 35);
topBtn.ButtonPushedFcn = @(src, event) setView(ui, V, F, 0, 90);
sideBtn.ButtonPushedFcn = @(src, event) setView(ui, V, F, 0, 0);
uimenu(viewMenu, 'Text', 'Isometric', 'MenuSelectedFcn', @(src, event) setView(ui, V, F, -30, 35));
uimenu(viewMenu, 'Text', 'Top', 'MenuSelectedFcn', @(src, event) setView(ui, V, F, 0, 90));
drawPart(ui, V, F);

function setView(ui, V, F, az, el)
    ui.az.Value = az;
    ui.el.Value = el;
    drawPart(ui, V, F);
end

function drawPart(ui, V, F)
    base = [0.80 0.55 0.28; 0.72 0.74 0.77; 0.20 0.42 0.78; 0.62 0.62 0.66];
    shine = [0.55; 0.70; 0.45; 0.60];
    c = base(ui.finish.Value, :);
    az = ui.az.Value;  el = ui.el.Value;

    % Per-vertex normals, then Blinn-Phong shading with a fixed light
    e1 = V(F(:,2),:) - V(F(:,1),:);
    e2 = V(F(:,3),:) - V(F(:,1),:);
    fn = cross(e1, e2, 2);
    vn = zeros(size(V));
    for j = 1:3
        vn = vn + accumarray([repmat(F(:,j), 3, 1), kron((1:3)', ones(size(F,1), 1))], fn(:), size(V));
    end
    vn = vn ./ max(sqrt(sum(vn.^2, 2)), eps);

    camDir = [cosd(el)*sind(az), -cosd(el)*cosd(az), sind(el)];
    if ui.light.Value == 1
        L = camDir;
    else
        L = [cosd(el+35)*sind(az-50), -cosd(el+35)*cosd(az-50), sind(el+35)];
    end
    Hv = (L + camDir) / norm(L + camDir);
    nd = vn * L';
    vn(nd < 0, :) = -vn(nd < 0, :);                 % two-sided lighting
    diffuse = max(vn * L', 0);
    spec = max(vn * Hv', 0).^40;
    rim = (1 - abs(vn * camDir')).^3;
    C = 0.22*c + 0.70*diffuse.*c + shine(ui.finish.Value)*spec + 0.12*rim;
    C = min(C, 1);

    if ui.edges.Value
        ec = [0.15 0.15 0.18];
    else
        ec = 'none';
    end
    patch(ui.ax, 'Faces', F, 'Vertices', V, 'FaceVertexCData', C, ...
        'FaceColor', 'interp', 'EdgeColor', ec);
    axis(ui.ax, 'equal');
    axis(ui.ax, 'off');
    xlim(ui.ax, [-82 82]);
    ylim(ui.ax, [-82 82]);
    zlim(ui.ax, [0 56]);
    view(ui.ax, az, el);
    title(ui.ax, 'Pump impeller, 7 blades');
end

function [V, F] = buildImpeller(nb)
    V = zeros(0, 3);  F = zeros(0, 3);
    % Back shroud: disc of radius 80 mm, 6 mm thick, with rounded rim
    [V, F] = addRevolved(V, F, [12 80 80 12], [0 0 6 6], 96);
    % Hub: tapered nose from the shroud up to the eye
    r = [22 22 18 12 6 0];  z = [6 30 42 50 54 55];
    [V, F] = addRevolved(V, F, r, z, 96);
    % Blades: backswept log-spiral sheets of finite thickness
    nr = 28;  nz = 8;
    rb = linspace(24, 78, nr);
    beta = 28;                                       % blade angle, degrees
    th0 = log(rb/rb(1)) / tand(beta);                % spiral sweep
    hgt = 36 - 24*(rb - rb(1))/(rb(end) - rb(1));    % blade height falls with radius
    for k = 1:nb
        phi = 2*pi*(k - 1)/nb;
        for side = [-1 1]
            dth = side * 2.2 ./ rb;                  % 4.4 mm thick blade
            [R, S] = meshgrid(rb, linspace(0, 1, nz));
            TH = repmat(phi + th0 + dth, nz, 1);
            Z = 6 + S .* repmat(hgt, nz, 1);
            [V, F] = addGrid(V, F, R.*cos(TH), R.*sin(TH), Z);
        end
        % Blade tip cap and top edge
        thA = phi + th0 - 2.2./rb;  thB = phi + th0 + 2.2./rb;
        Xt = [rb.*cos(thA); rb.*cos(thB)];
        Yt = [rb.*sin(thA); rb.*sin(thB)];
        Zt = [6 + hgt; 6 + hgt];
        [V, F] = addGrid(V, F, Xt, Yt, Zt);
        zc = linspace(6, 6 + hgt(end), nz)';
        Xc = [rb(end)*cos(thA(end))*ones(nz,1), rb(end)*cos(thB(end))*ones(nz,1)];
        Yc = [rb(end)*sin(thA(end))*ones(nz,1), rb(end)*sin(thB(end))*ones(nz,1)];
        [V, F] = addGrid(V, F, Xc, Yc, [zc zc]);
    end
end

function [V, F] = addRevolved(V, F, r, z, n)
    th = linspace(0, 2*pi, n + 1);
    [TH, Rg] = meshgrid(th, r);
    Zg = repmat(z(:), 1, n + 1);
    [V, F] = addGrid(V, F, Rg.*cos(TH), Rg.*sin(TH), Zg);
end

function [V, F] = addGrid(V, F, X, Y, Z)
    [m, n] = size(X);
    base = size(V, 1);
    V = [V; X(:), Y(:), Z(:)];
    [I, J] = ndgrid(1:m-1, 1:n-1);
    p = base + I(:) + (J(:) - 1)*m;
    F = [F; p, p + 1, p + m + 1; p, p + m + 1, p + m];
end
