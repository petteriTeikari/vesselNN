function [featureScaled, featureSigned] = handcraftVesselFeature_SE(im, param, fileNameOut, outputFolder)

        if nargin == 0
            
            pathImage = '/home/petteri/znnData/dataset/vessel_2PM/denoised'; 
            fileName = 'poon2015_mixedSize1_BM4D_denoised.tif';
            [~, imageStack, ~, ~] = importMicroscopyFile(fileName, pathImage);
            im = single(imageStack{1}{1});
            im = im(:,:,5:14);
            im = im / max(im(:));
            param.visualizeOn = true;                               
            param.is3D = false;
            param.saveToDisk = false;
            
            outputFolder = '/home/petteri/znnData/dataset/vessel_2PM/handCraftedFeatures';
            fileNameOut = fileName;
            
        end

        % get the current path (where this .m file is), and cd to that
        fileName = mfilename; fullPath = mfilename('fullpath');
        pathCode = strrep(fullPath, fileName, '');
        if ~isempty(pathCode); cd(pathCode); end
        
        % get screen size for plotting
        scrsz = get(0,'ScreenSize'); 
                
    %% Edges
    
        opts.suppressFaintEdges = true; % maybe improve this at some point
        edges = vesselness_structuredEdgesWrapper(im, opts);
        
    %% Weigh with input
    
        % this step suppresses a bit more the background noise
        edgesW = edges .* im;
        
    %% L0 Smoothing
    
        % this STEP should be trained!
        % See Deep Edge-Aware Filters
        % Xu et al. (2015), http://jmlr.org/proceedings/papers/v37/xub15.pdf
        kappa = 2; 
        lambdaS = 1e-06; % conservative value
        edges_S = L0Smoothing_stack(edgesW, lambdaS, kappa);
        
    %% CLAHE
    
        for slice = 1 : size(edges_S,3)
            imCLAHE(:,:,slice) = adapthisteq(edges_S(:,:,slice),...
                'clipLimit',0.0001,'Distribution','rayleigh');  
        end
    
    
    %% Locally Normalized
    
        % See Fig 3 of Almasi et al. (2015)
        % http://dx.doi.org/10.1016/j.media.2014.11.007
        % code: http://www.mathworks.com/matlabcentral/fileexchange/8303-local-normalization
        for i = 1 : size(edges_S,3)
            lnEdges(:,:,i) = localnormalize(edges_S(:,:,i), 4, 4);
            
            level(i) = graythresh(lnEdges(:,:,i));
            lnEdges_bw(:,:,i) = im2bw(lnEdges(:,:,i), level(i));
        end

        
        
    %% Scaling for OUTPUT
    
        feature_2D = edges_S;
    
        % Scale to 8-bit
        %{
        disp('Scale to 8-bit range')
        limits = [min(feature_2D(:)) max(feature_2D(:))];
        absLimits = abs(limits)
        maxOfLimits = max(absLimits)
        featureSigned = feature_2D / maxOfLimits;
        
        % make sure that zero is now at 127, and values are
        % symmetrically on each side. Typically positive values are
        % larger so the highest value get 255 but the lowest value is
        % probably larger than 0        
        
        % ZNN symmetrically scales this then so the zero is nice to be in
        % the middle? (confirm still actually this)
        featureScaled = featureSigned + 1; % 0 -> 1
        featureScaled = floor(featureScaled * (255/2)); % 1 -> 127 
        limitsScaled = [min(featureScaled(:)) max(featureScaled(:))]
        
        % have to normalize after all (don't normalize if you are okay with
        % the [0, 255] range
        featureScaled = featureScaled / max(featureScaled(:));     
        %}
        
        featureScaled = feature_2D / max(feature_2D(:));
        featureSigned = featureScaled;
    
     %% export the stack to disk
     
        if param.saveToDisk
     
            if isempty(fileNameOut)
                
            end
            
            if isempty(outputFolder)
                
            end
            
            if param.is3D
                fileNameOut = fullfile(outputFolder, strrep(fileNameOut, '_BM4D_denoised.tif', '_handCraftFeature.tif'));
            else
                fileNameOut = fullfile(outputFolder, strrep(fileNameOut, '_BM4D_denoised.tif', '_handCraftFeature_2D.tif'));
            end

            export_stack_toDisk(fileNameOut, featureScaled, 8)
            
        end
        
        
    %% VISUALIZE
    
        if param.visualizeOn
    
            fig1 = figure;
            
            sliceOfInterest = 3;
            
            rows = 3; cols = 3;

            i = 0;
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(im(:,:,sliceOfInterest), []); title('Input'); colorbar                       
            
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edges(:,:,sliceOfInterest), []); title('Edges'); colorbar                        
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edgesW(:,:,sliceOfInterest), []); title('Edges W'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edges_S(:,:,sliceOfInterest), []); title('Edges L0'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edgesW(:,:,sliceOfInterest) - edges_S(:,:,sliceOfInterest), []); title('L0 Noise removed'); colorbar
            
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(lnEdges(:,:,sliceOfInterest), []); title('Locally Normalized Edges'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(lnEdges_bw(:,:,sliceOfInterest), []); title('Locally Normalized Edges BIN'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(imCLAHE(:,:,sliceOfInterest), []); title('CLAHE Edges'); colorbar
            
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(featureScaled(:,:,sliceOfInterest), []); title('Features'); colorbar
                        
        end