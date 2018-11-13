
dirpath = '../shared/data/';
load([dirpath 'ikea-lamp-skeleton.mat'])
C(end,1:2) =[0.09 0.79];
V = C(BE(:,2),:)-C(BE(:,1),:);
V = [C(1,:);V];
P = [0;P+1];
WI = [5 1:4]';
%[V,WI,P] = readBF([dirpath 'ikea-lamp.bf']);
model_file = 'ikea-lamp-model.off';
[VV,FF] = load_mesh([dirpath model_file]);
weights_file = 'ikea-lamp-weights.dmat';
%W = readDMAT([dirpath weights_file]);
C = connected_components(FF);

M = diag(massmatrix(VV,FF,'barycentric'));
CV = full(sparse(repmat(C,1,3),repmat(1:3,size(VV,1),1),M.*VV)./sparse(C,1,M));
clf;
text(CV(:,1),CV(:,2),CV(:,3),num2str((1:size(CV,1))'))

WM = ones(max(C),1);
WM(1:14) = 4;
WM(8) = 3;
WM(15:22) = 2;
WM([23 24 ]) = 5;
W = full(sparse(1:size(VV,1),WM(C),1,size(VV,1),5));
writeDMAT([dirpath weights_file],W);


xzx_min = zeros(size(V,1),3);
xzx_max = zeros(size(V,1),3);
xzx_min(3,2) = -60;
xzx_max(3,2) =  120;
xzx_min(4,2) = -230;
xzx_max(4,2) =  80;
xzx_min(5,2) = -120;
xzx_max(5,2) =  75;
xzx_min(2,1) =  -90;
xzx_max(2,1) =   90;

A = zeros(size(V,1),1);

[T,D,U,l] = skeleton_transformations(V,WI,P,A);
[BVV,BFF,BCC] = rest_skeleton_mesh( ...
 T,l,norm(max(VV)-min(VV))*0.01);

clf;
hold on;
tsurf(FF,VV,'FaceColor','none');
tsurf(BFF,BVV,'FaceVertexCData',BCC);
hold off;
axis equal;
view(2);

ik_constraints = [5];

json_file = [dirpath 'ikea-lamp-rig.json'];
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
fid = fopen(json_file,'w');
fprintf(fid,'%s',json);
fclose(fid);

system(['../build-release/kinematics "' json_file '"']);
