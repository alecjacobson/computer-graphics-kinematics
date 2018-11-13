function k = keys(A)
 k = arrayfun(@(i) struct('t',A(i,1),'xzx',A(i,2:4)),1:size(A,1));
end
