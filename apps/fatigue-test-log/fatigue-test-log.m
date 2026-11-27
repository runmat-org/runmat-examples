% Fatigue test log
% Constant-amplitude fatigue results for three alloys. The table holds the
% specimen records; the plot shows the S-N data with a Basquin fit
% sigma_a = sigma_f' (2N)^b for the selected alloy.

alloys = {'Al 7075-T6', 'Ti-6Al-4V', 'Steel 4340'};
sf = [1050 1900 1650];      % fatigue strength coefficient, MPa
bx = [-0.110 -0.095 -0.087];  % Basquin exponent
hiFrac = [0.36 0.42 0.45];  loFrac = [0.19 0.24 0.27];
rng(11);
spec = {};  alloy = {};  amp = [];  cycles = [];  outcome = {};
for k = 1:3
    s = sf(k) * linspace(hiFrac(k), loFrac(k), 8);   % stress amplitudes, MPa
    for j = 1:numel(s)
        N = 0.5 * (s(j)/sf(k))^(1/bx(k)) * exp(0.35*randn);
        spec{end+1, 1} = sprintf('%s-%02d', char('A' + k - 1), j);
        alloy{end+1, 1} = alloys{k};
        amp(end+1, 1) = round(s(j));
        if N > 1e7
            cycles(end+1, 1) = 1e7;
            outcome{end+1, 1} = 'Runout';
        else
            cycles(end+1, 1) = round(N);
            outcome{end+1, 1} = 'Failed';
        end
    end
end
results = table(spec, alloy, amp, cycles, outcome, ...
    'VariableNames', {'Specimen', 'Alloy', 'Amplitude_MPa', 'Cycles', 'Result'});

fig = uifigure('Name', 'Fatigue Test Log', 'Position', [80 80 1280 720]);
root = uigridlayout(fig, [2 2]);
root.ColumnWidth = {470, '1x'};
root.RowHeight = {'1x', 150};
root.Padding = [12 12 12 12];
root.ColumnSpacing = 12;
root.RowSpacing = 12;

tbl = uitable(root, 'Data', results);
tbl.Layout.Row = [1 2];

ax = uiaxes(root);

% Controls sit at pixel positions from the panel's lower-left corner.
ctl = uipanel(root, 'Title', 'Fit');
uilabel(ctl, 'Text', 'Alloy', 'Position', [8 80 80 24]);
alloyMenu = uicontrol(ctl, 'Style', 'popupmenu', 'String', alloys, 'Value', 2, ...
    'Position', [96 80 220 26]);
fitBtn = uibutton(ctl, 'Text', 'Fit Basquin', 'Icon', 'success', 'Position', [332 78 160 30]);
uilabel(ctl, 'Text', 'Fit', 'Position', [8 44 80 24]);
fitLabel = uilabel(ctl, 'Text', '', 'Interpreter', 'tex', 'Position', [96 44 560 24]);
uilabel(ctl, 'Text', 'Endurance', 'Position', [8 10 80 24]);
endLabel = uilabel(ctl, 'Text', '', 'Interpreter', 'tex', 'Position', [96 10 560 24]);

ui = struct('ax', ax, 'alloy', alloyMenu, 'fit', fitLabel, 'endurance', endLabel);
fitBtn.ButtonPushedFcn = @(src, event) fitAlloy(ui, results, alloys);
alloyMenu.Callback = @(src, event) fitAlloy(ui, results, alloys);
fitAlloy(ui, results, alloys);

function fitAlloy(ui, results, alloys)
    colors = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.47 0.67 0.19];
    sel = ui.alloy.Value;
    cla(ui.ax);
    hold(ui.ax, 'on');
    for k = 1:numel(alloys)
        r = strcmp(results.Alloy, alloys{k});
        failed = r & strcmp(results.Result, 'Failed');
        runout = r & strcmp(results.Result, 'Runout');
        sz = 36 + 30*(k == sel);
        scatter(ui.ax, results.Cycles(failed), results.Amplitude_MPa(failed), sz, colors(k,:), 'filled');
        if any(runout)   % open markers: runouts
            scatter(ui.ax, results.Cycles(runout), results.Amplitude_MPa(runout), sz, colors(k,:));
        end
    end
    r = strcmp(results.Alloy, alloys{sel}) & strcmp(results.Result, 'Failed');
    p = polyfit(log10(2*results.Cycles(r)), log10(results.Amplitude_MPa(r)), 1);
    Nfit = logspace(3, 7.3, 50);
    plot(ui.ax, Nfit, 10^p(2) * (2*Nfit).^p(1), '-', 'Color', colors(sel,:), 'LineWidth', 2);
    hold(ui.ax, 'off');
    set(ui.ax, 'XScale', 'log');
    grid(ui.ax, 'on');
    xlim(ui.ax, [1e3 2e7]);
    title(ui.ax, sprintf('S-N data, Basquin fit for %s', alloys{sel}));
    xlabel(ui.ax, 'Cycles to failure N');
    ylabel(ui.ax, 'Stress amplitude \sigma_a (MPa)');

    ui.fit.Text = sprintf('\\sigma_a = %.0f (2N)^{%.3f} MPa', 10^p(2), p(1));
    ui.endurance.Text = sprintf('\\sigma_a at 10^7 cycles = %.0f MPa', 10^p(2) * (2e7)^p(1));
end
