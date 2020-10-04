function x = ga_func()
global P

lb = reshape(repmat([0; 0; 50], 1, P.rNum), [3*P.rNum, 1]);
ub = reshape(repmat([1500; 1500; 150], 1, P.rNum), [3*P.rNum, 1]);
options = optimoptions('ga','ConstraintTolerance',1e-6,'PlotFcn', @gaplotbestf);
options.CrossoverFraction = 0.7;
options.EliteCount = 10;
options.PopulationSize = 100;

% selection functions
% options.SelectionFcn = 'selectionstochunif';
% options.SelectionFcn = 'selectionroulette';
options.SelectionFcn = 'selectionremainder';

% crossover
options.CrossoverFcn = 'crossoverscattered';
% options.CrossoverFcn =  'crossoverarithmetic' ;

% options.CrossoverFcn =  'crossoverheuristic';
% options.CrossoverFcn = 'crossoversinglepoint' ;
% options.CrossoverFcn =  'crossovertwopoint' ;



% mutation
% options.MutationFcn = 'mutationgaussian';
options.MutationFcn = @mutationadaptfeasible;
% options.MutationFcn = 'mutationuniform';

%%
tic
[x,fval] = ga(@costfunction_evaluation_solo,3*P.rNum,[],[],[],[],lb,ub,[], options);
t_GA = toc;

disp(['GA calculation time = ', num2str(t_GA)])
end