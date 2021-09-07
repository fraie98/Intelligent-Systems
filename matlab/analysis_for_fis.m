%% Fuzzy System - Feature Analysis and FIS evaluation

clc;
clear;
close all;

% Constant
PLOT_HIST_LOW = 1;
PLOT_HIST_MEDIUM = 0;
PLOT_HIST_HIGH = 0;

% Load Data
fuzzyData = load("data/biomedical_signals/fuzzyData.mat");
dataset = load("data/biomedical_signals/dataset_cleaned.mat");
dataset = dataset.dataset_cleaned;

x_train = fuzzyData.fuzzyData.x_train_arousal;
y_train = fuzzyData.fuzzyData.y_train_arousal;

x_test = fuzzyData.fuzzyData.x_test_arousal;
y_test = fuzzyData.fuzzyData.y_test_arousal;

best_features = fuzzyData.fuzzyData.best_features;

y_values = fuzzyData.fuzzyData.y_values;

%% Find universe of discourse 

x_level_17 = x_train(:,1);
x_level_27 = x_train(:,2);
x_level_35 = x_train(:,3);

max_17 = max(x_level_17);
max_27 = max(x_level_27);
max_35 = max(x_level_35);

min_17 = min(x_level_17);
min_27 = min(x_level_27);
min_35 = min(x_level_35);

fprintf(" --- RANGES FOR UNIVERSE OF DISCOURSE ---\n");
fprintf("  Feature 17 -> Max:%f Min:%f\n", max_17, min_17);
fprintf("  Feature 27 -> Max:%f Min:%f\n", max_27, min_27);
fprintf("  Feature 35 -> Max:%f Min:%f\n", max_35, min_35);

%% Analysis of the features

% I plot rispondono alla domanda quanti sono i samples di output low per la
% feature x?
y_level_low = find(y_train==y_values(1) | y_train==y_values(2));
y_level_medium = find(y_train==y_values(3) | y_train==y_values(4) | y_train==y_values(5));
y_level_high = find(y_train==y_values(6) | y_train==y_values(6));


%Low
if PLOT_HIST_LOW==1
    figure(1);
    histogram(x_train(y_level_low,1));
    figure(2);
    histogram(x_train(y_level_low,2));
    figure(3);
    histogram(x_train(y_level_low,3));
end

%Medium
if PLOT_HIST_MEDIUM==1
    figure(4);
    histogram(x_train(y_level_medium,1));
    figure(5);
    histogram(x_train(y_level_medium,2));
    figure(6);
    histogram(x_train(y_level_medium,3));
end

%High
if PLOT_HIST_HIGH==1
    figure(7);
    histogram(x_train(y_level_high,1));
    figure(8);
    histogram(x_train(y_level_high,2));
    figure(9);
    histogram(x_train(y_level_high,3));
end
