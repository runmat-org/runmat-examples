results = [92 88 81 76; 85 91 87 82; 78 84 93 89; 90 86 80 94];
conditions = {'Cold', 'Nominal', 'Hot', 'Vibration'};
components = {'Pump A', 'Pump B', 'Valve A', 'Valve B'};

h = heatmap(conditions, components, results);
h.Title = 'Component Test Score';
h.XLabel = 'Test condition';
h.YLabel = 'Component';
h.Colormap = 'turbo';
h.ColorbarVisible = true;
