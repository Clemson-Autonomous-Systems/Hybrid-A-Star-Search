function goal = ackermann_sampler(direction,source, steering, arc_length, collision_check, obstacles, vertex, id)
% This function returns the sampler from ackermann steering
% The return format is [x, y, yaw, distance_travelled, mother_id, smaple_index, arc_length]
% 1. Setup the initial state of the sampler
global id
x = source(1);
y = source(2);
yaw = source(3);
m_distance = source(4);
%mother_id = source(5);
current_id = source(6);
data_x = zeros(length(steering), length(arc_length));
data_y = data_x;
car_length = 0.33;
goal = [];
arc = direction*linspace(0.01,arc_length,15);
open_vertex = vertex;
% 2. Search all the possible solution and
for i = 1:1:length(steering)
    collision = false;
    turning_radius = car_length/tan(steering(i));
    alpha_forward = arc(end)/turning_radius;
    %alpha_backward = arc(1)/turning_radius;
    for j = 1:1:length(arc)
        alpha = arc(j)/turning_radius;
        data_x(i,j) = turning_radius*sin(alpha);
        data_y(i,j) = turning_radius*(1-cos(alpha));
    end
    % Perform the coordinate transformation
    x_glob = x + data_x(i,:)*cos(yaw) - data_y(i,:)*sin(yaw);
    y_glob = y + data_x(i,:)*sin(yaw) + data_y(i,:)*cos(yaw);
    yaw_glob_f = yaw + alpha_forward;
    %yaw_glob_b = yaw + alpha_backward;
    % Perform the collision check
    for k = 1:1:length(x_glob)
        if collision_check(obstacles, [x_glob(k), y_glob(k)])
            collision = true;
            break
        end
    end
    if collision
        continue
    % Check if the vertex has been visited
    else
        if ~isempty(vertex)
            open_dist = abs(open_vertex - [x_glob(end), y_glob(end)]);
            open_dist_abs = open_dist(:,1) + open_dist(:,2);
            min_open_dist_abs = min(open_dist_abs);
        else
            min_open_dist_abs = Inf;
        end
        if min_open_dist_abs < 0.25
            continue
        else
            if direction == 1
                plot(x_glob, y_glob,'Linewidth',1.8,'Color', [0.31 0.81 0.5]);hold on
            else
                plot(x_glob, y_glob,'Linewidth',1.8,'Color', [0.31 0.81 0.5]);hold on
            end
            id = id + 1;
            goal = [goal;[x_glob(end), y_glob(end), yaw_glob_f, m_distance + arc_length, current_id, id, arc_length]];
            %id = id + 1;
            %goal = [goal;[x_glob(1), y_glob(1), yaw_glob_b, m_distance + arc_length,current_id,id]];
        end
    end
end
end
