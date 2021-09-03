%% Preparation of the dataset
% In the following script the following steps are performed:
% - Removal of non-numerical values
% - Outliers Removal
% - Dataset Balancing
% .....

clc;
clear;
close all;

% constant valid after the removal of subject_id and video_id
COL_AROUSAL = 1;
COL_VALENCE = 2;

dataset = load("datasets/dataset.mat");
% it can be useful for debugging in order to see the original dataset
%original = dataset; 
dataset = table2array(dataset.dataset);

[howManyRow, ~] = size(dataset);

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
dataset(:,1) = [];
dataset(:,1) = [];

% TODO qui è necessario fare delle prove e vedere il metodo migliore tra:
% 'median', 'mean', 'quartiles', 'grubbs', 'gesd'
[dataset_cleaned, ~] = rmoutliers(dataset);
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

figure("Name", "Classes Distribution For Arousal Before Balancing");
bar(howManySamplesForClass_arousal);
[~, lowest_class_arousal] = min(howManySamplesForClass_arousal);
[~, majority_class_arousal] = max(howManySamplesForClass_arousal);

figure("Name", "Classes Distribution For Valence Before Balancing");
bar(howManySamplesForClass_valence);
[~, lowest_class_valence] = min(howManySamplesForClass_valence);
[~, majority_class_valence] = max(howManySamplesForClass_valence);

augmentation_factors = [0.95 0.96 0.97 0.98 0.99 1.01 1.02 1.03 1.04 1.05];

debug = dataset_cleaned;
possible_values = [1 2.333333333333333 3.666666666666667 5 6.333333333333333 7.666666666666667 9];
% Copying the values directly from the dataset in order to avoid
% different approximation
possible_values(1) = debug(10,1);
possible_values(2) = debug(1,1);
possible_values(3) = debug(8,1);
possible_values(4) = debug(15,1);
possible_values(5) = debug(7,1);
possible_values(6) = debug(21,1);
possible_values(7) = debug(27,1);

%% Data balancing
% The algorithm to balance the data is the following: 
%  1) I augment the samples that belong to the majority class of arousal 
% and don't belong to the majority class of valence; and the samples that 
% belong to the majority class of valence and don't belong to the minority
% class of arousal.
% 2) Then I removed the samples that belong to the majority class of 
% arousal and don't belong to the minority class of valence; and the
% samples that belong to the majority class of valence and don't belong to
% the minority class of arousal.
%
% I repeat this two steps rep (i.e. 40) times and for each repetition I
% compute the new majority and minority classe both for arousal and valence
rep = 40;
row_to_check = row_survived;
for k = 1:rep
    for i = 1:row_to_check
        if (dataset_cleaned(i,1)==possible_values(lowest_class_arousal) && dataset_cleaned(i,2)~=possible_values(majority_class_valence)) || (dataset_cleaned(i,1)~=possible_values(majority_class_arousal) && dataset_cleaned(i,2)==possible_values(lowest_class_valence))
            fprintf("ok %i sto per perturbare la classe valence:%f e arousal:%f\n",i, dataset_cleaned(i,2), dataset_cleaned(i,1));
            % Selection of i-th row
            row_original = dataset_cleaned(i,:);
            % Augmentation of the i-th row with 10 different factors
            row_to_add = row_original;
            %for j = 1:5
                row_to_add(3:end) = row_original(3:end).*augmentation_factors(2); 
                % Addition of the new sample, obtained through augmentation, to
                % the dataset
                dataset_cleaned = [dataset_cleaned; row_to_add];
                %row_to_check = row_to_check +1;
            %end
        end
        
        if((dataset_cleaned(i,1)==possible_values(majority_class_arousal) && dataset_cleaned(i,2)~=possible_values(lowest_class_valence)) || (dataset_cleaned(i,2)==possible_values(majority_class_valence) && dataset_cleaned(i,1)~=possible_values(lowest_class_arousal)))
            dataset_cleaned(i,:)=[];
            row_to_check = row_to_check - 1;
            fprintf(" Sto eliminando la riga %i\n",i);
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

% Undersample on class 1 (for valence) because experiments prove that the
% previous algorithm create a distribution in which the first class has too
% many samples
[row_to_check, ~] = size(dataset_cleaned);
howManyToDelete = 30;
deleted = 0;              
% In the following loop I set to 0 the rows which correspond to samples
% that have a valence class equal to 1
for i = 1:row_to_check
    %DEBUG fprintf("%i> %d is %d ?\n", i, dataset_cleaned(i,COL_VALENCE), possible_values(1));
    if dataset_cleaned(i,COL_VALENCE)==possible_values(1) && deleted<howManyToDelete
        % DEBUGfprintf(" write to Remove row %i\n",i);
        dataset_cleaned(i,:) = 0;
        deleted = deleted + 1;
    end
end

% I find the row with all zeros and I delete them
[rowToRemove, ~] = find(~dataset_cleaned);
disp(rowToRemove);
dataset_cleaned(rowToRemove,:)=[];

%% Plot of the histograms to check the balancing
howManySamplesForClass_arousal = groupcounts(dataset_cleaned(:,1));
howManySamplesForClass_valence = groupcounts(dataset_cleaned(:,2));
figure("Name", "Classes Distribution For Arousal After Balancing");
bar(howManySamplesForClass_arousal);
figure("Name", "Classes Distribution For Valence After Balancing");
bar(howManySamplesForClass_valence);

%% Cross Validation and feature selection


