% Gearbox vibration workbench
% A run-up accelerometer record from a single-stage gearbox: the shaft
% speeds up from 20 to 40 Hz, so the gear-mesh tone sweeps upward. Filter
% the record and compare its waveform, spectrum and spectrogram.

fs = 8000;                                  % sample rate, Hz
t = (0:1/fs:4 - 1/fs)';
teeth = 32;                                 % pinion teeth
shaft = 20 + 5*t;                           % shaft speed, Hz (run-up)
phase = 2*pi*cumsum(shaft)/fs;

mesh = 0.9*sin(teeth*phase) .* (1 + 0.35*sin(phase));    % mesh tone with sidebands
mesh2 = 0.35*sin(2*teeth*phase + 0.4);                    % second mesh harmonic
unbalance = 0.6*sin(phase);                               % 1x shaft

% Outer-race bearing defect: impacts at 3.1x shaft speed ring a 2.6 kHz resonance
impacts = zeros(size(t));
hits = find(diff(floor(3.1*phase/(2*pi))) > 0);
impacts(hits) = 1;
ring = exp(-t(1:200)*900) .* sin(2*pi*2600*t(1:200));
bearing = 1.4*filter(ring, 1, impacts);

rng(7);
x = unbalance + mesh + mesh2 + bearing + 0.25*randn(size(t));

% ---- Window and layout ------------------------------------------------
fig = uifigure('Name', 'Vibration Workbench', 'Position', [80 80 1280 780]);
fileMenu = uimenu(fig, 'Text', 'File');
uimenu(fileMenu, 'Text', 'Open record...', 'Accelerator', 'O');
uimenu(fileMenu, 'Text', 'Export spectrum...', 'Accelerator', 'E');
viewMenu = uimenu(fig, 'Text', 'View');
uimenu(viewMenu, 'Text', 'Linear frequency axis', 'Checked', 'on');
uimenu(viewMenu, 'Text', 'Order tracking', 'Separator', 'on');

root = uigridlayout(fig, [1 2]);
root.ColumnWidth = {300, '1x'};
root.Padding = [12 12 12 12];
root.ColumnSpacing = 12;

side = uigridlayout(root, [3 1]);
side.RowHeight = {200, 250, '1x'};
side.Padding = [0 0 0 0];
side.RowSpacing = 12;

rec = uipanel(side, 'Title', 'Record');
rg = uigridlayout(rec, [5 2]);
rg.ColumnWidth = {110, '1x'};
rg.RowHeight = repmat({22}, 1, 5);
uilabel(rg, 'Text', 'Channel');
uilabel(rg, 'Text', 'Input shaft, radial');
uilabel(rg, 'Text', 'Sample rate');
uilabel(rg, 'Text', sprintf('%.0f Hz', fs));
uilabel(rg, 'Text', 'Duration');
uilabel(rg, 'Text', sprintf('%.1f s run-up', t(end)));
uilabel(rg, 'Text', 'Shaft speed');
uilabel(rg, 'Text', '20 \rightarrow 40 Hz', 'Interpreter', 'tex');
uilabel(rg, 'Text', 'Gear mesh');
uilabel(rg, 'Text', 'f_{mesh} = 32 f_{shaft}', 'Interpreter', 'tex');

% Classic uicontrol controls and the app controls beside them sit at
% pixel positions measured from the panel's lower-left corner.
flt = uipanel(side, 'Title', 'Filter');
uilabel(flt, 'Text', 'Type', 'Position', [8 180 100 24]);
typeMenu = uicontrol(flt, 'Style', 'popupmenu', 'String', {'Band-pass', 'Low-pass', 'High-pass'}, ...
    'Position', [112 180 176 26]);
uilabel(flt, 'Text', 'Low cut (Hz)', 'Position', [8 144 100 24]);
lowEdit = uieditfield(flt, 'numeric', 'Value', 2000, 'Limits', [1 3999], 'Position', [112 144 176 26]);
uilabel(flt, 'Text', 'High cut (Hz)', 'Position', [8 108 100 24]);
highEdit = uieditfield(flt, 'numeric', 'Value', 3200, 'Limits', [1 3999], 'Position', [112 108 176 26]);
uilabel(flt, 'Text', 'Order', 'Position', [8 72 100 24]);
orderSlider = uicontrol(flt, 'Style', 'slider', 'Min', 2, 'Max', 8, 'Value', 4, ...
    'SliderStep', [1/6 1/6], 'Position', [112 76 176 18]);
showRaw = uicheckbox(flt, 'Text', 'Overlay raw', 'Value', true, 'Position', [8 40 200 24]);
apply = uibutton(flt, 'Text', 'Apply filter', 'Icon', 'success', 'Position', [8 4 280 30]);

stats = uipanel(side, 'Title', 'Filtered signal');
sg = uigridlayout(stats, [3 2]);
sg.ColumnWidth = {110, '1x'};
sg.RowHeight = {22, 22, 22};
uilabel(sg, 'Text', 'RMS');
rmsLabel = uilabel(sg, 'Text', '');
uilabel(sg, 'Text', 'Peak');
peakLabel = uilabel(sg, 'Text', '');
uilabel(sg, 'Text', 'Crest factor');
crestLabel = uilabel(sg, 'Text', '');

plots = uigridlayout(root, [3 1]);
plots.RowHeight = {'1x', '1x', '1.4x'};
plots.Padding = [0 0 0 0];
plots.RowSpacing = 10;
axTime = uiaxes(plots);
axPsd = uiaxes(plots);
axSpec = uiaxes(plots);

ui = struct('typeMenu', typeMenu, 'lowEdit', lowEdit, 'highEdit', highEdit, ...
    'orderSlider', orderSlider, 'showRaw', showRaw, 'axTime', axTime, ...
    'axPsd', axPsd, 'axSpec', axSpec, 'rms', rmsLabel, 'peak', peakLabel, ...
    'crest', crestLabel);
apply.ButtonPushedFcn = @(src, event) analyze(ui, t, x, fs);
analyze(ui, t, x, fs);

function analyze(ui, t, x, fs)
    order = round(ui.orderSlider.Value);
    lo = ui.lowEdit.Value;
    hi = ui.highEdit.Value;
    switch ui.typeMenu.Value
        case 1
            [b, a] = butter(order, [lo hi]/(fs/2), 'bandpass');
        case 2
            [b, a] = butter(order, hi/(fs/2), 'low');
        otherwise
            [b, a] = butter(order, lo/(fs/2), 'high');
    end
    y = filtfilt(b, a, x);

    % Waveform: a 0.25 s window late in the run-up
    k = t >= 3.5 & t < 3.75;
    if ui.showRaw.Value
        plot(ui.axTime, t(k), x(k), 'Color', [0.72 0.75 0.80]);
        hold(ui.axTime, 'on');
        plot(ui.axTime, t(k), y(k), 'Color', [0.00 0.45 0.74], 'LineWidth', 1.2);
        hold(ui.axTime, 'off');
        legend(ui.axTime, 'Raw', 'Filtered');
    else
        plot(ui.axTime, t(k), y(k), 'Color', [0.00 0.45 0.74], 'LineWidth', 1.2);
    end
    grid(ui.axTime, 'on');
    title(ui.axTime, 'Acceleration, t = 3.50 to 3.75 s');
    xlabel(ui.axTime, 'Time (s)');
    ylabel(ui.axTime, 'a (g)');

    % Welch power spectral density of raw and filtered records
    [pxx, fr] = pwelch(x, hann(2048), 1024, 2048, fs);
    [pyy, ~] = pwelch(y, hann(2048), 1024, 2048, fs);
    plot(ui.axPsd, fr, 10*log10(pxx), 'Color', [0.72 0.75 0.80]);
    hold(ui.axPsd, 'on');
    plot(ui.axPsd, fr, 10*log10(pyy), 'Color', [0.85 0.33 0.10], 'LineWidth', 1.2);
    hold(ui.axPsd, 'off');
    grid(ui.axPsd, 'on');
    xlim(ui.axPsd, [0 fs/2]);
    ylim(ui.axPsd, [-90 0]);
    title(ui.axPsd, 'Power spectral density (Welch, 2048-point Hann)');
    xlabel(ui.axPsd, 'Frequency (Hz)');
    ylabel(ui.axPsd, 'PSD (dB re 1 g^2/Hz)');

    % Short-time Fourier transform of the raw record
    nfft = 512;  hop = 128;
    w = hann(nfft);
    starts = 1:hop:numel(x) - nfft;
    S = zeros(nfft/2 + 1, numel(starts));
    for c = 1:numel(starts)
        seg = x(starts(c):starts(c) + nfft - 1) .* w;
        F = fft(seg);
        S(:, c) = abs(F(1:nfft/2 + 1)).^2;
    end
    tc = (starts + nfft/2)/fs;
    fc = (0:nfft/2)*fs/nfft;
    imagesc(ui.axSpec, tc, fc, 10*log10(S + 1e-6));
    axis(ui.axSpec, 'xy');
    colormap(ui.axSpec, turbo);
    clim(ui.axSpec, [5 45]);
    colorbar(ui.axSpec);
    title(ui.axSpec, 'Spectrogram (raw): gear mesh 640 \rightarrow 1280 Hz');
    xlabel(ui.axSpec, 'Time (s)');
    ylabel(ui.axSpec, 'Frequency (Hz)');

    ui.rms.Text = sprintf('%.3f g', sqrt(mean(y.^2)));
    ui.peak.Text = sprintf('%.3f g', max(abs(y)));
    ui.crest.Text = sprintf('%.2f', max(abs(y))/sqrt(mean(y.^2)));
end
