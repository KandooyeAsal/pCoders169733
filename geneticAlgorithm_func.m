function [best_position_GA, best_routes_GA] = geneticAlgorithm_func(muPosition,gcsPosition, rNum, P)
P.P_selection = 0.7;



Position_GA = zeros(3 , rNum , P.np);
for d = 1:3
    Position_GA(d,:,:) = randi([P.spaceLim(d,1),P.spaceLim(d,2)],rNum, P.np);
end

%{
scatter(muPosition(1,:) , muPosition(2,:)  ,'pentagram');
hold on
scatter(gcsPosition(1), gcsPosition(2) ,'g');
xlim([0 1500])
ylim([0 1500])
pause(0.01)
%}

% [costFunBest , longestLink , shortestDist] = costfunction_evaluation(muPosition,gcsPosition,Position_GA,P);
iter_flag = true;
while iter_flag == true
    
selection;
cross_over;
mutation;
    
    costfunction_evaluation;
end
end