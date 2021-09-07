%% Neural Networks - Task 3.1
% In this script:
% - the fitnets for arousal and valence are developed and trained
% - the RBF networks for arousal and valence are developed and trained

clc;
clear;
close all;

TRAIN_NET_VALENCE = 0;
TRAIN_NET_AROUSAL = 0;
TRAIN_RBF_VALENCE = 0;
TRAIN_RBF_AROUSAL = 1;

if ((TRAIN_NET_VALENCE+TRAIN_NET_AROUSAL+TRAIN_RBF_VALENCE+TRAIN_RBF_AROUSAL) == 0)
    fprintf(" WARNING: No network selected for training \n");
end

test_data_valence = load('data/biomedical_signals/test_data_valence.mat');
training_data_valence = load('data/biomedical_signals/training_data_valence.mat');
test_data_arousal = load('data/biomedical_signals/test_data_arousal.mat');
training_data_arousal = load('data/biomedical_signals/training_data_arousal.mat');

x_train_arousal = training_data_arousal.training_data_arousal.x_train_arousal';
x_train_valence = training_data_valence.training_data_valence.x_train_valence';
y_train_arousal = training_data_arousal.training_data_arousal.y_train_arousal';
y_train_valence = training_data_valence.training_data_valence.y_train_valence';

x_test_arousal = test_data_arousal.test_data_arousal.x_test_arousal';
x_test_valence = test_data_valence.test_data_valence.x_test_valence';
y_test_arousal = test_data_arousal.test_data_arousal.y_test_arousal';
y_test_valence = test_data_valence.test_data_valence.y_test_valence';


%% Fitnet For Arousal
hiddenLayerSize_arousal = 30;

net_arousal = fitnet(hiddenLayerSize_arousal);
net_arousal.divideParam.trainRatio = 0.7;
net_arousal.divideParam.testRatio = 0;
net_arousal.divideParam.valRatio = 0.3;

%net_arousal.trainParam.lr = 0.1; 
%net_arousal.trainParam.epochs = 100;
%net_arousal.trainParam.max_fail = 5;

if TRAIN_NET_AROUSAL == 1
    [net_arousal, tr] = train(net_arousal, x_train_arousal, y_train_arousal, "useParallel", "yes");

    figure(1);
    plotperform(tr);

    % test
    test_output_arousal = net_arousal(x_test_arousal);

    % plot regression
    figure(2)
    plotregression(y_test_arousal, test_output_arousal, " Arousal ");
end

%% Fitner For Valence

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

%% RBF For Arousal
goal_rbf_arousal = 0.02;   % Sum-Squared Error goal
sc_arousal = 1;      % Spread constant

%maxNumNeurons = 50;
%numNeuronsToAdd = 5;
if TRAIN_RBF_AROUSAL == 1
    rbf_arousal = newrb(x_train_arousal, y_train_arousal, goal_rbf_arousal, sc_arousal); %,maxNumNeurons,numNeuronsToAdd);
    view(rbf_arousal);

    output_test_arousal_rbf = rbf_arousal(x_test_arousal);

    figure(5);
    plot(x_test_arousal, y_test_arousal,'r');

    figure(6);
    plot(x_test_arousal, output_test_arousal_rbf, 'b--');

    figure(7);
    plotregression(y_test_arousal, output_test_arousal_rbf);
end

%% RBF For Valence
goal_rbf_valence = 0.02;   % Sum-Squared Error goal
sc_valence = 1;      % Spread constant

%maxNumNeurons = 50;
%numNeuronsToAdd = 5;
if TRAIN_RBF_VALENCE == 1
    rbf_valence = newrb(x_train_valence, y_train_valence, goal_rbf_valence, sc_valence); %,maxNumNeurons,numNeuronsToAdd);
    view(rbf_valence);

    output_test_valence_rbf = rbf_valence(x_test_valence);

    figure(8);
    plot(x_test_valence, y_test_valence,'r');

    figure(9);
    plot(x_test_valence, output_test_valence_rbf, 'b--');

    figure(10);
    plotregression(y_test_valence, output_test_valence_rbf);
end