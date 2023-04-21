function field_list = get_fieldnames(structure)
% Recursively get all the fieldnames of a nested struct
field_list = {};
if isstruct(structure)
    fields = fieldnames(structure);
    for i = 1:numel(fields)
        subfields = get_fieldnames(structure.(fields{i}));
        subfields = cellfun(@(x) [fields{i} '.' x], subfields, 'UniformOutput', false);
        field_list = [field_list subfields];
    end
else
    field_list = {''};
end
end