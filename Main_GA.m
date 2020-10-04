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

x = ga_func();

[best_position_GA, best_routes_GA, routsIdx] = ga_func()
%%
[costFun_GA,LongestLink,ShortestIntraDist] = costFunCalc(best_routes_GA);

figure_plot(best_position_GA, best_routes_GA, costFun_GA, 'GA')
% figure_plot3d(best_position_GA, best_routes_GA, costFun_GA)

%% PSO
tic
[best_position_PSO, best_routes_PSO, BestRoutIdx] = PSOAlgorithm_func(P.muPosition,P.gcsPosition, P.rNum);
[costFun_PSO,LongestLink,ShortestIntraDist] = costFunCalc(best_routes_PSO);
t_PSO = toc;
disp(['PSO calculation time = ', num2str(t_PSO)])
%%

figure_plot(best_position_PSO, best_routes_PSO, costFun_PSO, 'PSO')


%%
% [best_position_GA, best_routes_GA] = geneticAlgorithm_func(muPosition,gcsPosition, rNum, P);
