%% Features Analysis For Fuzzy System

clc;
clear;
close all;

% Constant
PLOT_HIST_LOW = 1;
PLOT_HIST_MEDIUM = 1;
PLOT_HIST_HIGH = 1;

% Load Data
fuzzyData = load("data/biomedical_signals/fuzzyData.mat");

x_train = fuzzyData.fuzzyData.x_train_arousal;
y_train = fuzzyData.fuzzyData.y_train_arousal;

x_test = fuzzyData.fuzzyData.x_test_arousal;
y_test = fuzzyData.fuzzyData.y_test_arousal;

best_features = fuzzyData.fuzzyData.best_features;

y_values = fuzzyData.fuzzyData.y_values;

%% Find universe of discourse 

x_level_24 = x_train(:,1);
x_level_27 = x_train(:,2);
x_level_37 = x_train(:,3);

max_24 = max(x_level_24);
max_27 = max(x_level_27);
max_37 = max(x_level_37);

min_24 = min(x_level_24);
min_27 = min(x_level_27);
min_37 = min(x_level_37);

fprintf(" --- RANGES FOR UNIVERSE OF DISCOURSE ---\n");
fprintf("  Feature 24 -> Max:%f Min:%f\n", max_24, min_24);
fprintf("  Feature 27 -> Max:%f Min:%f\n", max_27, min_27);
fprintf("  Feature 37 -> Max:%f Min:%f\n", max_37, min_37);

%% Analysis of the features

% Check how many samples have a low/medium/high output that correspond to
% the different values of a particular feature
y_level_low = find(y_train==y_values(1) | y_train==y_values(2));
y_level_medium = find(y_train==y_values(3) | y_train==y_values(4) | y_train==y_values(5));
y_level_high = find(y_train==y_values(6) | y_train==y_values(7));


%Low
if PLOT_HIST_LOW==1
    figure(1);
    histogram(x_train(y_level_low,1));
    title("Low Outputs For Feature 24");
    figure(2);
    histogram(x_train(y_level_low,2));
    title("Low Outputs For Feature 27");
    figure(3);
    histogram(x_train(y_level_low,3));
    title("Low Outputs For Feature 37");
end

%Medium
if PLOT_HIST_MEDIUM==1
    figure(4);
    histogram(x_train(y_level_medium,1));
    title("Medium Outputs For Feature 24");
    figure(5);
    histogram(x_train(y_level_medium,2));
    title("Medium Outputs For Feature 27");
    figure(6);
    histogram(x_train(y_level_medium,3));
    title("Medium Outputs For Feature 37");
end

%High
if PLOT_HIST_HIGH==1
    figure(7);
    histogram(x_train(y_level_high,1));
    title("High Outputs For Feature 24");
    figure(8);
    histogram(x_train(y_level_high,2));
    title("High Outputs For Feature 27");
    figure(9);
    histogram(x_train(y_level_high,3));
    title("High Outputs For Feature 37");
end
