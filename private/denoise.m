function Nii = denoise(Nii,Verbose)
if nargin < 2, Verbose  = 0;     end

fprintf('Denoising...')
N = numel(Nii{1});
for n=1:N        
    do_denoise(Nii{1}(n).dat.fname,Verbose);
    
    f             = Nii{1}(n).dat.fname;
    [pth,nam,ext] = fileparts(f);
    nf            = fullfile(pth,['y' nam ext]);
    
    delete(f);
    Nii{1}(n) = nifti(nf);
end
fprintf('done!\n')
%==========================================================================

%==========================================================================
function do_denoise(P,Verbose)
% RegScaleDenoisingMRI = 4;
% CoRegister           = false;    
% WorkersParfor        = 0;
% 
% fun_args = {'InputImages',Nii, ...
%             'Verbose',Verbose, ...
%             'RegScaleDenoisingMRI',RegScaleDenoisingMRI, ...
%             'CoRegister',CoRegister, ...
%             'WorkersParfor',WorkersParfor};
            
opt.Denoise = true;
opt.DoCoReg = false;

spm_superres({P},opt);
%==========================================================================