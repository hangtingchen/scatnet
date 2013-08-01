%% spatial
src = uiuc_src;
options.J = 6;
options.M = 2;



options.parallel = 0;
w = wavelet_factory_3d_spatial(options, options, options);
features{1} = @(x)(sum(sum(format_scat(scat(x,w)),2),3));
%features{1} = @(x)(sum(sum(format_scat(renorm_scat_spatial(scat(x,w))),2),3));
db = prepare_database(src, features, options);


%% classif with 200 randomn partition and size 5 10 20
grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
		model = affine_train(db, train_set, train_opt);
		labels = affine_test(db, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
% morlet
%  0.5278    0.6775    0.8379
% haar
%  0.6904    0.8497    0.9264
% haar + renorm
%  0.4887    0.5037    0.2456
% haar J=6
%  0.7187    0.8540    0.9252
% haar M=3
%  0.7174    0.8548    0.9442
% 3d buggy
%  0.6819    0.8609    0.9206
% 3d+log buggy
%  0.8099    0.9245    0.9800
% 3d 
%  0.6679    0.8660    0.9292
% 3d+log
%  0.8752    0.9564    0.9892

% 3d J=6
%  0.6937    0.8689    0.9526
% 3d J=6+log
%  0.8874    0.9607    0.9874
%%
db2 = db;
db2.features = log(db.features);
grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
		model = affine_train(db2, train_set, train_opt);
		labels = affine_test(db2, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end