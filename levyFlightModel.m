global P

m = 3;
beta = 1.5;
levyD = levy(nStep,m*size(muPosition,2),beta); % generate the steps
levyD = reshape(levyD,nStep,3,size(muPosition,2));
levyD(levyD>30) = 30;
muPositionLevy = muPosition;
for i = 1:length(levyD)-1 % use those steps
    muPositionLevy(1,:,i+1) = muPositionLevy(1,:,i) + 1 * squeeze(levyD(i,1,:)).';
    muPositionLevy(2,:,i+1) = muPositionLevy(2,:,i) + 1 * squeeze(levyD(i,2,:)).';
    muPositionLevy(3,:,i+1) = muPositionLevy(3,:,i) + 0.3 * squeeze(levyD(i,3,:)).';
    
    idxX1 = find(muPositionLevy(1,:,i+1) < 0 );
    idxX2 = find(muPositionLevy(1,:,i+1) > 1500 );
    muPositionLevy(1,idxX1,i+1) = 0;
    muPositionLevy(1,idxX2,i+1) = 1500;
    
    idxY1 = find(muPositionLevy(2,:,i+1) < 0 );
    idxY2 = find(muPositionLevy(2,:,i+1) > 1500 );
    muPositionLevy(2,idxY1,i+1) = 0;
    muPositionLevy(2,idxY2,i+1) = 1500;
    
    idxZ1 = find(muPositionLevy(3,:,i+1) < 50 );
    idxZ2 = find(muPositionLevy(3,:,i+1) > 150 );
    muPositionLevy(3,idxZ1,i+1) = 50;
    muPositionLevy(3,idxZ2,i+1) = 150;
end