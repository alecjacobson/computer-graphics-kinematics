function [BVV,BFF,BCC] = rest_skeleton_mesh(T,l,th)
  [BV,BF,BC] = canonical_bone();
  BVV = zeros([size(BV) size(T,3)]);
  BFF = zeros([size(BF) size(T,3)]);
  BCC = zeros([size(BC) size(T,3)]);
  for b = 1:size(T,3)
    BVV(:,:,b) = [BV*diag([l(b) th th]) ones(size(BV,1),1)]*(T(1:3,:,b)');
    BFF(:,:,b) = BF+size(BV,1)*(b-1);
    BCC(:,:,b) = BC;
  end
  BVV = reshape(permute(BVV,[1 3 2]),[],3);
  BFF = reshape(permute(BFF,[1 3 2]),[],3);
  BCC = reshape(permute(BCC,[1 3 2]),[],3);
end
