function x = pad_signal(x,N1,boundary,half_sample)
	if nargin < 3 || isempty(boundary)
		boundary = 'symm';
	end
	
	if nargin < 4 || isempty(half_sample)
		half_sample = 1;
	end
		
	
	for d = 1:length(N1)
		N0 = size(x,d);
	
		if strcmp(boundary,'symm')
			if half_sample
				ind0 = [1:N0 N0:-1:1];
			else
				ind0 = [1:N0 N0-1:-1:2];
			end
		elseif strcmp(boundary,'per')
			ind0 = [1:N0];
		elseif strcmp(boundary,'zero')
			ind0 = [1:N0];				% UNUSED FOR NOW
		else
			error('Invalid boundary conditions!');
		end
	
		if ~strcmp(boundary,'zero')
			ind = zeros(1,N1(d));
			ind(1:N0) = 1:N0;
			ind(N0+1:N0+floor((N1(d)-N0)/2)) = ...
				ind0(mod([N0+1:N0+floor((N1(d)-N0)/2)]-1,length(ind0))+1);
			ind(N1(d):-1:N0+floor((N1(d)-N0)/2)+1) = ...
				ind0(mod(length(ind0)-[1:ceil((N1(d)-N0)/2)],length(ind0))+1);
		else
			ind = 1:N0;
		end
	
		%x = shiftdim(x,d-1);
		%sz = size(x);
		%x = reshape(x,[sz(1) prod(sz(2:end))]);
		%x = x(ind,:);
		%x = reshape(x,[length(ind) sz(2:end)]);
		%x = shiftdim(x,dims-d+1);
		
		% MATLAB is stupid; easier to do manually
		if d == 1
			x = x(ind,:,:);
			if strcmp(boundary,'zero')
				x(N0+1:N1,:,:) = 0;
			end
		elseif d == 2
			x = x(:,ind,:);
			if strcmp(boundary,'zero')
				x(:,N0+1:N1,:) = 0;
			end
		end
	end
end