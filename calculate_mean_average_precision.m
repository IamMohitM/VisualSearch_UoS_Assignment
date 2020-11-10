function [avgPrecisionPerClass, mean_average_precision, avgPrecisionArray] = calculate_mean_average_precision(DESCRIPTOR_SUBFOLDER, nResults, iterations)

if (nargin<2)
    nResults = 15;
    iterations = 10;
elseif (nargin<3)
    iterations = 10;
end

totalClasses = 20;
avgPrecisionArray = zeros(1, totalClasses*iterations);
avgPrecisionPerClass = zeros(1, totalClasses);
iter = 0;
for i = 1:totalClasses
    disp("Class "+ num2str(i));
    for j=1:iterations
        iter = iter + 1;
        [~, ~, averagePrecision] = cvpr_visualsearch(DESCRIPTOR_SUBFOLDER, '', nResults, num2str(i), false);
        avgPrecisionArray(iter) = averagePrecision;
    end
    avgPrecisionPerClass(i) = mean(avgPrecisionArray((10*(i-1))+1:(10*(i-1))+10));
    fprintf("Average Precision %2.4f\n", avgPrecisionPerClass(i));
end

mean_average_precision = mean(avgPrecisionArray);

return