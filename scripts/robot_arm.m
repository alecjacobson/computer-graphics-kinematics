dirpath = '/Users/ajx/Dropbox/computer-graphics/kinematics/shared/data/';
[V,WI,P] = readBF([dirpath 'robot-arm.bf']);
model_file = 'robot-arm.obj';
[VV,FF] = load_mesh([dirpath model_file]);

seen = false(size(V,1),1);
Q = 1:size(V,1);

% Twist Adjustments
A = [0;0;0;90;-90;90;0];
[T,D,U,l] = skeleton_transformations(V,WI,P,A);

BE = [find(WI>0) P(find(WI>0))];
C = connected_components(FF);

[~,D] = project_to_lines(VV,U(BE(:,1),:),U(BE(:,2),:),'Segments',true);
[~,WM] = min(D,[],2);
M = diag(massmatrix(VV,FF,'barycentric'));
[~,WM] = max(sparse(C,WM,M),[],2);
W = full(sparse(1:size(VV,1),WM(C),1,size(VV,1),max(WI)));
weights_file = 'robot-arm-weights.dmat';
writeDMAT([dirpath weights_file],W);

s = 0.02;
clf;
hold on;
for b = 1:size(V,1)
  VV = [s*eye(4,3) ones(4,1)]*(T(1:3,1:4,b)');
  plot_edges(VV,[1 4],'r','LineWidth',3);
  plot_edges(VV,[2 4],'g','LineWidth',3);
  plot_edges(VV,[3 4],'b','LineWidth',3);
end
hold off;
axis equal;

%keys = @(A) arrayfun(@(i) struct('t',A(i,1),'xzx',A(i,2:4)),1:size(A,1));
xzx_min = [
  0 0 0
  0 0 0
  -180 0 0
  0 -60 0
  0 -60 0
  0 -60 0
  0 0   -1e10];
xzx_max = [
  0 0 0
  0 0 0
  180 0 0
  0 60 0
  0 60 0
  0 60 0
  0 0   1e10];
fk_animation = ...
[
  struct('bone_id',2,'keys',keys([0 0 0 0;1 -90 0 0;5 -90 0 0;6 0 0 0]))
  struct('bone_id',3,'keys',keys([0 0 0 0;1 0 60 0;3 0 0 0;5 0 -60 0;6 0 0 0]))
  struct('bone_id',4,'keys',keys([0 0 0 0;2 0 -30 0;3 0 -20 0;4 0 -30 0;6 0 0 0]))
  struct('bone_id',5,'keys',keys([0 0 0 0; 1 0  -20 0; 1.5 0 20 0; 2 0  -20 0; 2.5 0 20 0; 3 0  -20 0; 3.5 0 20 0; 4 0 -20 0; 4.5 0 20 0; 5 0  -20 0; 5.5 0 20 0; 6.0 0 0 0]))
  struct('bone_id',6,'keys',keys([0 0 0 0;0.5 0 0 -360;1 0 0 0;5 0 0 0;5.5 0 0 -360;6 0 0 0]))
];

json = jsonencode( ...
  struct( ...
    'model',struct('file',model_file), ...
    'weights',struct('file',weights_file), ...
    'fk_animation',fk_animation, ...
    'bones', arrayfun(@(b) struct( ...
      'parent_id',P(b)-1, ...
      'weight_id',WI(b)-1, ...
      'length',l(b), ...
      'xzx_min',xzx_min(b,:), ...
      'xzx_max',xzx_max(b,:), ...
      'rest_T',T(:,:,b)),1:size(P,1))));

fid = fopen('../shared/data/robot-arm-rig.json','w');
fprintf(fid,'%s',json);
fclose(fid);

%json = jsonencode( ...
%  struct( ...
%    'model',struct('file',model_file), ...
%    'weights',struct('file',weights_file), ...
%    'ik_animation',ik_animation, ...
%    'bones', arrayfun(@(b) struct( ...
%      'parent_id',P(b)-1, ...
%      'weight_id',WI(b)-1, ...
%      'rest_T',T(:,:,b)),1:size(P,1))));
%fid = fopen('../shared/data/robot-arm-rig-ik.json','w');
%fprintf(fid,'%s',json);
%fclose(fid);

%!../build/kinematics ../shared/data/robot-arm-rig-ik.json
