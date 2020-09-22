
spaceLim = [0 1500;0 1500; 50 150]; % x , y , z limitations
gcsPosition = [750 750 0]';
muPosition = [300 300 100; 300 1200 100; 1200 300 100; 1200 1200 100; 400 500 120]';
% muPosition = [ 300 300 100]';

P.lambda = 50;
P.mhu = P.lambda;
P.np = 100;
P.w = 0.729;
P.c1 = 1.4962;
P.c2 = P.c1;
P.vMax = 0.1 * diff(spaceLim,1,2);
P.psoIter = 100;
P.montIter = 1;
% P.ruNum = rNum;
P.dCm = 300;
P.dSf = 30;
P.alpha = 2;


%{
for n = 1:np
    figure;
    plot3(muLoc(1,:),muLoc(2,:),muLoc(3,:),'O','markerSize',5);
    str = {'mU#1','mU#2','mU#3','mU#4'};
    text(muLoc(1,:),muLoc(2,:),muLoc(3,:)+7,str)
    hold all; plot3(gcsLoc(1),gcsLoc(2),gcsLoc(3),'^','markerSize',5);
    strg = {'  GCS'};
    text(gcsLoc(1),gcsLoc(2),gcsLoc(3)+10,strg)
    [x,y] = meshgrid([1:1500],[1:1500].');
    z = -2*ones(1500,1500);
    hold on; plot3(x,y,z,'color',[179,225,172]/255)
    hold all; plot3(ruLocs1{n}(1,:),ruLocs1{n}(2,:),ruLocs1{n}(3,:),'>','LineWidth',1.5)
    strr = {'rU'};
    text(ruLocs1{n}(1,:),ruLocs1{n}(2,:),ruLocs1{n}(3,:)+7,strr)
%     pause
%     close all
end
%}




% ruLocs1 = ruLocs(:,randomIdx);
% ruLocs1 = reshape(ruLocs1,3,)


% % save ruLocs ruLocs
% load ruLocs
%{
for i = 1:np
    figure;
    plot3(muLoc(1,:),muLoc(2,:),muLoc(3,:),'O','markerSize',10);
    str = {'  1' , '  2' , '  3' , '  4'}
    text(muLoc(1,:),muLoc(2,:),muLoc(3,:),str)
    hold on; plot3(gcsLoc(1),gcsLoc(2),gcsLoc(3),'^','markerSize',10); hold off
    hold on; plot3(ruLocs(1,:,i),ruLocs(2,:,i),ruLocs(3,:,i),'*')
    %     pause
    hold off
    title(i)
    close all
end

Paths = cell(size(muLoc,2),np);
Paths(1,1) = [[1082,605,65];[685,510,93];[459,687,94] ];
Paths(2,1) = [[1082,605,65];[685,510,93];[459,687,94] ];
Paths(3,1) = [[1082,605,65]];
Paths(4,1) = [[1082,605,65];[1157,1049,65]];

Paths(1,2) = [[580,370,111] ];
Paths(2,2) = [[105,1395,84];[145,1358,102];[288,1436,75]];
Paths(3,2) = [[750,750,0];[1006,913,85];[1022,645,114];[1200,300,100]];
Paths(4,2) = [[1006,913,85];[1200,1200,100];[750,750,0]];

%}

%%
%{
s = [1 1 1 1 2 2 3 4 4 5 6];
t = [2 3 4 5 3 6 6 5 7 7 7];
G = graph(s,t);
plot(G)

s = [1 1 1 2 5 3 6 4 7 8 8 8];
t = [2 3 4 5 3 6 4 7 2 6 7 5];
weights = [100 10 10 10 10 20 10 30 50 10 70 10];
G = graph(s,t,weights);
plot(G,'EdgeLabel',G.Edges.Weight)
P = shortestpath(G,2,6)



%%

s = [1 1 1 1 1 2 2 2 3 3 3 3 3];
t = [2 4 5 6 7 3 8 9 10 11 12 13 14];
weights = randi([1 10],1,13);
G = graph(s,t,weights);
p = plot(G,'Layout','force','EdgeLabel',G.Edges.Weight);

nn = nearest(G,1,5)

highlight(p,1,'NodeColor','g')
highlight(p,nn,'NodeColor','r')

%%
s = {'a' 'a' 'a' 'b' 'c' 'c' 'e' 'f' 'f'};
t = {'b' 'c' 'd' 'a' 'a' 'd' 'f' 'a' 'b'};
weights = [1 1 1 2 2 2 2 2 2];
G = digraph(s,t,weights);
plot(G,'EdgeLabel',G.Edges.Weight)

%%
s = [1 1 2 3 3 4 4 6 6 7 8 7 5];
t = [2 3 4 4 5 5 6 1 8 1 3 2 8];
G = digraph(s,t);
plot(G)

P = shortestpath(G,7,8)

%%

s = [1 1 2 3 3 4 4 6 6 7 8 7 5];
t = [2 3 4 4 5 5 6 1 8 1 3 2 8];
G = digraph(s,t)

TR = shortestpathtree(G,1);
p = plot(G);
highlight(p,TR,'EdgeColor','r')

%}

