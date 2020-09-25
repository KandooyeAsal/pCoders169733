function [costFunBest, longestLink , shortestDist] = costfunction_evaluation_solo(Position)
global P
Position2 = reshape(Position, [3, P.rNum]);
[Routs , routsIdx] = RoutingProtocol(P.muPosition,P.gcsPosition,Position2);
[costFunBest] = costFunCalc(Routs);
end
