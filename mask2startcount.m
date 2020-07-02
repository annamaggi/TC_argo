function [start,count] = mask2startcount(mask)
    start = find(mask,1);
    count = find(~mask(start:end),1)-1;
    if isempty(count)
        count = Inf;
    end
end