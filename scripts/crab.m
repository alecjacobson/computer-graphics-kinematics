dirpath = '/Users/ajx/Dropbox/models/';
[V,WI,P] = readBF([dirpath 'Dark_Finger_Reef_Crab-50K.bf']);
model_file = 'Dark_Finger_Reef_Crab-50K.obj';
[VV,FF] = load_mesh([dirpath model_file]);
weights_file = 'Dark_Finger_Reef_Crab-50K-weights.dmat';

seen = false(size(V,1),1);
A = zeros(size(V,1),1);
xzx_min = -1e10*ones(size(V,1),3);
xzx_max = 1e10*ones(size(V,1),3);
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

ik_constraints = [2 23 24 25 26 27 28 29 30 31 32];

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
fid = fopen([dirpath 'Dark_Finger_Reef_Crab-50K-rig.json'],'w');
fprintf(fid,'%s',json);
fclose(fid);
