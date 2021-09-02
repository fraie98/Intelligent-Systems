%% Preparation of the dataset
% In the following script the following steps are performed:
% - Removal of non-numerical values
% - Outliers Removal
% - Dataset Balancing
% .....

clc;
clear;
close all;

dataset = load("datasets/dataset.mat");
original = dataset;
dataset = table2array(dataset.dataset);

%% Removal of non numerical values

isInfinite = isinf(dataset);
% find return the rows and the columns of the elements equal to 1 in
% isInfinitere, those elements are the ones that have infinite values in
% the datasetm thus I have to remove the samples (row) that contains these
% values
[rinf, ~] = find(isInfinite==1);
dataset(rinf,:) = [];

%% Outliers removal
% The first two columns contains useless informations thus they can be
% deleted
original2 = dataset;
dataset(:,1) = [];
dataset(:,1) = [];

% TODO qui è necessario fare delle prove e vedere il metodo migliore tra:
% 'median', 'mean', 'quartiles', 'grubbs', 'gesd'
[dataset_cleaned, where_outliers] = rmoutliers(dataset);
[row_survived, ~] = size(dataset_cleaned);
[row_raw, ~] = size(dataset);
outliers_removed = row_raw - row_survived;
fprintf(" %i outliers have been removed, %i samples remain\n", outliers_removed, row_survived);

%% Dataset Balancing
% Let visualize the distribution for valence and arousal before the
% balancing

% Let divide output from input
features = dataset_cleaned(:,3:end);
target_arousal = dataset_cleaned(:,1);
target_valence = dataset_cleaned(:,2);

% Now we count the classes for valence and for arousal
howManySamplesForClass_arousal = groupcounts(target_arousal);
howManySamplesForClass_valence = groupcounts(target_valence);

figure("Name", "Classes Distribution For Arousal Before Balancing");
bar(howManySamplesForClass_arousal);
[~, lowest_class_arousal] = min(howManySamplesForClass_arousal);
[~, majority_class_arousal] = max(howManySamplesForClass_arousal);


figure("Name", "Classes Distribution For Valence Before Balancing");
bar(howManySamplesForClass_valence);
[~, lowest_class_valence] = min(howManySamplesForClass_valence);
[~, majority_class_valence] = max(howManySamplesForClass_valence);

% Il metodo successivo per ora non va bene in generale perchè quando faccio
% l'augmentation devo tenere in considerazione anche la classe mentre se
% uso la matrice features non lo faccio, mentre se uso solo la matrice
% dataset_cleaned perturbo anche la classe, quindi la soluzione e usare
% dataset cleaned senza perturbare valence e arousal
for i = 1:row_survived
    if i==lowest_class_arousal && i~=majority_class_valence
        %questo metodo va bene per selezionare una riga
        row_temp = features(i,:);
        
        %quesot metodo va bene per effettuare una augmentation
        disp("Prima");
        disp(row_temp);
        row_temp = row_temp.*1.05;
        disp("Dopo");
        disp(row_temp);
        
        % questo metodo va bene per aggiungere righe
        features = [features; row_temp];
        
    end
end
