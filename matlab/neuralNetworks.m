%% Neural Networks - Task 3.1
% In this script:
% - the fitnets for arousal and valence are developed and trained
% - the RBF networks for arousal and valence are developed and trained

clc;
clear;
close all;

test_data = load('data/biomedical_signals/test_data.mat');
training_data = load('data/biomedical_signals/training_data.mat');