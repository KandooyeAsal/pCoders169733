function [routs , routIdx] = RoutingProtocol(muLoc,gcsLoc,ruLocs)
global P
ruLocs3 = reshape(ruLocs(1:2,:,:),2,[]);
ruGcs = ruLocs3 - gcsLoc(1:2);
muGcs = muLoc(1:2,:) - gcsLoc(1:2);
thetasRu = 180 +  atan2d(ruGcs(2,:),ruGcs(1,:));
rRu = sqrt(sum(ruGcs.^2)) * 3;

thetasMu = 180 +  atan2d(muGcs(2,:),muGcs(1,:));
rMu = sqrt(sum(muGcs.^2)) * 3;

Phi = 60;
pR2 = [rRu .* cosd(thetasRu - Phi) ; rRu .* sind(thetasRu - Phi)] + ruLocs3;
pR3 = [rRu .* cosd(thetasRu + Phi) ; rRu .* sind(thetasRu + Phi)] + ruLocs3;

pM1 = muLoc(1:2,:);
pM2 = [rMu .* cosd(thetasMu - Phi) ; rMu .* sind(thetasMu - Phi)] + muLoc(1:2,:);
pM3 = [rMu .* cosd(thetasMu + Phi) ; rMu .* sind(thetasMu + Phi)] + muLoc(1:2,:);

pM12 = pM1 - pM2;
pM23 = pM2 - pM3;
pM31 = pM3 - pM1;

sign1 = sign(determin(pM31,pM23));
sign2 = sign(determin(pM12,pM31));
sign3 = sign(determin(pM23,pM12));

for i = 1:size(muLoc,2)
    sign11(i,:) = sign(determin(pM3(:,i) - ruLocs3, repmat(pM23(:,i),1,size(ruLocs3,2))));
    sign22(i,:) = sign(determin(pM1(:,i) - ruLocs3, repmat(pM31(:,i),1,size(ruLocs3,2))));
    sign33(i,:) = sign(determin(pM2(:,i) - ruLocs3, repmat(pM12(:,i),1,size(ruLocs3,2))));
end

TT = sign1' .* sign11 >=0 & sign2' .* sign22 >= 0 & sign3' .* sign33 >= 0;
TT2 = reshape(TT,size(muLoc,2),size(ruLocs,2),size(ruLocs,3));

%%
pR1 = ruLocs(1:2,:,:);
pR2 = reshape(pR2,2,size(ruLocs,2),[]);
pR3 = reshape(pR3,2,size(ruLocs,2),[]);


for ii = 1:size(ruLocs,3)
    fanetLoc = [muLoc ruLocs(:,:,ii) gcsLoc];
    fanetNum = size(fanetLoc,2);
    fanetLocRep = repmat(fanetLoc,fanetNum,1);
    
    fanetLoc1 = zeros(3*fanetNum,1);
    for l = 1:fanetNum
        fanetLoc1((l-1)*3+1:l*3,1) =  fanetLocRep((l-1)*3+1:l*3,l) ;
    end
    
    diff = reshape(fanetLocRep - fanetLoc1,3,[]);
    distances1 = sqrt(sum(diff.^2));
    distances = reshape(distances1,fanetNum,[])';
    distMu1 = distances(1:size(muLoc,2),size(muLoc,2)+1:end);
    distMu = inf*ones(size(distMu1));
    TT3 = TT2(:,:,ii);
    TT3 = logical([TT3 ones(size(TT3,1),1)]);
    distMu(TT3) = distMu1(TT3);
    [distFirst,neighbor] = min(distMu,[],2);
    for i = 1:size(muLoc,2)
        if neighbor(i) == size(ruLocs,2)+1
            routIdx{i,ii} = [i size(fanetLoc,2)];
            routs{i,ii} = [muLoc(:,i) gcsLoc];
            continue
        end
        nbr = [];
        nbr1 = neighbor(i);
        for rr = 1:size(ruLocs,2)
            nbr = [nbr nbr1];
            
            pR12 = pR1(:,nbr1,ii) - pR2(:,nbr1,ii);
            pR23 = pR2(:,nbr1,ii) - pR3(:,nbr1,ii);
            pR31 = pR3(:,nbr1,ii) - pR1(:,nbr1,ii);
            signR1 = sign(determin(pR31,pR23));
            signR2 = sign(determin(pR12,pR31));
            signR3 = sign(determin(pR23,pR12));
            signR11 = sign(determin(pR3(:,nbr1,ii) - [pR1(:,:,ii) gcsLoc(1:2)], repmat(pR23,1,size(ruLocs,2)+1)));
            signR22 = sign(determin(pR1(:,nbr1,ii) - [pR1(:,:,ii) gcsLoc(1:2)], repmat(pR31,1,size(ruLocs,2)+1)));
            signR33 = sign(determin(pR2(:,nbr1,ii) - [pR1(:,:,ii) gcsLoc(1:2)], repmat(pR12,1,size(ruLocs,2)+1)));
            
            TTR = signR1 .* signR11 >=0 & signR2 .* signR22 >= 0 & signR3 .* signR33 >= 0;
            TTR(nbr) = 0;
            distRu = distances(size(muLoc,2)+1:end-1,size(muLoc,2)+1:end);
            distRu1 = inf * ones(size(distRu));
            
            distRu1(nbr1,TTR) = distRu(nbr1,TTR);
            [~,nbr1] = min(distRu1(nbr1,:));
            
            if nbr1 == size(distRu1,2)
                nbr = [nbr nbr1];
                break
            end
        end
        routIdx{i,ii} = [i nbr+size(muLoc,2)];
        routs{i,ii} = fanetLoc(:,routIdx{i,ii});
    end
end
%%

routs = routs.';
routIdx = routIdx.';
end