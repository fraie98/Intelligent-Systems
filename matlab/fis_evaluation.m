%% Evaluation of FIS
clc;
clear;
close all;

fis = readfis('FIS_arousal');
fuzzyData = load("data/biomedical_signals/fuzzyData.mat");

x_test = fuzzyData.fuzzyData.x_test_arousal;
y_test = fuzzyData.fuzzyData.y_test_arousal;

output = evalfis(fis,x_test);

plotregression(y_test, output);

