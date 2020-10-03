clc
clear all
close all

global P
rng('default')

InitialParams;

P.rNum = 6;

nStep = 1000;
levyFlightModel;

%% GA Parameters
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
best_position_GA = reshape(x, [3, P.rNum]);

[best_routes_GA , routsIdx] = RoutingProtocol(P.muPosition,P.gcsPosition,best_position_GA);
[costFun_GA,LongestLink,ShortestIntraDist] = costFunCalc(best_routes_GA);

disp(['GA calculation time = ', num2str(t_GA)])
%%

figure_plot(best_position_GA, best_routes_GA, costFun_GA)

%% PSO
tic
[best_position_PSO, best_routes_PSO] = PSOAlgorithm_func(P.muPosition,P.gcsPosition, P.rNum);
[costFun_PSO,LongestLink,ShortestIntraDist] = costFunCalc(best_routes_PSO);
t_PSO = toc;
disp(['PSO calculation time = ', num2str(t_PSO)])
%%

figure_plot(best_position_PSO, best_routes_PSO, costFun_PSO)


%%
% [best_position_GA, best_routes_GA] = geneticAlgorithm_func(muPosition,gcsPosition, rNum, P);
