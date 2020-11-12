function computePCA(DESCRIPTOR_SUBFOLDER_PATH, PCA_OUT_FOLDER_PATH, pca_parameter, variance_contribution) 

    if nargin<4
        variance_contribution = false;
    end
    
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
    disp("Building Eigen Model");
    E= Eigen_Build(allfeat);
    
    disp("Performing PCA");
    if variance_contribution
        projectionMatrix = Eigen_Deflate(E, 'keepf', pca_parameter);
    else
        projectionMatrix = Eigen_Deflate(E, 'keepn', pca_parameter);
    end
    disp("Projecting Features");
    projected_data = Eigen_Project(allfeat, projectionMatrix)';
    
    %Save the projection Matrix
    disp("Saving computed features");
    projected_fout = DESCRIPTOR_FOLDER+"/"+ PCA_OUT_FOLDER_PATH+ "/"+"projection_matrix.mat";
    save(projected_fout, "projectionMatrix");
    for i=1:size(projected_data, 1)
        F = projected_data(i, :);
        fname=allfiles(i).name;
        fout=DESCRIPTOR_FOLDER+"/"+PCA_OUT_FOLDER_PATH+"/"+fname(1:end-4)+".mat"; %replace .bmp with .mat
        save(fout,"F"); 
    end
end