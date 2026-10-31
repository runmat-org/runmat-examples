values = [35 25 20 12 8];
labels = {'Engineering', 'Marketing', 'Operations', 'R&D', 'Admin'};
explode = [1 0 0 0 0];

pie(values, explode, labels);
title('Annual Budget Allocation');
