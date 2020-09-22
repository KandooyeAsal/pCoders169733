
%
Position = zeros(3 , rNum , P.np);
velocity = zeros(3 , rNum , P.np);
for d = 1:3
    Position(d,:,:) = randi([spaceLim(d,1),spaceLim(d,2)],rNum, P.np);
end

[Routs , routsIdx] = RoutingProtocol(muPosition,gcsPosition,Position,P);

for n = 1:P.np
    [costFunBest(n) , longestLink(n) , shortestDist(n)] = costFunCalc(Routs(n,:),P);
end

pBestI = Position;
[costFunFinal,idxG] = min(costFunBest);
gBest = pBestI(:,:,idxG);

RoutsBest = Routs;
u1 = rand(size(pBestI,1),size(pBestI,2),size(pBestI,3),P.psoIter);
u2 = rand(size(pBestI,1),size(pBestI,2),size(pBestI,3),P.psoIter);
% figure;
for nPso = 1:P.psoIter
    
    [Routs , routsIdx] = RoutingProtocol(muPosition,gcsPosition,Position,P);
    
    for np = 1:P.np
        [costFunNew(np) , longestLink(np) , shortestDist(np)] = costFunCalc(Routs(np,:),P);
        if costFunNew(np) <= costFunBest(np)
            pBestI(:,:,np) = Position(:,:,np);
            RoutsBest(np,:) = Routs(np,:);
            RoutsBestIdx(np,:) = routsIdx(np,:);

        end
        [costFunBest(np) , longestLink(np) , shortestDist(np)] = costFunCalc(RoutsBest(np,:),P);
    end
    
    velocityNew = P.w * velocity + P.c1 * u1(:,:,:,nPso).*(pBestI - Position) +...
        P.c2 * u2(:,:,:,nPso) .* (gBest - Position);
    velocityNew = max(velocityNew,-P.vMax);
    velocityNew = min(velocityNew,P.vMax);
    Position = Position + velocityNew;
    
    [costFunFinal,idxG] = min(costFunBest);
    gBest = pBestI(:,:,idxG);
    BestRout = RoutsBest(idxG,:);
    BestRoutIdx = RoutsBestIdx(idxG,:);

    longestLink2 = max(longestLink);
    shortestDist2 = min(shortestDist);
    %{
    scatter(muPosition(1,:) , muPosition(2,:)  ,'pentagram');
    hold on
    scatter(gcsPosition(1), gcsPosition(2) ,'g');
    hold on
    scatter(gBest(1,:),gBest(2,:),'k');
    title([num2str(nPso)  ', costFun = ' num2str(costFunFinal)])
    hold off
    for mf = 1: size(muPosition,2)
        hold all;
        plot(BestRout{mf}(1,:),BestRout{mf}(2,:))
        hold off
    end
    
    xlim([0 1500])
    ylim([0 1500])
    pause(0.01)
    %}
%     nPso
end
