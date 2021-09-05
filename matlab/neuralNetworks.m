%% Neural Networks - Task 3.1
% In this script:
% - the fitnets for arousal and valence are developed and trained
% - the RBF networks for arousal and valence are developed and trained

clc;
clear;
close all;

TRAIN_NET_VALENCE = 1;
TRAIN_NET_AROUSAL = 0;

test_data_valence = load('data/biomedical_signals/test_data_valence.mat');
training_data_valence = load('data/biomedical_signals/training_data_valence.mat');

%x_train_arousal = training_data.training_data.x_train_arousal';
x_train_valence = training_data_valence.training_data.x_train_valence';
%y_train_arousal = training_data.training_data.y_train_arousal';
y_train_valence = training_data_valence.training_data.y_train_valence';

%x_test_arousal = test_data.test_data.x_test_arousal';
x_test_valence = test_data_valence.test_data.x_test_valence';
%y_test_arousal = test_data.test_data.y_test_arousal';
y_test_valence = test_data_valence.test_data.y_test_valence';


%c = cvpartition(y_test_arousal, "KFold", 10);

hiddenLayerSize_arousal = 30;

net_arousal = fitnet(hiddenLayerSize_arousal);
%net_arousal.trainFcn = 'trainscg';
net_arousal.divideParam.trainRatio = 0.75;
net_arousal.divideParam.testRatio = 0;
net_arousal.divideParam.valRatio = 0.25;

net_arousal.trainParam.lr = 0.1; 
net_arousal.trainParam.epochs = 100;
net_arousal.trainParam.max_fail = 5;

if TRAIN_NET_AROUSAL == 1
    [net_arousal, tr] = train(net_arousal, x_train_arousal, y_train_arousal, "useParallel", "yes");

    figure(1);
    plotperform(tr);
    %title("Perform iteration %f",i);

    % test
    test_output_arousal = net_arousal(x_test_arousal);

    % plot regression
    figure(2)
    plotregression(y_test_arousal, test_output_arousal, " Arousal ");
    %title("Regression iteration %f",i);
end
%% Valence

hiddenLayerSize_valence = 35;
net_valence = fitnet(hiddenLayerSize_valence);
net_valence.divideParam.trainRatio = 0.7;
net_valence.divideParam.testRatio = 0;
net_valence.divideParam.valRatio = 0.3;

if TRAIN_NET_VALENCE == 1
    [net_valence, tr_valence] = train(net_valence, x_train_valence, y_train_valence);

    figure(3);
    plotperform(tr_valence);

    % test
    output_valence = net_valence(x_test_valence);

    % plot regression
    figure(4);
    plotregression(y_test_valence, output_valence, " Valence ");
end