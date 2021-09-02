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
%features = dataset_cleaned(:,3:end);
%target_arousal = dataset_cleaned(:,1);
%target_valence = dataset_cleaned(:,2);

% Now we count the classes for valence and for arousal
howManySamplesForClass_arousal = groupcounts(dataset_cleaned(:,1));
howManySamplesForClass_valence = groupcounts(dataset_cleaned(:,2));

possible_values = [1 2.33333333333333 3.66666666666667 5 6.33333333333333 7.66666666666667 9];

figure("Name", "Classes Distribution For Arousal Before Balancing");
bar(howManySamplesForClass_arousal);
[~, lowest_class_arousal] = min(howManySamplesForClass_arousal);
[~, majority_class_arousal] = max(howManySamplesForClass_arousal);


figure("Name", "Classes Distribution For Valence Before Balancing");
bar(howManySamplesForClass_valence);
[~, lowest_class_valence] = min(howManySamplesForClass_valence);
[~, majority_class_valence] = max(howManySamplesForClass_valence);


augmentation_factors = [0.95 0.96 0.97 0.98 0.99 1.01 1.02 1.03 1.04 1.05];
% Il metodo successivo per ora non va bene in generale perchè quando faccio
% l'augmentation devo tenere in considerazione anche la classe mentre se
% uso la matrice features non lo faccio, mentre se uso solo la matrice
% dataset_cleaned perturbo anche la classe, quindi la soluzione e usare
% dataset cleaned senza perturbare valence e arousal
rep = 30;
for k = 1:rep
    for i = 1:row_survived
        if (dataset_cleaned(i,1)==possible_values(lowest_class_arousal) && dataset_cleaned(i,2)~=possible_values(majority_class_valence)) || (dataset_cleaned(i,1)~=possible_values(majority_class_arousal) && dataset_cleaned(i,2)==possible_values(lowest_class_valence))
            fprintf("ok %i sto per perturbare la classe valence:%f e arousal:%f\n",i, dataset_cleaned(i,2), dataset_cleaned(i,1));
            % Selection of i-th row
            row_original = dataset_cleaned(i,:);
            % Augmentation of the i-th row with 10 different factors
            row_to_add = row_original;
            for j = 1:10
                row_to_add(3:end) = row_original(3:end).*augmentation_factors(j); 
                % Addition of the new sample, obtained through augmentation, to
                % the dataset
                dataset_cleaned = [dataset_cleaned; row_to_add];
            end
        end
    end
    fprintf("abc %i\n",k);
    howManySamplesForClass_arousal = groupcounts(dataset_cleaned(:,1));
    howManySamplesForClass_valence = groupcounts(dataset_cleaned(:,2));

    [~, lowest_class_arousal] = min(howManySamplesForClass_arousal);
    [~, majority_class_arousal] = max(howManySamplesForClass_arousal);

    [~, lowest_class_valence] = min(howManySamplesForClass_valence);
    [~, majority_class_valence] = max(howManySamplesForClass_valence);
end
howManySamplesForClass_arousal = groupcounts(dataset_cleaned(:,1));
howManySamplesForClass_valence = groupcounts(dataset_cleaned(:,2));

figure("Name", "Classes Distribution For Arousal After Balancing");
bar(howManySamplesForClass_arousal);
%[~, lowest_class_arousal] = min(howManySamplesForClass_arousal);
%[~, majority_class_arousal] = max(howManySamplesForClass_arousal);


figure("Name", "Classes Distribution For Valence After Balancing");
bar(howManySamplesForClass_valence);
%[~, lowest_class_valence] = min(howManySamplesForClass_valence);
%[~, majority_class_valence] = max(howManySamplesForClass_valence);

