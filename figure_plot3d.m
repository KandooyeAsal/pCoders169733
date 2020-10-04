function figure_plot3d(rUAV_Positions, best_routes, cost)
global P
figure;
% scatter(P.muPosition(1,:) , P.muPosition(2,:)  ,'pentagram');
scatter3(P.muPosition(1,:) , P.muPosition(2,:), P.muPosition(2,:), 'pentagram')
str_mUAV = num2str((2+P.rNum:1+P.rNum+size(P.muPosition, 2)).');
text(P.muPosition(1,:) , P.muPosition(2,:),P.muPosition(3,:), str_mUAV, 'Color','blue','FontSize',14)
hold on
% scatter(P.gcsPosition(1), P.gcsPosition(2) ,'g');
scatter3(P.gcsPosition(1), P.gcsPosition(2), P.gcsPosition(3),'g');
text(P.gcsPosition(1) , P.gcsPosition(2), P.gcsPosition(3), num2str(1), 'Color','green','FontSize',14)
hold on
% scatter(rUAV_Positions(1,:),rUAV_Positions(2,:),'k');
scatter3(rUAV_Positions(1,:),rUAV_Positions(2,:),rUAV_Positions(3,:),'k');
str_rUAV = num2str((2:1+P.rNum).');
text(rUAV_Positions(1,:), rUAV_Positions(2,:), rUAV_Positions(3,:), str_rUAV, 'Color','black','FontSize',14);

for mf = 1: size(P.muPosition,2)
    hold all;
    plot(best_routes{mf}(1,:),best_routes{mf}(2,:))
    hold off
end
title(['Genetic Algorithm     -   ', 'costFcn = ', num2str(cost)])
xlim([0 1500])
ylim([0 1500])