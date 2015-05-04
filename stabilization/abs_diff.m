function d = abs_diff(block, template)
    d = sum(sum(abs(block-template)));
end