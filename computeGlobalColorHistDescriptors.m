function computeGlobalColorHistDescriptors(OUT_SUBFOLDER, quantize)
%% computes texture descriptors for all Images in the DATASET_FOLDER and saves them in
%% OUT_SUBFOLDER (must be created before running this function)
%% quantize specifies the quantization of the color ranges



DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';

OUT_FOLDER = 'descriptors';

allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    fprintf('Processing file %d/%d - %s\n',filenum,length(allfiles),fname);
    tic;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full));
    fout=[OUT_FOLDER,'/',OUT_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
    F=globalColorHistogram(img, quantize);
    save(fout,'F');
    toc
end
