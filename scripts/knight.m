[V,WI,P] = readBF('/Users/ajx/Dropbox/computer-graphics/kinematics/shared/data/knight.bf');
model_file = 'knight.obj';
weights_file = 'knight-weights.dmat';
fk_animation = {{13,[0 0 0 0;1 0 90 0;2 0 0 0]}};


% Twist Adjustments
A = zeros(size(V,1),1);
A(2) = -30;
A(3) = 80;
A(4) = -30;
A(6) = 90;
A(8) = 90;
A(9) = 120-A(8);
A(13) = 110;
A(17) = 70;
xzx_min = zeros(size(V,1),3);
xzx_max = zeros(size(V,1),3);
xzx_min(3,:) = [-70 -30 -10];
xzx_max(3,:) = [ 70  100 10];
xzx_min(4,:) = [-5 -10 -45];
xzx_max(4,:) = [5  80 45];
% right arm
xzx_min(8,:) = [-70 -30 -10];
xzx_max(8,:) = [ 70  100 10];
xzx_min(9,:) = [-5 -10 -45];
xzx_max(9,:) = [5  80 45];
% spine
xzx_min(6,:) = [-40 -40 -40];
xzx_max(6,:) = [ 40  80 40];
xzx_min(10,:) = [-10 -10 -10];
xzx_max(10,:) = [10 10 10];
xzx_min(11,:) = [-10 -10 -10];
xzx_max(11,:) = [10 10 10];
% right leg
xzx_min(16,:) = [-10 -10 -10];
xzx_max(16,:) = [10 10 10];
xzx_min(17,:) = [-20 -50 -0];
xzx_max(17,:) = [10  70 0];
xzx_min(18,:) = [0 -70 0];
xzx_max(18,:) = [0  10 0];
xzx_min(19,:) = [-10 -30 -10];
xzx_max(19,:) = [10  30 10];
% left leg
xzx_min(12,:) = [-10 -10 -10];
xzx_max(12,:) = [ 10 10 10];
xzx_min(13,:) = [-10 -50 -0];
xzx_max(13,:) = [10  70 0];
xzx_min(14,:) = [0 -70 0];
xzx_max(14,:) = [0  10 0];
xzx_min(15,:) = [-10 -30 -10];
xzx_max(15,:) = [10  30 10];

[T,D,U,l] = skeleton_transformations(V,WI,P,A);

s = 0.02;
clf;
hold on;
for b = 1:size(V,1)
  VV = [s*eye(4,3) ones(4,1)]*(T(1:3,1:4,b)');
  plot_edges(VV,[1 4],'r','LineWidth',3);
  plot_edges(VV,[2 4],'g','LineWidth',3);
  plot_edges(VV,[3 4],'b','LineWidth',3);
  text(U(:,1),U(:,2),U(:,3),num2str((1:size(U,1))'));
end
hold off;
axis equal;

ik_constraints = [19 15 9 4 6];

json = jsonencode( ...
  struct( ...
    'model',struct('file',model_file), ...
    'weights',struct('file',weights_file), ...
    'fk_animation',[], ...
    'ik_constraints',ik_constraints-1, ...
    'bones', arrayfun(@(b) struct( ...
      'parent_id',P(b)-1, ...
      'weight_id',WI(b)-1, ...
      'length',l(b), ...
      'xzx_min',xzx_min(b,:), ...
      'xzx_max',xzx_max(b,:), ...
      'rest_T',T(:,:,b)),1:size(P,1))));
fid = fopen('../shared/data/knight-rig.json','w');
fprintf(fid,'%s',json);
fclose(fid);

!../build-release/kinematics ../shared/data/knight-rig.json
