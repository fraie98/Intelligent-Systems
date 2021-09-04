%% Neural Networks - Task 3.1
% In this script:
% - the fitnets for arousal and valence are developed and trained
% - the RBF networks for arousal and valence are developed and trained

clc;
clear;
close all;

test_data = load('data/biomedical_signals/test_data.mat');
training_data = load('data/biomedical_signals/training_data.mat');

x_train_arousal = training_data.training_data.x_train_arousal';
x_train_valence = training_data.training_data.x_train_valence';
y_train_arousal = training_data.training_data.y_train_arousal';
y_train_valence = training_data.training_data.y_train_valence';

x_test_arousal = test_data.test_data.x_test_arousal';
x_test_valence = test_data.test_data.x_test_valence';
y_test_arousal = test_data.test_data.y_test_arousal';
y_test_valence = test_data.test_data.y_test_valence';


hiddenLayerSize_arousal = 40; %20 non male
net_arousal = fitnet(hiddenLayerSize_arousal);
net_arousal.divideParam.trainRatio = 0.7;
net_arousal.divideParam.testRatio = 0.1;
net_arousal.divideParam.valRatio = 0.2;

[net_arousal, tr] = train(net_arousal, x_train_arousal, y_train_arousal);

figure(1);
plotperform(tr);

% test
test_output_arousal = net_arousal(x_test_arousal);

% plot regression
figure(2);
plotregression(y_test_arousal, test_output_arousal);

%% Valence

%hiddenLayerSize_valence = 50;
%net_valence = fitnet(hiddenLayerSize_valence);

%[net_valence, tr_valence] = train(net_valence, x_train_valence, y_train_valence);

%figure(3);
%plotperform(tr_valence);

% test
%output_valence = net_valence(x_test_valence);

% plot regression
%figure(4);
%plotregression(y_test_valence, output_valence);
