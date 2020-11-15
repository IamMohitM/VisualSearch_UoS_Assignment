function [precision, recall, average_precision] = cvpr_visualsearch(DESCRIPTOR_SUBFOLDER, distanceMetric, nResults, queryClass, displayResults)

%% This function will perform the visual search for a random image or an image from
%% a particular class if queryClass is mentioned and return precision, recall and
%% and average_precision metrics
%% this function loads descriptors pre-computed in the DESCRIPTOR_SUBFOLDER
%% from the images in the MSRCv2 dataset.
%% DESCRIPTOR_SUBFOLDER must be inside "descriptors" directory at the top-level project directory
%% Choose one of the followinh distanc metrics: "cosine", "Euclidean", "Manhattan",
%% "Mahalanobis" (default Euclidean)
%% Choose "Mahalanobis" only if the DESCRIPTOR_SUBFOLDER has a projectionMatrix.mat file
%% twhich contains Eigen Vectors(.vct) and Eigen Values(.val)
%% nResults returns the top n results for the query (default 15)
%% set displayResults as false to not show any results

close all;

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';
DESCRIPTOR_FOLDER = 'descriptors';
%% Folder that holds the results...
if nargin<1    
    DESCRIPTOR_SUBFOLDER='gridTextureDescriptors_20_20';
    nResults = 15;
    displayResults=true;
    distanceMetric = "Euclidean";
elseif nargin < 2
    distanceMetric = "Euclidean";
    nResults = 15;
    displayResults=true;
elseif nargin < 3
    nResults=15;
    displayResults=true;
elseif nargin < 5
     displayResults = true;
end
%% and within that folder, another folder to hold the descriptors
%% we are interested in working with
% DESCRIPTOR_SUBFOLDER='gridTextureDescriptors_20_20';

%% 1) Load all the descriptors into "ALLFEAT"
%% each row of ALLFEAT is a descriptor (is an image)

ALLFEAT=[];
ALLFILES=cell(1,0);
ctr=1;
allfiles=dir(fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full))./255;
    featfile=DESCRIPTOR_FOLDER+"/"+DESCRIPTOR_SUBFOLDER+"/"+fname(1:end-4)+".mat";%replace .bmp with .mat
    load(featfile,'F');
    ALLFILES{ctr}=imgfname_full;
    ALLFEAT=[ALLFEAT ; F];
    ctr=ctr+1;
end

%% 2) Pick an image at random to be the query or choose an image from queryClass if passed
NIMG=size(ALLFEAT,1); % number of images in collection
if nargin<4
    queryimg=floor(rand()*NIMG);    % index of a random image
else
    load('classFileIndices.mat', 'classFileIndices');
    queryClassIndices = classFileIndices(num2str(queryClass));
    t=ceil(rand()*length(queryClassIndices));
    queryimg = queryClassIndices(t);
end
query_file_path = ALLFILES{queryimg};
% query_file_path = 'MSRC_ObjCategImageDatabase_v2/Images/19_22_s.bmp';
[~, query_file, ~] = fileparts(query_file_path);
query_file_path

%% 3) Compute the distance of image to the query
dst=[];
if strcmp(distanceMetric, 'Mahalanobis')
    load(DESCRIPTOR_FOLDER +"/" +DESCRIPTOR_SUBFOLDER+"/projection_matrix.mat", 'projectionMatrix');
else
    projectionMatrix = [];
end

query=ALLFEAT(queryimg,:);
% load("descriptors/"+DESCRIPTOR_SUBFOLDER+"/19_22_s.mat", 'F');
% query = F;

for i=1:NIMG
    candidate=ALLFEAT(i,:);
    distance=cvpr_compare(query,candidate, distanceMetric, projectionMatrix);
    dst=[dst ; [distance i]];
end

%because higher values in cosine similarity means high similarity
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
%        img=img(1:2:end,1:2:end,:); % make image a quarter size
       img = imresize(img, [200, 300]);
       outdisplay=[outdisplay img zeros(size(img, 1), 10, 3)];
   end
   
end
prediction_files
[precision, recall, average_precision] = evaluate_results(query_file, prediction_files);
precision
recall
if (displayResults)
    figure;
    imshow(outdisplay);
    axis off;
    figure;
    plot(recall, precision);
    title("Precision-Recall Curve");
    xlabel("Recall");
    ylabel("Precision");
    axis on;
end

end
