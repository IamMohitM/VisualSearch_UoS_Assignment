function computePRGraph(DESCRIPTOR_SUBFOLDER, distanceMetrics)
%% This will compute PR graphs for distance metrics Euclidean, Cosine, Manhattan
%% and save it in PR_Plots Directory, one image for each distance metric.
%% If isMahalanobis is true, then will compute the Mahalanobis distance too, Use
%% this only for PCA Descriptors.

if nargin<2
    distanceMetrics = ["Manhattan", "Euclidean", "cosine"];
end

DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';
DESCRIPTOR_FOLDER = 'descriptors';
OUT_FOLDER = "PR_Plots/";
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




for metric=1:length(distanceMetrics)
    dstMetric = distanceMetrics(metric);
    disp(dstMetric);
    precisionArray = [];
    recallArray=[];
    
    if strcmp(dstMetric, 'Mahalanobis')
        load(DESCRIPTOR_FOLDER +"/" +DESCRIPTOR_SUBFOLDER+"/projection_matrix.mat", 'projectionMatrix');
    else
        projectionMatrix = [];
    end
    
    for filenum=1:length(allfiles)
        query_file_path = ALLFILES{filenum};
        disp(query_file_path);
        [~, query_file, ~] = fileparts(query_file_path);
        query = ALLFEAT(filenum, :);
        dst=[];
        
        
        for i=1:length(allfiles)
            candidate=ALLFEAT(i,:);
            distance=cvpr_compare(query,candidate, dstMetric, projectionMatrix);
            dst=[dst ; [distance i]];
        end
        
        if strcmp(dstMetric, "cosine")
            dst = sortrows(dst, 1, "descend");
        else
            dst=sortrows(dst,1);
        end
        
        prediction_files = {};

        for i=1:size(dst,1)
           [~, name, ~] = fileparts(ALLFILES{dst(i, 2)});
           prediction_files = [prediction_files ; name];
        end
        
        [p, r, ~] = evaluate_results(query_file, prediction_files);
        precisionArray = [precisionArray; p];
        recallArray = [recallArray; r];
    end
      
    meanPrecision = mean(precisionArray);
    meanRecall = mean(recallArray);
   
    disp(size(meanPrecision));
    disp(size(meanRecall));
    
    close all;
    figure;
    plot(meanRecall, meanPrecision);
    title("Precision-Recall Curve ");
    xlabel("Recall");
    ylabel("Precision");
    axis on;
    filename = OUT_FOLDER + "/" + DESCRIPTOR_SUBFOLDER + "_" + dstMetric + ".png";
    fprintf('Saving to %s\n',filename);
    saveas(gcf, filename);
end

end