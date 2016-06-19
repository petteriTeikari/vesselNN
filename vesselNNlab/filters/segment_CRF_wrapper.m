function CRFmask = segment_CRF_wrapper(crfPath, pathImage, im, mask, twoDim)

    if nargin == 4
        twoDim = false;
    end
    
    CRFmask = zeros(size(im)); 
    for slice = 1 : size(im, 3)
        
        % if this a flat 2D image (greyscale)
        if twoDim
            imSlice = im;            
            maskSlice = cat(3, mask, mask, mask);
            disp('2D Image')
        else
            imSlice = im(:,:,slice);
            maskSlice = mask(:,:,slice);
            disp('Volumetric, slice-by-slice')
        end
        
        % save as .ppm
        imwrite(imSlice, fullfile(pathImage, 'im.ppm'))        
        %imwrite(maskSlice, jet(2), fullfile(pathImage, 'mask.ppm'))
        write_ppm(maskSlice, fullfile(pathImage, 'mask.ppm'), 255);
        
        % densecrf inference call
        % For example:
        % build/examples/dense_inference examples/im1.ppm examples/anno1.ppm output1.ppm
        functionCall = fullfile(crfPath, 'dense_inference');
        input = fullfile(pathImage, 'im.ppm');
        inputMask = fullfile(pathImage, 'mask.ppm');
        output = fullfile(pathImage, 'mask_densecrf.ppm');

            % construct the final call
            commandCall = [functionCall, ' ', input, ' ' inputMask, ' ' output];
            [status, cmdOut] = system(commandCall)
            
            if ~isempty(strfind(cmdOut, 'No such file or directory'))
                warning('Problem with densecrf, not built yet?')
            elseif ~isempty(strfind(cmdOut, 'Permission denied'))
                warning('Permission problem! Do "sudo chmod 757 dense_inference"')
            end

        % read the resulting .ppm
        CRFmaskSlice = imread(fullfile(pathImage, 'mask_densecrf.ppm'));
        CRFmaskSlice = im2bw(CRFmaskSlice);
        
        if twoDim
            CRFmask = uint8(CRFmaskSlice);
        else
            CRFmask(:,:,slice) = uint8(CRFmaskSlice);
        end
            
    end
    
    
% https://fengl.org/2014/08/15/save-image-into-ppm-ascii-format-in-matlab/
function write_ppm(im, fname, xval)
 
    [height, width, c] = size(im);
    assert(c == 3);

    fid = fopen( fname, 'w' );

    %% write headers
    fprintf( fid, 'P3\n' );
    fprintf( fid, '%d %d\n', width, height);
    fprintf( fid, '%d \n', xval); %maximum values

    fclose( fid ); 

    %% interleave image channels before streaming
    c1 = im(:, :, 1)';
    c2 = im(:, :, 2)';
    c3 = im(:, :, 3)';
    im1 = cat(2, c1(:), c2(:), c3(:));

    %% data streaming, could be slow if the image is large
    dlmwrite(fname, int32(im1), '-append', 'delimiter', '\n')
    
