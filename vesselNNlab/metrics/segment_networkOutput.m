function segmentation = segment_networkOutput(im, outMask, fileOut, mask_folder, param_segment)         

    if nargin == 0
        load('/home/petteri/Desktop/temp.mat')
    else
        % save('/home/petteri/Desktop/temp.mat')
    end

    whos
    slice = 12;
    debugVisualize = false;
    
    
    
    %% Weigh the input with the 
    imW = im .* outMask;
    
        % Visualize
        if debugVisualize
            
            rows = 2; cols = 3;

            i = 0;

            logOffset = 0.1;
            i=i+1; subplot(rows,cols,i); imshow(im(:,:,slice), []); colorbar
            i=i+1; subplot(rows,cols,i); imshow(log10(im(:,:,slice) + logOffset), []); colorbar    
            i=i+1; subplot(rows,cols,i); imshow(outMask(:,:,slice), []); colorbar

            i=i+1; subplot(rows,cols,i); imshow(imW(:,:,slice), []); colorbar
            i=i+1; subplot(rows,cols,i); imshow(log10(imW(:,:,slice) + logOffset), []); colorbar
            i=i+1; subplot(rows,cols,i); imshow(imW(:,:,slice) - im(:,:,slice), []); colorbar
            
        end
        
        
    %% Dense CRF interference, 2D slice-by-slice approach
        
        whos
        outMask_8bit = uint8(outMask);
        
        %% SKIPPiNG NOW THIS (Petteri, 29 March 2016)
        %CRFmaskMatrix = outMask_8bit;  
        
        CRFmaskMatrix = segment_CRF_wrapper(imW, outMask_8bit, 'inference');      
        
        
        if debugVisualize

            rows = 2; cols = 2;
            i = 0;

            i=i+1; subplot(rows,cols,i); imshow(imW(:,:,slice), []); title('Weighed'); colorbar
            i=i+1; subplot(rows,cols,i); imshow(outMask(:,:,slice), []); title('Out');  colorbar
            i=i+1; subplot(rows,cols,i); imshow(outMask_8bit(:,:,slice), []); title('uint8(Out)');  colorbar
            i=i+1; subplot(rows,cols,i); imshow(CRFmaskMatrix(:,:,slice), []); title('Final Mask');  colorbar
            
        end
        
        noOfMethod = 1;
        segmentation{noOfMethod}.name = 'DenseCRF_2D';
        segmentation{noOfMethod}.labelStack = CRFmaskMatrix;
        
        % export the segmentations
        fileOut = strrep(fileOut, 'weighed', ['mask_', segmentation{noOfMethod}.name]);
        export_stack_toDisk(fullfile(mask_folder, fileOut), segmentation{noOfMethod}.labelStack, 8);
        
        segmentation{noOfMethod}.fileName = fileOut;
        segmentation{noOfMethod}.fullPath = fullfile(mask_folder, fileOut);

    %% Dummy
        
        % binarize
        for i = 1 : size(imW,3)
            level(i) = graythresh(imW(:,:,i)); % get automatic threshold
            vesselMask(:,:,i) = im2bw(imW(:,:,i), level(i)); 
        end
        
        noOfMethod = noOfMethod + 1;
        segmentation{noOfMethod}.name = 'Thresholding';
        segmentation{noOfMethod}.labelStack = vesselMask;
    
        % export the segmentations
        fileOut = strrep(fileOut, segmentation{noOfMethod-1}.name, segmentation{noOfMethod}.name);
        export_stack_toDisk(fullfile(mask_folder, fileOut), segmentation{noOfMethod}.labelStack, 8);
        
        segmentation{noOfMethod}.fileName = fileOut;
        segmentation{noOfMethod}.fullPath = fullfile(mask_folder, fileOut);
        