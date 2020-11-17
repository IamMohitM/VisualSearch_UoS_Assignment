function visualsearch(image, descriptorType, parameters, DESCRIPTOR_SUBFOLDER,distanceMetric, nResults)

%% This function will perform the visual search for a random image or an image from
%% a particular class if queryClass is mentioned and return precision, recall and
%% and average_precision metrics
%% this function loads descriptors pre-computed in the DESCRIPTOR_SUBFOLDER
%% from the images in the MSRCv2 dataset.
%% DESCRIPTOR_SUBFOLDER must be inside "descriptors" directory at the top-level project directory
%% Choose one of the following distance metrics: "cosine", "Euclidean", "Manhattan",
%% "Mahalanobis" (default Euclidean)
%% Choose "Mahalanobis" only if the DESCRIPTOR_SUBFOLDER has a projectionMatrix.mat file
%% which contains Eigen Vectors(.vct) and Eigen Values(.val)
%% nResults returns the top n results for the query (default 15)
%% set displayResults as false to not show any results

%%This function performs visual search for a provided image. Make sure that
%%your descriptors are computed and saved in DESCRIPTOR_SUBFOLDER with the
%% same parameters you want to use. 
%% Possible descriptorType = "ColorHistDescriptor" and "textureDescriptor"
%% parametrs must be a 1-D row array
%% If descriptorType is ColorHistDescriptor then parameters should hold only one value (quantization value) see globalColorHistogram.m
%% If descriptorType is textureDescriptor then parameters should hold only two values [gridSize and edgeOrientation) see textureDescriptor.m

close all;

switch descriptorType
    case "ColorHistDescriptor"
        query = globalColorHistogram(image, parameters(1));
    case "textureDescriptor"
        query = textureDescriptor(image, parameters(1), parameters(2));
end

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';
DESCRIPTOR_FOLDER = 'descriptors';


ALLFEAT=[];
ALLFILES=cell(1,0);
ctr=1;
allfiles=dir(fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    featfile=DESCRIPTOR_FOLDER+"/"+DESCRIPTOR_SUBFOLDER+"/"+fname(1:end-4)+".mat";%replace .bmp with .mat
    load(featfile,'F');
    ALLFILES{ctr}=imgfname_full;
    ALLFEAT=[ALLFEAT ; F];
    ctr=ctr+1;
end

dst=[];

if strcmp(distanceMetric, 'Mahalanobis')
    load(DESCRIPTOR_FOLDER +"/" +DESCRIPTOR_SUBFOLDER+"/projection_matrix.mat", 'projectionMatrix');
else
    projectionMatrix = [];
end

for i=1:length(ALLFILES)
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

dst=dst(1:nResults,:);

resize_image = imresize(image, [200, 300]);
outdisplay=[resize_image zeros(size(resize_image, 1), 10, 3)];
prediction_files = {};

for i=1:size(dst,1)
   img=imread(ALLFILES{dst(i,2)});
   img = imresize(img, [200, 300]);
   outdisplay=[outdisplay img zeros(size(img, 1), 10, 3)];
end

imshow(outdisplay);
axis off;


end
