function [costFun,LongestLink,ShortestIntraDist] = costFunCalc(Paths,P)
for mm = 1:length(Paths)
    nPath = size(Paths{mm},2);
    PathsRep = repmat(Paths{mm},nPath,1);
    
    PathsLoc1 = zeros(3*nPath,1);
    for l = 1:nPath
        PathsLoc1((l-1)*3+1:l*3,1) =  PathsRep((l-1)*3+1:l*3,l) ;
    end
    PathDiff = PathsRep - PathsLoc1;
    diff1 = reshape(PathDiff,3,[]);
    distances = round(sqrt(sum(diff1.^2)));
    distances = reshape(distances,nPath,[])';
    distances1 = distances(distances ~= 0)';
    
    delta = diff(Paths{mm},1,2);
    Distance = round(sqrt(sum(delta.^2)));
    metricTerm1 = sum(Distance .^ P.alpha);
    constraint1 = P.lambda * max(0 , max(Distance) - P.dCm)^2;
    constraint2 = P.mhu * max(0 , (P.dSf - min(distances1)))^2;
    
    costFun1(mm) = metricTerm1 + constraint1 + constraint2;
    LongestLink(mm) =  max(Distance);
    ShortestIntraDist(mm) = min(distances1);
end
costFun = sum(costFun1);
LongestLink = max(LongestLink);
ShortestIntraDist = min(ShortestIntraDist);
end