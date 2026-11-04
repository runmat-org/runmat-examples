function draw_sync_marks(S, f, yTop, xSpan, color, fontSize)
% DRAW_SYNC_MARKS  Marks each sync event on a plot against step.
%
%   draw_sync_marks(S, f, yTop, xSpan, color, fontSize) draws, in the current
%   axes, a dotted vertical line from 0 to yTop at each pose-graph solve in
%   S.eventSolve reached by step f, where the drones' shared maps correct
%   their poses and the position error starts to fall. A "sync" label sits
%   near the top, left of the line, so the last label stays inside the axes.
%   xSpan is the x-axis width in steps; fontSize sets the label size.
%   RunMat's text() centers on its anchor and rejects HorizontalAlignment,
%   so the anchor sits 7 % of the axis width left of the line: clear of it
%   both in printed frames and in the smaller interactive figure, where the
%   label takes a larger share of the axis.

    for e = 1:numel(S.eventSolve)
        t = S.eventSolve(e);
        if t > f
            continue;
        end
        plot([t t], [0 yTop], ':', 'Color', color, 'LineWidth', 2);
        text(t - 0.07 .* xSpan, 0.92 .* yTop, 'sync', 'FontSize', fontSize, 'Color', color);
    end
end
