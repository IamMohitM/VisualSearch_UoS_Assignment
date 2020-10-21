function colorHistogram = globalColorHistogram(img, quantize)

    red_dash = floor((img(:, :, 1) .* quantize)./256);
    green_dash = floor((img(:, :, 2) .* quantize)./256);
    blue_dash = floor((img(:, :, 3) .* quantize)./256);

    red_dash = reshape(red_dash, [], 1);
    green_dash = reshape(green_dash, [], 1);
    blue_dash = reshape(blue_dash, [], 1);

    bins = (red_dash.*(quantize^2)) + (green_dash.*(quantize)) + (blue_dash);

    colorHistogram = histcounts(bins, quantize^3);

return;