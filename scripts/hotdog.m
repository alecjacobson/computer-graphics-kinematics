dirpath = '/Users/ajx/Dropbox/models/';
[V,WI,P] = readBF([dirpath 'hotdog.bf']);
model_file = 'hotdog.obj';
[VV,FF] = load_mesh([dirpath model_file]);
weights_file = 'hotdog-weights.dmat';

seen = false(size(V,1),1);
Q = 1:size(V,1);
A = zeros(size(V,1),1);
A(8) = [90+15];
A([2 5 10]) = 90;
A([3 6]) = -45;
A([4 7]) = 0;
xzx_min = zeros(size(V,1),3);
xzx_max = zeros(size(V,1),3);
% head
xzx_min(9,:) = [-10 -10 -10];
xzx_max(9,:) = [ 10  90  10];
% neck
xzx_min(8,:) = [-10 -10 -10];
xzx_max(8,:) = [ 10  10  10];
% spine
xzx_min(10,:) = [-10 -10 -10];
xzx_max(10,:) = [ 10  10  10];
% hands
xzx_min(4,:) = [-30 -80 -30];
xzx_max(4,:) = [ 30  80  30];
xzx_min(7,:) = [-30 -80 -30];
xzx_max(7,:) = [ 30  80  30];
% inner shoulder
xzx_min(2,:) = [-3 -3 -3];
xzx_max(2,:) = [ 3  3  3];
xzx_min(5,:) = [-3 -3 -3];
xzx_max(5,:) = [ 3  3  3];
% shoulder/hips
xzx_min(3,:) = [-40 -100 -40];
xzx_max(3,:) = [ 40 100  40];
xzx_min(6,:) = [-40 -100 -40];
xzx_max(6,:) = [ 40 100  40];
xzx_min(11,:) = [-5 -5 -5];
xzx_max(11,:) = [ 5  5 5];
xzx_min(15,:) = [-5 -5 -5];
xzx_max(15,:) = [ 5  5 5];
% leg
xzx_min(12,:) = [-10 -60 -10];
xzx_max(12,:) = [ 10  60  10];
xzx_min(16,:) = [-10 -60 -10];
xzx_max(16,:) = [ 10  60  10];
% knee
xzx_min(13,:) = [-5 -100 -5];
xzx_max(13,:) = [ 5   5  5];
xzx_min(17,:) = [-5 -100 -5];
xzx_max(17,:) = [ 5   5  5];
% feet
xzx_min(14,:) = [-5 -10 -5];
xzx_max(14,:) = [ 5  10  5];
xzx_min(18,:) = [-5 -10 -5];
xzx_max(18,:) = [ 5  10  5];


[T,D,U,l] = skeleton_transformations(V,WI,P,A);

s = norm(max(VV)-min(VV))/40;
clf;
hold on;
for b = 1:size(V,1)
  VV = [s*eye(4,3) ones(4,1)]*(T(1:3,1:4,b)');
  plot_edges(VV,[1 4],'r','LineWidth',1);
  plot_edges(VV,[2 4],'g','LineWidth',1);
  plot_edges(VV,[3 4],'b','LineWidth',1);
  text(U(:,1),U(:,2),U(:,3),num2str((1:size(U,1))'));
end
hold off;
axis equal;

ik_constraints = [4 7 9 14 18];

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
fid = fopen([dirpath 'hotdog-rig.json'],'w');
fprintf(fid,'%s',json);
fclose(fid);
!../build-release/kinematics ~/Dropbox/models/hotdog-rig.json
