clc
clear all
close all

global P

InitialParams;

P.rNum = 10;

nStep = 1000;
levyFlightModel;

lb = reshape(repmat([0; 0; 50], 1, P.rNum), [3*P.rNum, 1]);
ub = reshape(repmat([1500; 1500; 150], 1, P.rNum), [3*P.rNum, 1]);

options = optimoptions('ga','ConstraintTolerance',1e-6,'PlotFcn', @gaplotbestf);

[x,fval] = ga(@costfunction_evaluation_solo,3*P.rNum,[],[],[],[],lb,ub,[], options);
best_position_GA = reshape(x, [3, P.rNum]);
[best_routes_GA , routsIdx] = RoutingProtocol(P.muPosition,P.gcsPosition,best_position_GA);

%%
figure;
scatter(P.muPosition(1,:) , P.muPosition(2,:)  ,'pentagram');
hold on
scatter(P.gcsPosition(1), P.gcsPosition(2) ,'g');
hold on
scatter(best_position_GA(1,:),best_position_GA(2,:),'k');
for mf = 1: size(muPosition,2)
    hold all;
    plot(best_routes_GA{mf}(1,:),best_routes_GA{mf}(2,:))
    hold off
end
title('Genetic Algorithm')
xlim([0 1500])
ylim([0 1500])
%% PSO
[best_position_PSO, best_routes_PSO] = PSOAlgorithm_func(P.muPosition,P.gcsPosition, P.rNum);

%%
figure;
scatter(P.muPosition(1,:) , P.muPosition(2,:)  ,'pentagram');
hold on
scatter(P.gcsPosition(1), P.gcsPosition(2) ,'g');
hold on
scatter(best_position_PSO(1,:),best_position_PSO(2,:),'k');
hold off
for mf = 1: size(P.muPosition,2)
    hold all;
    plot(best_routes_PSO{mf}(1,:),best_routes_PSO{mf}(2,:))
    hold off
end
title('PSO')
xlim([0 1500])
ylim([0 1500])

%%
% [best_position_GA, best_routes_GA] = geneticAlgorithm_func(muPosition,gcsPosition, rNum, P);
