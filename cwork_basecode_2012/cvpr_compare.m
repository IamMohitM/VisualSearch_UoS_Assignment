function dst=cvpr_compare(F1, F2, distanceMetric, E)

% This function should compare F1 to F2 - i.e. compute the distance
% between the two descriptors

% For now it just returns a random number
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
    otherwise
        dst = sqrt(sum((F1 - F2).^2));
end
% dst=rand();

return;
