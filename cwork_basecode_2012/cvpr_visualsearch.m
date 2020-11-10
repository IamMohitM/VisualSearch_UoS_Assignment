%% EEE3032 - Computer Vision and Pattern Recognition (ee3.cvpr)
%%
%% cvpr_visualsearch.m
%% Skeleton code provided as part of the coursework assessment
%%
%% This code will load in all descriptors pre-computed (by the
%% function cvpr_computedescriptors) from the images in the MSRCv2 dataset.
%%
%% It will pick a descriptor at random and compare all other descriptors to
%% it - by calling cvpr_compare.  In doing so it will rank the images by
%% similarity to the randomly picked descriptor.  Note that initially the
%% function cvpr_compare returns a random number - you need to code it
%% so that it returns the Euclidean distance or some other distance metric
%% between the two descriptors it is passed.
%%
%% (c) John Collomosse 2010  (J.Collomosse@surrey.ac.uk)
%% Centre for Vision Speech and Signal Processing (CVSSP)
%% University of Surrey, United Kingdom
function [precision, recall, average_precision] = cvpr_visualsearch(DESCRIPTOR_SUBFOLDER, distanceMetric, nResults, queryClass, displayResults)

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
    queryClassFiles = {};
    index = {};
    classFilesIndex = 0;
    for i=1:length(allfiles)
        if(startsWith(allfiles(i).name,strcat(num2str(queryClass),'_')))
            classFilesIndex = classFilesIndex + 1;
            queryClassFiles{classFilesIndex} = allfiles(i).name;
            index{classFilesIndex} = i;
        end
    end
    t=ceil(rand()*classFilesIndex);
    queryimg = index{t};
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
    dst=[dst ; [distance i]]
%     dst
end

dst=sortrows(dst,1);  % sort the results

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
