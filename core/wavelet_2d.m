% WAVELET_2D Compute the wavelet transform of a signal x
%
% Usage
%    [x_phi, x_psi] = WAVELET_2D(x, filters, options)
%
% Input
%    x (numeric): the input signal
%    filters (cell): cell containing the filters
%    options (structure): options of the wavelet transform
%
% Output
%    x_phi (cell): Low pass part of the wavelet transform
%    x_psi (cell): Wavelet coeffcients of the wavelet transform
%
% Description
%    WAVELET_2D computes a wavelet transform, using the signal and the
%    filters in the Fourier domain. The signal is padded in order to avoid
%    border effects.
%
%    The meta information concerning the signal x_phi, x_psi(scale, angle,
%    resolution) can be found in meta_phi and meta_psi.
%
% See also
%   WAVELET_2D, CONV_SUB_2D, WAVELET_FACTORY_2D_PYRAMID

function [x_phi, x_psi, meta_phi, meta_psi] = wavelet_2d(x, filters, options)
    % Options
    if(nargin<3)
        options = struct;
    end
    white_list = {'x_resolution', 'precision', 'psi_mask','oversampling'};
    check_options_white_list(options, white_list);
    options = fill_struct(options, 'x_resolution',0);
    options = fill_struct(options, 'precision','single');
    options = fill_struct(options, 'oversampling',1);
    options = fill_struct(options, 'psi_mask', ...
        ones(1,numel(filters.psi.filter)));
    
    precision = options.precision;
    oversampling = options.oversampling;
    psi_mask = options.psi_mask;
    
    % Padding and Fourier transform
    sz_paded = filters.phi.filter.N;
    xf = fft2(pad_signal(x, sz_paded, [], 0));
    
    % Low-pass filtering, downsampling and unpadding
    lastres = options.x_resolution;
    Q = filters.meta.Q;
    J = filters.phi.meta.J;
    ds = max(floor(J/Q)- lastres - oversampling, 0);
    x_phi = real(conv_sub_2d(xf, filters.phi.filter, ds));
    x_phi = unpad_signal(x_phi, ds*[1 1], size(x));
    
    meta_phi.j = -1;
    meta_phi.theta = -1;
    meta_phi.resolution = lastres+ds;
    
    % Band-pass filtering, downsampling and unpadding
    x_psi={};
    for p = find(psi_mask)
        j = filters.psi.meta.j(p);
        ds = max(floor(j/Q)- lastres - oversampling, 0);
        x_psi{p} = conv_sub_2d(xf, filters.psi.filter{p}, ds);
        x_psi{p} = unpad_signal(x_psi{p}, ds*[1 1], size(x));
        meta_psi.j(1,p) = filters.psi.meta.j(p);
        meta_psi.theta(1,p) = filters.psi.meta.theta(p);
        meta_psi.resolution(1,p) = lastres+ds;
    end
    meta_psi.j = -1*ones(1, numel(filters.psi.filter));
    meta_psi.theta = -1*ones(1, numel(filters.psi.filter));
    meta_psi.resolution = -1*ones(1, numel(filters.psi.filter));
    
    % Conversion to single precision if required
    if(strcmp(precision,'single'))
        x_phi = single(x_phi);
        x_psi = cellfun(@single, x_psi, 'UniformOutput', 0);
    end
end