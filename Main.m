clc
clear all
close all

InitialParams;

P.rNum = 10;

nStep = 1000;
levyFlightModel

% [best_position, best_routes, BestRoutIdx] = PSOAlgorithm_func(P.muPosition,P.gcsPosition, P.rNum);
[best_position, best_routes, BestRoutIdx] = ga_func();

% [best_position_ga, best_routes_ga] = geneticAlgorithm(muPosition,gcsPosition, rNum);

BestRout = best_routes;
ruPosition = best_position;
alpha2 = 2;
counterPSO = 1;
flag_remove_mUAV = true;
%%
modes = {'IFTM' , 'IFTM-RT' , 'IFTM-T' , 'PSO-Only'};
% figure
for modd = 1:length(modes)
    
    switch modes{modd}
        case 'IFTM'
            E = [700 1000];
        case 'IFTM-RT'
            E = [inf inf];
        case 'IFTM-T'
            E = [700 inf];
        case 'PSO-Only'
            E = [-inf -inf];
    end
    
    cnt = 1;
    for loop = 1:nStep
        muPosition = muPositionLevy(:,:,loop);
        %% Algorithm3 in Paper
        gradiant = zeros(3,P.rNum);
        for rr = 1:P.rNum
            grad = zeros(3,1);
            for mm = 1:size(muPosition,2)
                rIdxes = BestRoutIdx{mm};
                rIdx = find(rIdxes == rr+size(muPosition,2));
                if ~isempty(rIdx)
                    Path = BestRout{mm};
                    diffPos = diff(Path(:,rIdx-1:rIdx+1),1,2) .* [1 -1];
                    distancePath = sqrt(sum(diffPos.^2));
                    grad(:,mm) = sum(alpha2 * distancePath.^(alpha2-2) .* diffPos , 2);
                end
            end
            gradiant(:,rr) = sum(grad,2);
        end
        gamma = 0.05;
        gammaR = 20;
        
        gradiant2 = gamma * gradiant;
        flag = sqrt(sum(gradiant2.^2)) <= gammaR;
        ruPosition2 = zeros(3,P.rNum);
        ruPosition2(:,flag) = ruPosition(:,flag) - gradiant2(:,flag);
        ruPosition2(:,~flag) = ruPosition(:,~flag) - gradiant(:,~flag) * gammaR ./sqrt(sum(gradiant(:,~flag).^2));
        ruPosition = ruPosition2;
%         ruPosition3(:,:,loop) = ruPosition;
        
        fanetPositions = [muPosition ruPosition gcsPosition];
        for mm1 = 1: size(muPosition,2)
            BestRout{mm1} = fanetPositions(:,BestRoutIdx{mm1});
        end
        [costFunFinal , longestLink2 , shortestDist2] = costFunCalc(BestRout);
        
        %%
        w = [30 30 0.5 1000 1000];
        psi1 = 0.1;
        psi2 = 0.3;
        
        setPairs = [];
        neighborDistance = [];
        distPairs = [];
        for m1 = 1:size(muPosition,2)
            fanetLoc = [muPosition(:,m1) ruPosition gcsPosition];
            fanetNum = size(fanetLoc,2);
            fanetLocRep = repmat(fanetLoc,fanetNum,1);
            fanetLoc1 = zeros(3*fanetNum,1);
            for l = 1:fanetNum
                fanetLoc1((l-1)*3+1:l*3,1) =  fanetLocRep((l-1)*3+1:l*3,l) ;
            end
            diff2 = reshape(fanetLocRep - fanetLoc1,3,[]);
            distances = sqrt(sum(diff2.^2));
            distances = reshape(distances,fanetNum,[])';
            dd1 = distances;
            dd1(:,:,loop) = dd1  + 1e4 * eye(size(dd1));
            [nodeA,nodeB] = find(dd1(:,:,loop) <= P.dCm);
            setPairs = [setPairs ; nodeA nodeB];
            for nm = 1:length(nodeA)
                dist(nm) = distances(nodeA(nm),nodeB(nm));
            end
            distPairs = [distPairs dist];
            RIdxMod = [1 BestRoutIdx{m1}(2:end) - size(muPosition,2)+1];
            neighborDistance = [neighborDistance sqrt(sum(diff(fanetLoc(:,RIdxMod),1,2).^2))];
        end
        PairsLength{loop} = setPairs;
        distPairsLoop{loop} = distPairs;
        
        if cnt > 1
            [deletion , idx1] = setdiff(PairsLength{loop},PairsLength{loop-1},'rows');
            [insertion , idx2] = setdiff(PairsLength{loop-1},PairsLength{loop},'rows');
            e(1) = size(deletion,1);
            e(2) = size(insertion,1);
            [common1,idx31] = intersect(PairsLength{loop},PairsLength{loop-1},'rows');
            [common2,idx32] = intersect(PairsLength{loop-1},PairsLength{loop},'rows');
            e(3) = sum(abs(distPairsLoop{loop}(idx31) -  distPairsLoop{loop-1}(idx32)));
            e(4) = exp(psi1 * (max(neighborDistance) - P.dCm));
            e(5) = exp(psi2 * (P.dSf - min(min(dd1(:,:,loop)))));
            
            deltaTed = sum(e .* w);
            if deltaTed > E(1)
                
                [BestRout , BestRoutIdx] = RoutingProtocol(muPosition,gcsPosition,ruPosition);
                neighborDist = [];
                for mm = 1:size(muPosition,2)
                    fanetLocNew = [muPosition(:,1) ruPosition(:,BestRoutIdx{mm}(2:end-1)-size(muPosition,2)) gcsPosition];
                    neighborDist = [neighborDist sqrt(sum(diff(fanetLocNew,1,2).^2))];
                end
                e(4) = exp(psi1 * (max(neighborDist) - P.dCm));
                deltaTed = sum(e .* w);
                cnt = cnt + 1;
                [costFunFinal , longestLink2 , shortestDist2] = costFunCalc(BestRout);
                if deltaTed > E(2) && flag_remove_mUAV
%                     PSOAlgorithm;
                    [best_position, BestRout, BestRoutIdx] = ga_func();
%                     ruPosition = gBest
                    ruPosition = best_position;
                    counterPSO = counterPSO + 1;
                    if modd == 4
                        cnt = cnt + 1;
                    else
                        cnt = 1;
                    end
                end
            end
        else
            
            costFunBestL(loop) = costFunFinal;
            longestLinkL(loop) = longestLink2;
            shortestDistL(loop) = shortestDist2;
            
            cnt = cnt+1;
            continue
        end
        
        %
        scatter(muPosition(1,:), muPosition(2,:), muPosition(3,:),'pentagram');
        str_mUAV = num2str((2+P.rNum:1+P.rNum+size(muPosition, 2)).');
        text(muPosition(1,:) , muPosition(2,:), str_mUAV, 'Color','blue','FontSize',14)
        hold on; scatter(ruPosition(1,:), ruPosition(2,:),'hexagram'); hold off
        str_rUAV = num2str((2:1+P.rNum).');
        text(ruPosition(1,:),ruPosition(2,:), str_rUAV, 'Color','black','FontSize',14);
        hold on; scatter(gcsPosition(1), gcsPosition(2),'o');
        text(gcsPosition(1) , gcsPosition(2), num2str(1), 'Color','green','FontSize',14)
        hold off
        for m2 = 1:size(muPosition,2)
            hold all
            plot(BestRout{m2}(1,:),BestRout{m2}(2,:))
            hold off
        end
        xlim([0 1500])
        ylim([0 1500])
        title(loop)
        grid on
        pause(0.001)
        %}
        costFunBestL(modd,loop) = costFunFinal;
        longestLinkL(modd,loop) = longestLink2;
        shortestDistL(modd,loop) = shortestDist2;
        loopState = [modd loop]
        
        flag_remove_mUAV = true;
        if loop == 50
            ind_mUAV = randi(4, 1);
            distances = squareform(pdist([muPosition(:, ind_mUAV), ruPosition].'));
            distances = distances(1, :);
            distances = distances(2:end);
            [~, ind_rUAV] = min(distances);
            
            muPosition(:, ind_mUAV) = ruPosition(:, ind_rUAV);
            ruPosition(:, ind_rUAV) = [];
            P.rNum = P.rNum - 1;
            [~ , BestRoutIdx] = RoutingProtocol(muPosition,gcsPosition,ruPosition);
            flag_remove_mUAV = false;
            levyFlightModel;
            muPositionLevy = cat(3, zeros(3, 4, loop),muPositionLevy);
            
        end
        
    end
    
end

%%
figure;
subplot(311) ;
plot(costFunBestL(:,2:end)'); ylabel('Performance Metric','Interpreter' , 'latex');
grid on ; legend(modes,'Interpreter' , 'latex')
title('Comparision of IFTM, IFTM-RT, IFTM-T & PSO-Only')
subplot(312) ; plot(longestLinkL(:,2:end)'); ylabel('Longest Link Distance(m)','Interpreter' , 'latex');
grid on; legend(modes,'Interpreter' , 'latex');
subplot(313) ; plot(shortestDistL(:,2:end)'); xlabel('Time Step','Interpreter' , 'latex');
ylabel('Shortest Distance (m)','Interpreter' , 'latex'); grid on; legend(modes,'Interpreter' , 'latex')

figure;
subplot(311);
Mean1 = movmean(costFunBestL(:,2:end)',10);
plot(Mean1); ylabel('Performance Metric','Interpreter' , 'latex');
grid on ; legend(modes,'Interpreter' , 'latex')
title('Cumulative moving average of Comparision')
subplot(312)
plot(movmean(longestLinkL(:,2:end)',10)); ylabel('Longest Link Distance(m)','Interpreter' , 'latex');
grid on; legend(modes,'Interpreter' , 'latex');
subplot(313) ; plot(movmean(shortestDistL(:,2:end)',10)); xlabel('Time Step','Interpreter' , 'latex');
ylabel('Shortest Distance (m)','Interpreter' , 'latex'); grid on; legend(modes,'Interpreter' , 'latex')


figure;
[a1,b1] = hist(costFunBestL(1,2:end)./costFunBestL(4,2:end),20);
subplot(211); bar(b1,a1/nStep,1)
title('Performance metric value')
xlabel('Ratio of the Performance metric values','Interpreter' , 'latex'); ylabel('Occurrence Rate','Interpreter' , 'latex')
subplot(212); plot(costFunBestL(1,2:end)./costFunBestL(4,2:end))
grid on; ylabel('Ratio of the Performance metric values','Interpreter' , 'latex'); xlabel('Time Step','Interpreter' , 'latex')


figure;
[a2,b2] = hist(longestLinkL(1,2:end)./longestLinkL(4,2:end),20);
subplot(211); bar(b2,a2/nStep,1)
title('Longest Link Distance')
xlabel('Ratio of the Longest Link Distance','Interpreter' , 'latex'); ylabel('Occurrence Rate','Interpreter' , 'latex')
subplot(212); plot(longestLinkL(1,2:end)./longestLinkL(4,2:end))
grid on; ylabel('Ratio of the Longest Link Distance','Interpreter' , 'latex'); xlabel('Time Step','Interpreter' , 'latex')

figure;
[a3,b3] = hist(shortestDistL(1,2:end)./shortestDistL(4,2:end),20);
subplot(211); bar(b3,a3/nStep,1)
title('Shortest intra UAV distances')
xlabel('Ratio of the Shortest intra UAV distances','Interpreter' , 'latex'); ylabel('Occurrence Rate','Interpreter' , 'latex')
subplot(212); plot(shortestDistL(1,2:end)./shortestDistL(4,2:end))
grid on; ylabel('Ratio of the Shortest intra UAV distances','Interpreter' , 'latex'); xlabel('Time Step','Interpreter' , 'latex')
