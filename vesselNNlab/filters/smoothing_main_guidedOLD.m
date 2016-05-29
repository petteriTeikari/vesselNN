function imS = smoothing_main(im, edges, opts)

    % save tempS.mat
    load tempS.mat
        
    %% VESSELNESS
    
        is3D = false;
        radii = 1:2;            
        OOF_2D = vesselness_OOF_wrapper(im, radii, opts, is3D);   
        
        is3D = true;
        radii = 2:4;            
        OOF_3D = vesselness_OOF_wrapper(im, radii, opts, is3D);
        
        % fusion
        OOF_2D = OOF_2D / max(OOF_2D(:));
        OOF = OOF_2D + OOF_3D;
        imF = im + OOF;
        imF = imF - min(imF(:));
        imF = imF / max(imF(:));
        
    %% Edges
    
        edgesOOF = vesselness_structuredEdgesWrapper(imF, opts);        
        edgesOOF = edgesOOF + edges_1;
        
    %% VISUALIZE
    
        rows = 2; cols = 3;
        sliceOfInterest = 2;
    
        
        i = 0;
        i = i + 1; sp(i) = subplot(rows,cols,i); imshow(im(:,:,sliceOfInterest), []); title('Input'); colorbar  
        
        i = i + 1; sp(i) = subplot(rows,cols,i); imshow(OOF_2D(:,:,sliceOfInterest), []); title('OOF 2D'); colorbar            
        i = i + 1; sp(i) = subplot(rows,cols,i); imshow(OOF_3D(:,:,sliceOfInterest), []); title('OOF 3D'); colorbar            
        i = i + 1; sp(i) = subplot(rows,cols,i); imshow(OOF(:,:,sliceOfInterest), []); title('OOF'); colorbar            
        
        
        i = i + 1; sp(i) = subplot(rows,cols,i); imshow(imF(:,:,sliceOfInterest), []); title('imF'); colorbar            
        i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edgesOOF(:,:,sliceOfInterest), []); title('edgesOOF'); colorbar            

        
