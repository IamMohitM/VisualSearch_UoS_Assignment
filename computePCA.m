function computePCA(DESCRIPTOR_SUBFOLDER_PATH, PCA_OUT_FOLDER_PATH, pcaComponents) 

    DATASET_FOLDER = "MSRC_ObjCategImageDatabase_v2";
    DESCRIPTOR_FOLDER = "descriptors";
    allfiles=dir(fullfile(DATASET_FOLDER+'/Images/*.bmp'));
    ALLFEAT=[];
    ALLFILES=cell(1,0);
    ctr = 1;
    for filenum=1:length(allfiles)
        fname=allfiles(filenum).name;
        featfile=[DESCRIPTOR_FOLDER+"/"+DESCRIPTOR_SUBFOLDER_PATH+"/"+fname(1:end-4)+".mat"];
        load(featfile, 'F');
        ALLFEAT=[ALLFEAT ; F];
        ctr=ctr+1;
    end
    allfeat = ALLFEAT';
    E= Eigen_Build(allfeat);
    projectionMatrix = Eigen_Deflate(E, 'keepn', pcaComponents);
    projected_data = Eigen_Project(allfeat, projectionMatrix)';
    
    %Save the projection Matrix
    projected_fout = DESCRIPTOR_FOLDER+"/"+ PCA_OUT_FOLDER_PATH+ "/"+"projection_matrix.mat";
    save(projected_fout, "projectionMatrix");
    for i=1:size(projected_data, 1)
        F = projected_data(i, :);
        
        fname=allfiles(i).name;
        fout=DESCRIPTOR_FOLDER+"/"+PCA_OUT_FOLDER_PATH+"/"+fname(1:end-4)+".mat"; %replace .bmp with .mat
        save(fout,"F"); 
    end
end