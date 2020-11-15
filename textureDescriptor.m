function gridTextureDescriptor = textureDescriptor(image, gridSize, edge_bins)
%% computes texture Descriptor of the given image. 
%% The image is resized to width 300 and height 200
%% Gridsize defines size of grid and must be divisible by both 300 and 200 (because square grid)
%% edge_bins defines the quantization value of edge orientations


width = 300;
height = 200;

hcf = gcd(height, width);
if (rem(hcf, gridSize))
    error("The grid size should be a factor of hcf of the resized image( 200 height, 300 width) %d - so values like 2, 5, 10, 20..", hcf);
end
resizedImage = imresize(image, [200, 300])./255;
resizedImage = imgaussfilt(resizedImage);
grayImage = rgb2gray(resizedImage);
edgeImage = edge(grayImage, 'canny');

totalColumnGrids = fix(width/gridSize);
totalRowGrids = fix(height/gridSize);

bin_edges = linspace(-180, 180, edge_bins+1);
featuresPerGrid = edge_bins + 3;
gridTextureDescriptor = zeros(1, totalColumnGrids*totalRowGrids * featuresPerGrid);
lastIndex = 0;

for rowIndex=0:(totalRowGrids-1)
    for columnIndex=0:(totalColumnGrids-1)
        gridImage = resizedImage((rowIndex*gridSize)+1: (rowIndex*gridSize)+gridSize, (columnIndex*gridSize)+1: (columnIndex*gridSize)+gridSize, :);
        gridEdgeImage = edgeImage((rowIndex*gridSize)+1: (rowIndex*gridSize)+gridSize, (columnIndex*gridSize)+1: (columnIndex*gridSize)+gridSize, :);     
        redGrid = gridImage(:, :, 1);
        greenGrid = gridImage(:, :, 2);
        blueGrid = gridImage(:, :, 3);
        
        [~, directions] = imgradient(gridEdgeImage);
        [orientation_freqs, ~] = histcounts(directions, bin_edges);
        meanRed = mean(redGrid(:));
        meanGreen = mean(greenGrid(:));
        meanBlue = mean(blueGrid(:));
        
        grid_features = [orientation_freqs meanRed meanGreen meanBlue];
        gridTextureDescriptor(lastIndex+1: lastIndex+featuresPerGrid) = grid_features;
        
        lastIndex = lastIndex + featuresPerGrid;
        
    end
end

return