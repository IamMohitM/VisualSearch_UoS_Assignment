function calculate_test_results(DESCRIPTOR_SUBFOLDER, points, isMahalanobis)
%% Calculates the average precision for all classes and mean average precision of
%% the descriptors in the DESCRIPTOR_SUBFOLDER for metrics [Euclidean, cosine, Manhattan](default)
%% The results are saved in the Results/Results.xlsx in sheet DESCRIPTOR_SUBFOLDER 
%% Average Precision per class is calculated over 10 iterations for each class
%% 'points' must be a list of top n results to calculate the metrics. default ([3, 5, 10, 15, 20])
%% set isMahalanobis=true to calculate with Mahalanobis distance too

outFolder = "Results/";
DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';
DESCRIPTOR_FOLDER = 'descriptors';

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

if nargin<2
    points = [3, 5, 10, 15, 20];
    isMahalanobis = false;
end

if isMahalanobis
    distanceMetrics = ["Manhattan", "Euclidean", "cosine", "Mahalanobis"];
else
    distanceMetrics = ["Manhattan", "Euclidean", "cosine"];
end

totalClasses = 20;
filename = outFolder+'Results.xlsx';
iterations = 10;
for metric=1:length(distanceMetrics)
    dstMetric = distanceMetrics(metric);
    disp(dstMetric);
    count = 1;
    sheetName =  DESCRIPTOR_SUBFOLDER+ "_"+ dstMetric;
    headers = [(1:20) "map"];
    writematrix(headers, filename, "Sheet", sheetName,'WriteMode', 'append');
    
    for pointIndex=1:length(points)
        iter = 0;
        avgPrecisionPerClass = zeros(1, totalClasses+1);
        
        for classVal=1:totalClasses
            avgPrecisionArray = zeros(1, totalClasses*iterations);
            for j=1:iterations
                iter = iter+1;
                [~, ~, AP] = faster_visual_search(ALLFEAT, ALLFILES, allfiles, DESCRIPTOR_SUBFOLDER, dstMetric, points(pointIndex), classVal);
                avgPrecisionArray(iter) = AP;
            end
            avgPrecisionPerClass(classVal) = mean(avgPrecisionArray((10*(classVal-1))+1:(10*(classVal-1))+10));
        end
        avgPrecisionPerClass(end) = mean(avgPrecisionPerClass(1:20));
        disp("Saving to " + sheetName);
        writematrix(avgPrecisionPerClass,filename,"Sheet" ,sheetName, 'WriteMode', 'append');
        count = count + 1;
    end
    
end

end