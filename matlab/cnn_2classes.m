%% Convolutional Neural Network - Two Classes Classification Problem
% This script contains the development and training of a CNN for
% classifying facial expressions. In particular this CNN based on
% pre-trained Alexnet classify images in two classes: anger and happiness. 

clc;
clear;
close all;


%% Constants and Parameters
numberOfClasses = 2;

%% Load And Prepare Data
% Load image from the dataset and prepare it adding labels
%img_data = imageDatastore('data/img_2classes/NoSelection', ...
%    'IncludeSubfolders',true, ...
%    'LabelSource','foldernames');

img_data = imageDatastore('data/img_2classes/Selected', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

% 70 per training e 30 per validation
[img_data_train, img_data_validation] = splitEachLabel(img_data, 0.7, 'randomized');

%% Load and modify alexnet
net = alexnet;
%analyzeNetwork(net);

input_size = net.Layers(1).InputSize;

% I extract all the layer from the pretrained network except the last three
% that will be added afterwards and fine-tuned for the specific problem
original_layers = net.Layers(1:end-3);

% Now I build the network structure adding to the original layers of the
% pretrained network other three layers:
% - A fully connected layer that has as inputs the number of classes and
%   weight and bias learning rate high
% - A softmax layer for classification
% - A classification layer for the final output
net_layers = [
    original_layers
    fullyConnectedLayer(numberOfClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

%% Network Training
pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection', true, ...
    'RandXTranslation', pixelRange, ...
    'RandYTranslation', pixelRange);

% Image augmentation for training and simultaneously image resize to fit
% the input image size of alexnet that is 227x227x3
augmented_image_data_train = augmentedImageDatastore(input_size(1:2), img_data_train, 'DataAugmentation', imageAugmenter);
augmented_image_data_validation = augmentedImageDatastore(input_size(1:2), img_data_validation);

% Training options
training_options = trainingOptions('sgdm', ...
    'MiniBatchSize', 10, ...
    'MaxEpochs', 6, ...
    'InitialLearnRate', 1e-4, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData',augmented_image_data_validation, ...
    'ValidationFrequency', 3, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% train the network
new_CNN = trainNetwork(augmented_image_data_train, net_layers, training_options);

%% Network Testing
% Classification of the validation images

[y, scores] = classify(new_CNN, augmented_image_data_validation);
t = img_data_validation.Labels;
accuracy = mean(y==t);
