function P = write_2d(Nii,dir_out2d,deg,axis_2d)
if nargin < 3, deg      = 0;    end
if nargin < 4, axis_2d  = 3;    end

fprintf('Writing 2D...')
N = numel(Nii{1});
for n=1:N
    f           = Nii{1}(n).dat.fname;     
    [~,nam,ext] = fileparts(f);
    nf          = fullfile(dir_out2d,['2d' nam ext]);
    do_write(f,nf,deg,axis_2d);    
    Nii{1}(n)   = nifti(nf);
end

if numel(Nii) > 1
    % Labels too
    for n=1:N
        if isempty(Nii{2}(n).dat), continue; end
        
        f           = Nii{2}(n).dat.fname;  
        [~,nam,ext] = fileparts(f);
        nf          = fullfile(dir_out2d,['2d' nam ext]);
        do_write(f,nf,deg,axis_2d);    
        Nii{2}(n)   = nifti(nf);
    end    
end

P    = cell(1,2);
P{1} = cell(1,N);
P{2} = cell(1,N);
for i=1:2
    for n=1:N
        if (i == 2 && numel(Nii) == 1) || isempty(Nii{i}(n).dat), continue; end
        
        P{i}{n} = Nii{i}(n).dat.fname;        
    end
end

fprintf('done!\n')
%==========================================================================

%==========================================================================
function do_write(fname,ofname,deg,axis_2d)
if nargin < 3, deg      = 0; end
if nargin < 4, axis_2d  = 3; end

% Create bounding box
V  = spm_vol(fname);
dm = V.dim;
if axis_2d     == 1
    d1 = floor(dm(1)/2) + 1;
    bb = [d1 d1;-inf inf;-inf inf];   
elseif axis_2d == 2
    d1 = floor(dm(2)/2) + 1;
    bb = [-inf inf;d1 d1;-inf inf];
elseif axis_2d == 3 
    d1 = floor(dm(3)/2) + 1;
    bb = [-inf inf;-inf inf;d1 d1];
end                

% Crop according to bounding-box
subvol(V,bb',ofname,deg);      

if axis_2d == 1 || axis_2d == 2
    % Make sure 1D plane is in z dimension
    Nii  = nifti(ofname);
    mat  = Nii.mat;
    
    % Permute image data and apply permutation matrix to orientation matrix
    if axis_2d == 1
        img = permute(Nii.dat(:,:,:),[2 3 1]);            
        P   = [0 1 0 0; 0 0 1 0; 1 0 0 0; 0 0 0 1];
    else
        img = permute(Nii.dat(:,:,:),[1 3 2]);        
        P   = [1 0 0 0; 0 0 1 0; 0 1 0 0; 0 0 0 1];
    end   
    mat     = P*mat*P';
    dm      = [size(img) 1];
    
    % Overwrite image data
    VO             = spm_vol(ofname);
    VO.dim(1:3)    = dm(1:3);        
    VO.mat         = mat;
    VO             = spm_create_vol(VO);        
    Nii            = nifti(VO.fname);    
    Nii.dat(:,:,:) = img; 
end
%==========================================================================