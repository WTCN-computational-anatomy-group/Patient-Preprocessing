function [Nii,M] = reslice2template(Nii,M,pth_template)
fprintf('Reslicing to template...')
Vr           = spm_vol(pth_template);
flags        = struct;
flags.params = [0 0 0 0 0 0 1 1 1 0 0 0];
N            = numel(Nii{1});
R            = cell(1,N);
for n=1:N
    f  = Nii{1}(n).dat.fname;
    Vn = spm_vol(f);    
    x  = spm_coreg(Vr,Vn,flags);
    
    Rn   = spm_matrix(x(:)');
    Mn   = Vn.mat\Rn*Vr.mat;
    R{n} = Rn;
    M{n} = M{n}*R{n};
    
    y = Affine(Vr.dim,Mn);
    
    intrp = [4 4 4 0 0 0];
    im    = single(Nii{1}(n).dat());
    mn    = min(im(:));
    mx    = max(im(:));
    c     = spm_diffeo('bsplinc',im,intrp);
    im    = spm_diffeo('bsplins',c,y,intrp);
    im    = min(mx, max(mn, im));
    
    [pth,nam,ext] = fileparts(f);
    npth          = fullfile(pth,['rt' nam ext]);
    create_nii(npth,im,Vr.mat,'float32','resliced',...
               Nii{1}(n).dat.offset,Nii{1}(n).dat.scl_slope,Nii{1}(n).dat.scl_inter);    
    
    Nii{1}(n) = nifti(npth);
    delete(f);
    
    if do_affinereg
        npth = fullfile(pth,['R_' nam '.mat']);
        save(npth,'Rn');
    end
end

if numel(Nii) > 1
    % Keep labels in alignment
    for n=1:N
        if isempty(Nii{2}(n).dat), continue; end
        
        f         = Nii{2}(n).dat.fname;
        mat0      = Nii{2}(n).mat;
        spm_get_space(f,R{n}\mat0); 
        Nii{2}(n) = nifti(f); 
    end    
end
fprintf('done!\n')
%=================================================================

%==========================================================================
% Affine()
function psi0 = Affine(d,Mat)
id    = Identity(d);
psi0  = reshape(reshape(id,[prod(d) 3])*Mat(1:3,1:3)' + Mat(1:3,4)',[d 3]);
if d(3) == 1, psi0(:,:,:,3) = 1; end
%==========================================================================

%==========================================================================
% Identity()
function id = Identity(d)
id = zeros([d(:)',3],'single');
[id(:,:,:,1),id(:,:,:,2),id(:,:,:,3)] = ndgrid(single(1:d(1)),single(1:d(2)),single(1:d(3)));
%==========================================================================