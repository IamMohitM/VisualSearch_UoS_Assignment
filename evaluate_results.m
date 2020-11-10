function [precision, recall, average_precision] = evaluate_results(ground_truth, predictions)

ground_truth_split = split(ground_truth, '_');
true_label = ground_truth_split(1);

precision = zeros(1, length(predictions));
recall = zeros(1, length(predictions));
relevant_predictions = zeros(1, length(predictions));

class_freqs = load('class_frequency.mat');
n = str2num(true_label{1}); %#ok<ST2NM>
true_positives = class_freqs.class_freq(n);
correct_predictions = 0;

for i=1:length(predictions)
    prediction_split = split(predictions(i), '_');
    prediction_label = prediction_split(1);
    relevant_predictions(i) = strcmp(true_label, prediction_label);
    correct_predictions = correct_predictions + relevant_predictions(i);
    precision(i) = double(correct_predictions)/i;
    recall(i) = double(correct_predictions)/true_positives;
end
average_precision = sum(precision .* relevant_predictions)/true_positives;

return;