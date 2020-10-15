function [best_position_GA, best_routes_GA, routsIdx] = ga_func_manual(f)

global P

% f = @(x) (x(:, 1) - 1).^2 + (x(:, 2) - 2).^2;

% P.lb = [-5, -5];
% P.ub = [5, 5];

P.lb = reshape(repmat([0; 0; 50], 1, P.rNum), [3*P.rNum, 1]).';
P.ub = reshape(repmat([1500; 1500; 150], 1, P.rNum), [3*P.rNum, 1]).';

P.NUM_chromosome = 300;
P.Percent_reproduction = 0.95;
P.NUM_reproduction = floor(P.Percent_reproduction * P.NUM_chromosome);
P.MAX_generation = 80;
P.Scale_mutation = 0.1*(P.ub - P.lb);
P.Shrink_mutation = 0.6;
P.Tournament_Size = 4;
P.Ratio = 0.8;

% initial population
chromosome = repmat((P.ub - P.lb), P.NUM_chromosome, 1) .*(rand(P.NUM_chromosome, 3*P.rNum)) + P.lb;

% finding fittness
% fittness = f(chromosome);
fittness = zeros(P.NUM_chromosome, 1);
for i = 1:P.NUM_chromosome
    fittness(i) = f(chromosome(i, :));
end


[sort_fittness, sort_Ind] = sort(fittness, 'ascend');
sort_chromosome = chromosome(sort_Ind, :);
new_chromosome = sort_chromosome;

sigma = repmat(P.Scale_mutation, P.NUM_reproduction, 1);

for k = 1:P.MAX_generation
    % creating next generation
    [sort_fittness, sort_Ind] = sort(fittness, 'ascend');
    best_fittness = sort_fittness(1);
    best_chromosome = new_chromosome(sort_Ind(1), :);
    sort_chromosome = new_chromosome(sort_Ind, :);
    
    % selection
    selection_rand = randi(P.NUM_chromosome, P.NUM_reproduction, P.Tournament_Size);
    selection_fittnes = sort_fittness(selection_rand);
    [selection_fittnes_sorted, selection_Ind_sorted] = sort(selection_fittnes, 2, 'ascend');
    
    selection_parent1_Ind = zeros(P.NUM_reproduction, 1);
    selection_parent2_Ind = zeros(P.NUM_reproduction, 1);
    for i = 1:P.NUM_reproduction
        selection_parent1_Ind(i) = selection_rand(i, selection_Ind_sorted(i, 1));
        selection_parent2_Ind(i) = selection_rand(i, selection_Ind_sorted(i, 2));
    end
    parent1 = sort_chromosome(selection_parent1_Ind, :);
    parent2 = sort_chromosome(selection_parent2_Ind, :);
    
    % cross over
    children = parent2 + P.Ratio * (parent1 - parent2);
    
    % mutation
    sigma = sigma *(1 - P.Shrink_mutation * k/P.MAX_generation);
    mutation_gaussian_rand = sigma .* randn(size(children));
    children = children + mutation_gaussian_rand;
    
    new_chromosome = sort_chromosome;
    new_chromosome(P.NUM_chromosome - P.NUM_reproduction + 1:end, :) = children;
    
    
    
    %     fittness = f(new_chromosome);
    fittness = zeros(P.NUM_chromosome, 1);
    for i = 1:P.NUM_chromosome
        fittness(i) = f(new_chromosome(i, :));
    end
    
    %     figure(1)
    %     plot(new_chromosome(:, 1), new_chromosome(:, 2), 'bo')
    %     xlim([-5, 5])
    %     ylim([-5, 5])
    %     grid on
    %     pause(0.2)
    %     title(num2str(k))
    
    %     figure(2);
    %     plot(k, best_fittness, 'k.')
    %     hold on
    %     plot(k, mean(fittness), 'b.')
    %     grid on
    %     xlim([0, P.MAX_generation])
    %     pause(0.2)
    %     title(num2str(k))
    %     pause(0.001)
    
%     position = reshape(best_chromosome, [3, P.rNum]);
%     [BestRout , routsIdx] = RoutingProtocol(P.muPosition,P.gcsPosition,position);
%     figure(3);
%     scatter(P.muPosition(1,:), P.muPosition(2,:), P.muPosition(3,:),'pentagram');
%     hold on; scatter(position(1,:), position(2,:),'hexagram'); hold off
%     hold on; scatter(P.gcsPosition(1), P.gcsPosition(2),'o');
%     hold off
%     for m2 = 1:size(P.muPosition,2)
%         hold all
%         plot(BestRout{m2}(1,:),BestRout{m2}(2,:))
%         hold off
%     end
%     xlim([0 1500])
%     ylim([0 1500])
%     title(['generation: ', num2str(k), ' - cost: ', num2str(best_fittness)])
%     grid on
%     pause(0.2)
    
    disp(['genetic algorithm developement: ', num2str(k/P.MAX_generation), '%'])
end

best_position_GA = reshape(best_chromosome, [3, P.rNum]);
[best_routes_GA , routsIdx] = RoutingProtocol(P.muPosition,P.gcsPosition,best_position_GA);
[costFun_GA,LongestLink,ShortestIntraDist] = costFunCalc(best_routes_GA);

end