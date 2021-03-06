%% Script for data preparation
% In the following script the following steps are performed:
% - Removal of non-numerical values
% - Outliers Removal
% - Dataset Balancing
% - Features Selection

clc;
clear;
close all;

% constant valid after the removal of subject_id and video_id
COL_AROUSAL = 1;
COL_VALENCE = 2;
% 1 yes (plot graphs), 0 no (do not plot)
PLOT_GRAPHS = 0; 
% Number of repetition for sequentialfs
repetition_sequentialfs = 5;
% Number of features of the original dataset
HOW_MANY_FEATURES = 54;
% Number of features that I will select
FEATURES_TO_SELECT = 3; %8 standard; 3 fuzzy
% 0 if I do not want to save data (for testing)
% 1 if I want to save data
SAVE_DATA = 0;
SAVE_DATA_FUZZY = 1;
% If 1 the script will stop after data balancing without performing
% features selection
ONLY_BALANCING = 0;

% load data
dataset = load("data/biomedical_signals/dataset.mat");
dataset = table2array(dataset.dataset);

[howManyRow, ~] = size(dataset);

%% Removal of non numerical values

isInfinite = isinf(dataset);
% find() returns the rows and the columns of the elements equal to 1 in
% isInfinite, those elements are the ones that have infinite values in
% the dataset thus I have to remove the samples (row) that contains these
% values
[rinf, ~] = find(isInfinite==1);
dataset(rinf,:) = [];

%% Outliers removal
% The first two columns contains useless informations thus they can be
% deleted
dataset(:,1) = [];
dataset(:,1) = [];

% Remove outliers thanks to rmoutliers with the default method 'median'
[dataset_cleaned, ~] = rmoutliers(dataset);
[row_survived, ~] = size(dataset_cleaned);
[row_raw, ~] = size(dataset);
outliers_removed = row_raw - row_survived;
fprintf(" %i outliers have been removed, %i samples remain\n", outliers_removed, row_survived);

%% Dataset Balancing
% Let visualize the distribution for valence and arousal before the
% balancing

% Now we count the classes for valence and for arousal
howManySamplesForClass_arousal = groupcounts(dataset_cleaned(:,1));
howManySamplesForClass_valence = groupcounts(dataset_cleaned(:,2));

if PLOT_GRAPHS==1
    figure("Name", "Classes Distribution For Arousal Before Balancing");
    bar(howManySamplesForClass_arousal);
    title("Classes Distribution For Arousal Before Balancing");
end
[~, lowest_class_arousal] = min(howManySamplesForClass_arousal);
[~, majority_class_arousal] = max(howManySamplesForClass_arousal);

if PLOT_GRAPHS==1
    figure("Name", "Classes Distribution For Valence Before Balancing");
    bar(howManySamplesForClass_valence);
    title("Classes Distribution For Valence Before Balancing");
end
[~, lowest_class_valence] = min(howManySamplesForClass_valence);
[~, majority_class_valence] = max(howManySamplesForClass_valence);

augmentation_factors = [0 0];

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
%  1) I augment the samples that belong to the minority class of arousal 
% and don't belong to the majority class of valence; and the samples that 
% belong to the minority class of valence and don't belong to the majority
% class of arousal.
% 2) Then I remove the samples that belong to the majority class of 
% arousal and don't belong to the minority class of valence; and the
% samples that belong to the majority class of valence and don't belong to
% the minority class of arousal.
%
% I repeat this two steps rep (i.e. 80) times and for each repetition I
% compute the new majority and minority class both for arousal and valence
rep = 80;
row_to_check = row_survived;

for k = 1:rep
    for i = 1:row_to_check
        if (dataset_cleaned(i,1)==possible_values(lowest_class_arousal) && dataset_cleaned(i,2)~=possible_values(majority_class_valence)) || (dataset_cleaned(i,1)~=possible_values(majority_class_arousal) && dataset_cleaned(i,2)==possible_values(lowest_class_valence))
            fprintf(" %i) I am going to aumgent the following class valence:%f and arousal:%f\n",i, dataset_cleaned(i,2), dataset_cleaned(i,1));
            % Selection of i-th row
            row_original = dataset_cleaned(i,:);
            % Augmentation of the i-th row
            row_to_add = row_original;
            % Selection of the augmentation factor
            augmentation_factors(1) = 0.95+(0.04)*rand;
            augmentation_factors(2) = 1.01+(0.04)*rand;
            j = round(0.51+(1.98)*rand);
            % Augmentation
            row_to_add(3:end) = row_original(3:end).*augmentation_factors(j); 
            % Addition of the new sample, obtained through augmentation, to
            % the dataset
            dataset_cleaned = [dataset_cleaned; row_to_add];
        end
        
        if((dataset_cleaned(i,1)==possible_values(majority_class_arousal) && dataset_cleaned(i,2)~=possible_values(lowest_class_valence)) || (dataset_cleaned(i,2)==possible_values(majority_class_valence) && dataset_cleaned(i,1)~=possible_values(lowest_class_arousal)))
            dataset_cleaned(i,:)=[];
            fprintf(" I am removing the row %i\n",i);
        end
    end
    fprintf(" --- ITERATION %i ENDS ---\n",k);
    howManySamplesForClass_arousal = groupcounts(dataset_cleaned(:,1));
    howManySamplesForClass_valence = groupcounts(dataset_cleaned(:,2));

    [~, lowest_class_arousal] = min(howManySamplesForClass_arousal);
    [~, majority_class_arousal] = max(howManySamplesForClass_arousal);

    [~, lowest_class_valence] = min(howManySamplesForClass_valence);
    [~, majority_class_valence] = max(howManySamplesForClass_valence);
    
end

%% Plot of the histograms to check the balancing
if PLOT_GRAPHS==1
    howManySamplesForClass_arousal = groupcounts(dataset_cleaned(:,1));
    howManySamplesForClass_valence = groupcounts(dataset_cleaned(:,2));
    figure("Name", "Classes Distribution For Arousal After Balancing");
    bar(howManySamplesForClass_arousal);
    title("Classes Distribution For Arousal After Balancing");
    figure("Name", "Classes Distribution For Valence After Balancing");
    bar(howManySamplesForClass_valence);
    title("Classes Distribution For Valence After Balancing");
end

if ONLY_BALANCING == 1
    fprintf(" SCRIPT STOPPED - Only data balancing performed \n");
    return;
end

fprintf(" --- FEATURES SELECTION --- \n");
%% Cross Validation and feature selection

% Let divide output from input
features = dataset_cleaned(:,3:end);
target_arousal = dataset_cleaned(:,1);
target_valence = dataset_cleaned(:,2);

cv = cvpartition(target_arousal, 'Holdout', 0.3);
idxTrain = training(cv);
idxTest = test(cv);

x_train = features(idxTrain, :);
y_train_aro = target_arousal(idxTrain, :);
y_train_val = target_valence(idxTrain, :);

x_test = features(idxTest, :);
y_test_aro = target_arousal(idxTest, :);
y_test_val = target_valence(idxTest, :);


% Feature Selection For Valence
counter_feat_sel_valence = zeros(HOW_MANY_FEATURES,1)';
for i = 1:repetition_sequentialfs
    fprintf(" Sequentialfs for valence: repetion %i\n",i);
    c_valence = cvpartition(y_train_val, 'k', 10);
    opts = statset('Display', 'iter','UseParallel',true);
    [features_selected_for_valence, history] = sequentialfs(@myfun, x_train, y_train_val, 'cv', c_valence, 'opt', opts, 'nfeatures', FEATURES_TO_SELECT);
    
    for j = 1:HOW_MANY_FEATURES
        if features_selected_for_valence(j) == 1
            counter_feat_sel_valence(j) = counter_feat_sel_valence(j) + 1;
        end
    end

end

f_sel_valence = zeros(FEATURES_TO_SELECT, 1)';
for i = 1:FEATURES_TO_SELECT
    % I find the maximum
    [~, f_sel_valence(i)] = max(counter_feat_sel_valence);
    fprintf(" Il max %f ?? in posizione (features) %i", counter_feat_sel_valence(f_sel_valence(i)), f_sel_valence(i)); 
    % I set the maximum to zero, thus at the next iteration the second
    % maximum value will be selected
    counter_feat_sel_valence(f_sel_valence(i)) = 0;
end

fprintf(" Features Selected For Valence:");
disp(f_sel_valence);


% Features Selection For Arousal
counter_feat_sel_arousal = zeros(HOW_MANY_FEATURES,1)';
for i = 1:repetition_sequentialfs
    fprintf(" Sequentialfs for arousal: repetion %i\n",i);
    c_arousal = cvpartition(y_train_aro, 'k', 10);
    opts = statset('Display', 'iter','UseParallel',true);
    [features_selected_for_arousal, history] = sequentialfs(@myfun, x_train, y_train_aro, 'cv', c_arousal, 'opt', opts, 'nfeatures', FEATURES_TO_SELECT);
    
    for j = 1:HOW_MANY_FEATURES
        if features_selected_for_arousal(j) == 1
            counter_feat_sel_arousal(j) = counter_feat_sel_arousal(j) + 1;
        end
    end

end

f_sel_arousal = zeros(FEATURES_TO_SELECT, 1)';
for i = 1:FEATURES_TO_SELECT
    % I find the maximum
    [~,f_sel_arousal(i)] = max(counter_feat_sel_arousal);
    fprintf(" Il max %f ?? in posizione (features) %i", counter_feat_sel_arousal(f_sel_arousal(i)), f_sel_arousal(i)); 
    % I set the maximum to zero, thus at the next iteration the second
    % maximum value will be selected
    counter_feat_sel_arousal(f_sel_arousal(i)) = 0;
end

fprintf(" Features Selected For Arousal");
disp(f_sel_arousal);


%% Save the obtained data to file
if SAVE_DATA == 1
    save('data/biomedical_signals/dataset_cleaned.mat','dataset_cleaned');

    % struct for training data
    training_data_arousal.x_train_arousal = x_train(:,f_sel_arousal);
    training_data_valence.x_train_valence = x_train(:,f_sel_valence);
    training_data_arousal.y_train_arousal = y_train_aro;
    training_data_valence.y_train_valence = y_train_val;
    save('data/biomedical_signals/training_data_arousal.mat', 'training_data_arousal');
    save('data/biomedical_signals/training_data_valence.mat', 'training_data_valence');

    % struct for test data
    test_data_arousal.x_test_arousal = x_test(:,f_sel_arousal);
    test_data_valence.x_test_valence = x_test(:,f_sel_valence);
    test_data_arousal.y_test_arousal = y_test_aro;
    test_data_valence.y_test_valence = y_test_val;
    save('data/biomedical_signals/test_data_arousal.mat', 'test_data_arousal');
    save('data/biomedical_signals/test_data_valence.mat', 'test_data_valence');
    
    disp(" DATA SAVED ");
end

if SAVE_DATA_FUZZY == 1
    % struct for training data
    fuzzyData.x_train_arousal = x_train(:,f_sel_arousal);
    fuzzyData.y_train_arousal = y_train_aro;
    fuzzyData.x_test_arousal = x_test(:,f_sel_arousal);
    fuzzyData.y_test_arousal = y_test_aro;
    fuzzyData.best_features = f_sel_arousal;
    fuzzyData.y_values = possible_values;
    save('data/biomedical_signals/fuzzyData.mat', 'fuzzyData');
    
    disp(" DATA FUZZY SAVED ");
end

%% Custom function for sequentialfs
function mse = myfun(xTrain, yTrain, xTest, yTest)
    % create network
    hiddenLayerSize = 40;
    net = fitnet(hiddenLayerSize);
    xx = xTrain';
    tt = yTrain';
    % train network
    [net, ~] = train(net, xx, tt);
    % test network
    y = net(xx);
    mse = perform(net, tt, y);
end
