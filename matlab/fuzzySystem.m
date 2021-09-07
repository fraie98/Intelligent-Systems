%% Fuzzy System - Feature Analysis and FIS evaluation

clc;
clear;
close all;

fuzzyData = load("data/biomedical_signals/fuzzyData.mat");
dataset = load("data/biomedical_signals/dataset_cleaned.mat");
dataset = dataset.dataset_cleaned;

x_train = fuzzyData.fuzzyData.x_train_arousal;
y_train = fuzzyData.fuzzyData.y_train_arousal;

x_test = fuzzyData.fuzzyData.x_test_arousal;
y_test = fuzzyData.fuzzyData.y_test_arousal;

best_features = fuzzyData.fuzzyData.best_features;

y_values = fuzzyData.fuzzyData.y_values;

y_levels = zeros(1,7);

for i=1:7
   y_levels(i) = find(y_train==y_values(i)); 
end
%% Analysis of the features

histogram(x_train(y_levels(1)));
