% Phenotypic phase plane of a small metabolic network: the best growth rate for each
% pair of glucose and oxygen uptake limits, by flux balance analysis (one linear
% program per point). Growth rises with oxygen until glucose becomes the limit.
% Reactions: 1 glucose uptake, 2 oxygen uptake, 3 glycolysis, 4 respiration,
% 5 fermentation, 6 biomass. Metabolites: glucose, oxygen, pyruvate, ATP.
S = [ 1  0 -1  0  0   0;     % glucose
      0  1  0 -1  0   0;     % oxygen
      0  0  2 -1 -1  -1;     % pyruvate
      0  0  2 14  1 -10];    % ATP
c = [0 0 0 0 0 -1]';          % maximize biomass
glc = linspace(0, 10, 21);  oxy = linspace(0, 20, 21);
growth = zeros(numel(oxy), numel(glc));
for a = 1:numel(glc)
    for b = 1:numel(oxy)
        ub = [glc(a); oxy(b); 1000; 1000; 1000; 1000];
        [~, fval] = linprog(c, [], [], S, zeros(4, 1), zeros(6, 1), ub);
        growth(b, a) = -fval;
    end
end
fprintf('best growth %.2f per hour at the highest glucose and oxygen limits\n', growth(end, end));
fprintf('with no oxygen, growth %.2f per hour at the same glucose limit\n', growth(1, end));

[G, O] = meshgrid(glc, oxy);
surf(G, O, growth);
view(-50, 28);
title('Phenotypic phase plane');
xlabel('Glucose uptake (mmol/gDW/h)');
ylabel('Oxygen uptake (mmol/gDW/h)');
zlabel('Growth rate (1/h)');
