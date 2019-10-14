function merged_samples = mergeChains(samples)

    merged_samples = struct;
    fields = fieldnames(samples);    
    
    for i=1:numel(fields)
        fieldsize = size(samples.(fields{i}));
        f = length(fieldsize);
        if f > 2
            merged_samples.(fields{i}) = reshape(samples.(fields{i}), [fieldsize(1)*fieldsize(2), fieldsize(3:f)]);
        else
            merged_samples.(fields{i}) = reshape(samples.(fields{i}), [fieldsize(1)*fieldsize(2), 1]);
        end
    end

end