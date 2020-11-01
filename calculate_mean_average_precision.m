function mean_average_precision = calculate_mean_average_precision(DESCRIPTOR_SUBFOLDER, nResults)

if (nargin<2)
    nResults = 15;
end

totalClasses = 20;
avgPrecisionArray = zeros(1, totalClasses);

for i = 1:totalClasses
    [~, ~, averagePrecision] = cvpr_visualsearch(DESCRIPTOR_SUBFOLDER, nResults, num2str(i), false);
    avgPrecisionArray(i) = averagePrecision;
end

mean_average_precision = mean(avgPrecisionArray);

return