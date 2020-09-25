function [costFunBest, longestLink , shortestDist] = costfunction_evaluation(muPosition,gcsPosition,Position,P)
[Routs , routsIdx] = RoutingProtocol(muPosition,gcsPosition,Position,P);
for n = 1:P.np
    [costFunBest(n) , longestLink(n) , shortestDist(n)] = costFunCalc(Routs(n,:),P);
end
end
