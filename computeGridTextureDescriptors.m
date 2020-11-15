function computeGridTextureDescriptors(OUT_SUBFOLDER, gridSize, edgeBins)
%% computes texture descriptors for all Images in the DATASET_FOLDER and saves them in
%% OUT_SUBFOLDER (must be created before running this function)
%% Gridsize defines size of grid and must be divisible by both 300 and 200 (because square grid)
%% edge_bins defines the quantization value of edge orientations

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';

OUT_FOLDER = 'descriptors';
% OUT_SUBFOLDER='TD_50_30';
% gridSize = 50;
% edgeBins = 30;
allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    fprintf('Processing file %d/%d - %s\n',filenum,length(allfiles),fname);
    tic;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full));
    fout=OUT_FOLDER+"/"+OUT_SUBFOLDER+"/"+fname(1:end-4)+".mat";%replace .bmp with .mat
    F=textureDescriptor(img, gridSize, edgeBins);
    save(fout,'F');
    toc
end
