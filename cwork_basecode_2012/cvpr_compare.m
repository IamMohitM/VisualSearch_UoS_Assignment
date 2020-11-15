function dst=cvpr_compare(F1, F2, distanceMetric, E)
%% compares two vectors based on the distanceMetrics default "Euclidean"
%% Can use metrics, "Euclidean" "cosine", "Manhattan", "Mahalanobis"
%% E parameter is the projection Matrix with Eigen Vectors and Eigen Values
%% E is only required for computing Mahalanobis

if nargin<3
    distanceMetric = "Euclidean";
end

switch distanceMetric
    case "Mahalanobis"
        scaled = ((F1-F2).^2)/E.val(1:length(F1))';
        dst = sqrt(sum(scaled));
    case "cosine"
        F1 = double(F1);
        F2 = double(F2);
        dst = dot(F1, F2)/(norm(F1)*norm(F2));
    case "Manhattan"
        dst = sum(abs(F1 - F2));
    case "Euclidean"
        dst = sqrt(sum((F1 - F2).^2));
end


return;
