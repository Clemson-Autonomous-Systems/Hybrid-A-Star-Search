%%  Implementation of hybrid a star for demo purpose
clear all
clc
close all
dbstop if error
%%  Create the obstacles and start/goal location
obstacles = [1,2,-2,10;
            4,5,-7,6;
            -4,-2,-10,-2;
            7,8,2,8];% Format -> [min_x, max_x, min_y, max_y]

for i = 1:1:length(obstacles(:,1))
    min_x = obstacles(i,1);
    max_x = obstacles(i,2);
    min_y = obstacles(i,3);
    max_y = obstacles(i,4);
    obs_x = [min_x, max_x, max_x, min_x, min_x];
    obs_y = [min_y, min_y, max_y, max_y, min_y];
    plot(obs_x, obs_y, 'k-', 'Linewidth',5);hold on;
    clear min_x; 
    clear max_x; 
    clear min_y; 
    clear max_y;
end
xlim([-10,10]);ylim([-10,10]);hold on
% Setting the start and goal location of nvaigation
start_x = -7;
start_y = -6;
start_yaw = 0;
goal_x = 10;
goal_y = 2;
plot(start_x, start_y, '>b', 'MarkerSize', 15, 'MarkerFaceColor', 'b');hold on
plot(goal_x, goal_y, '>r', 'MarkerSize', 15, 'MarkerFaceColor', 'r');hold on
%%  create open_list and closed list
open = [];
open_f = [];
open_g = [];
open_c = [];
close = [];
%%  Create the steering angle and arc length for sampling
steering = linspace(-0.34,0.34,4);
arc_length = 1.2;
%%  Searching over the map
% Initialize the open list
 % Keep track of the total vertex visited
global id
id = 1;
mother_id = 0;
open = [start_x, start_y, start_yaw, 0, mother_id, id];
open_f = [open_f, pdist([open(1:2);[goal_x, goal_y]])]; % eucliden heuristic function
open_c = open_f + open(end);
while length(open_c) ~= 0
    % Pop the minimum cost value
    [~,source_ind] = min(open_c);
    source = open(source_ind,:);
    close = [close; source];
    if pdist([source(1:2);[goal_x, goal_y]]) < 0.5
        break
    end
    open(source_ind,:) = [];
    open_f(source_ind) = [];
    open_c(source_ind) = [];
    sample = ackermann_sampler(source, steering, arc_length, @collision_check, obstacles, id);
    if length(sample) > 0
        f = sample(:,1:2) - [goal_x, goal_y];
        f = (f(:,1).^2 + f(:,2).^2).^0.5;
        open = [open; sample];
        open_f = [open_f, f.'];
        open_c = open_f + 0.2*open(:,4).';
    end
end
%%  Search thorough the closed list to find the path.
% Start from the last point 
search_id =  close(end, 5);
while search_id ~= 0
    point_id = find(close(:,6)== search_id);
    plot(close(point_id,1), close(point_id,2),'rh','MarkerSize',10,'MarkerFaceColor','r');hold on
    search_id = close(point_id,5);
end