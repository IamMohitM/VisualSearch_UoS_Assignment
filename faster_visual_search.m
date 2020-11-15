function [precision, recall, average_precision] = faster_visual_search(ALLFEAT, ALLFILES, allfiles, DESCRIPTOR_SUBFOLDER, distanceMetric, nResults, queryClass, displayResults)
%%same like cvpr_visualsearch but ALLFEAT (FEATURES), ALLFILES, allfiles
%%matrix is passed. Used in calculate_test_results.m

DESCRIPTOR_FOLDER = 'descriptors';
displayResults=false;
NIMG=size(ALLFEAT,1); % number of images in collection
if nargin<7
    queryimg=floor(rand()*NIMG);    % index of a random image
else
    load('classFileIndices.mat', 'classFileIndices');
    queryClassIndices = classFileIndices(num2str(queryClass));
    t=ceil(rand()*length(queryClassIndices));
    queryimg = queryClassIndices(t);
end
query_file_path = ALLFILES{queryimg};
[~, query_file, ~] = fileparts(query_file_path);
%% 3) Compute the distance of image to the query
dst=[];

if strcmp(distanceMetric, 'Mahalanobis')
    load(DESCRIPTOR_FOLDER +"/" +DESCRIPTOR_SUBFOLDER+"/projection_matrix.mat", 'projectionMatrix');
else
    projectionMatrix = [];
end

query=ALLFEAT(queryimg,:);

for i=1:NIMG
    candidate=ALLFEAT(i,:);
    distance=cvpr_compare(query,candidate, distanceMetric, projectionMatrix);
    dst=[dst ; [distance i]];
%     dst
end

if strcmp(distanceMetric, "cosine")
    dst = sortrows(dst, 1, "descend");
else
    dst=sortrows(dst,1);
end

%% 4) Visualise the results
%% These may be a little hard to see using imgshow
%% If you have access, try using imshow(outdisplay) or imagesc(outdisplay)


dst=dst(1:nResults,:);
outdisplay=[];
prediction_files = {};

for i=1:size(dst,1)
   img=imread(ALLFILES{dst(i,2)});
   [~, name, ~] = fileparts(ALLFILES{dst(i, 2)});
   prediction_files = [prediction_files ; name];
   
   if (displayResults)
       img=img(1:2:end,1:2:end,:); % make image a quarter size
       img=img(1:81,:,:); % crop image to uniform size vertically (some MSVC images are different heights)
       outdisplay=[outdisplay img];
   end
   
end

[precision, recall, average_precision] = evaluate_results(query_file, prediction_files);
if (displayResults)
    figure;
    imshow(outdisplay);
    axis off;
    figure;
    plot(recall, precision);
    xlabel("Recall");
    ylabel("Precision");
    axis on;
end

end
