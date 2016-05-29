function segment_thresholding()

    %% Thresholding
    
        % L0 Smoothing
        kappa = 2; 
        lambdaS = 5e-05;
        
        disp('LO Smoothing')
        imS = L0Smoothing_stack(imW, lambdaS, kappa);
    
        %%
        
        disp('Local Normalization')
        sigma1 = 12;
        sigma2 = 12;
        for i = 1 : size(imW,3)            
            im_lnfim(:,:,i) = localnormalize(imS(:,:,i),sigma1, sigma2);
            im_lnfim(:,:,i) = mat2gray(im_lnfim(:,:,i));
        end
        
        % smooth again
        
            kappa = 2; 
            lambdaS = 5e-05;

            disp('LO Smoothing')
            imS2 = L0Smoothing_stack(im_lnfim, lambdaS, kappa);
        
        
        % binarize
        for i = 1 : size(imW,3)
            
             % get automatic threshold
            level(i) = graythresh(imS2(:,:,i));
            vesselMask(:,:,i) = im2bw(imS2(:,:,i), level(i));              
            
        end
        
        slice = 12;
        % Visualize
        if debugVisualize
            
            rows = 2; cols = 3;
            i = 0;

            i=i+1; subplot(rows,cols,i); imshow(imW(:,:,slice), []); colorbar; title('Weighed')
            i=i+1; subplot(rows,cols,i); imshow(imS(:,:,slice), []); colorbar; title('L0 Smoothed')
            i=i+1; subplot(rows,cols,i); imshow(im_lnfim(:,:,slice), []); colorbar; title('Local Normalization')
            i=i+1; subplot(rows,cols,i); imshow(imS2(:,:,slice), []); colorbar; title('Local Normalization Smooth')
            i=i+1; subplot(rows,cols,i); imshow(vesselMask(:,:,slice), []); colorbar; title('Binary Mask')
            

        end