function handcraftVesselFeature_znnOld(im, znn, param, fileNameOut, outputFolder)

        if nargin == 0

            pathImage = '/home/petteri/znnData/dataset/vessel_2PM/denoised'; 
            fileName = 'santos2015_lowContrastVessels.tif';
            [~, imageStack, ~, ~] = importMicroscopyFile(fileName, pathImage);
            im = single(imageStack{1}{1});
            im = im / 255;
            param.visualizeOn = true;                    
           
            param.is3D = false;
            
            outputFolder = '/home/petteri/znnData/dataset/vessel_2PM/handCraftedFeatures';
            fileNameOut = fileName;
        end

        % get the current path (where this .m file is), and cd to that
        fileName = mfilename; fullPath = mfilename('fullpath');
        pathCode = strrep(fullPath, fileName, '');
        if ~isempty(pathCode); cd(pathCode); end
        
        % get screen size for plotting
        scrsz = get(0,'ScreenSize'); 
        
        whos
        
    %% ZNN-weighed edge detection
    
        opts = [];
        radii = 1:4;
        
        [edgesFusion, edgesStr, OOF_2D, OOF_3D, MDOF_3D] = ...
                                vesselness_combinedEdges(im, radii, opts);
                            
    %% Refine the ZNN mask with dense CRF
    
        cd(pathCode)
        crfPath  = fullfile('..', '3rdParty', 'densecrf', 'build', 'examples');
        imEdgesCRF = im + edgesStr;
        imEdgesCRF(imEdgesCRF > 1) = 1;
        [imDisk, mask_densecrf, znn_new] = segment_refineMaskwithDenseCRF(imEdgesCRF, znn, crfPath);
    
        % Weigh    
        whos
        imW = im .* znn_new;
        imW_edges1 = imW + edgesFusion;
        imW_edges1(imW_edges1 > 1) = 1;
        
    %% ITERATE EDGES ONE MORE
    
        opts.doNotUseStrEdges = 1;
        radii = 1:2;
        [edgesFusion2, edgesStr, OOF_2D, OOF_3D, MDOF_3D] = ...
                                vesselness_combinedEdges(imW, radii, opts, znn);
        
        
    %% WEIGHING
    
        imW_edges2 = imW + edgesFusion2;
        imW_edges2(imW_edges2 > 1) = 1;
        
        imW_edges3 = imW_edges1 + imW_edges2;
        imW_edges3(imW_edges3 > 1) = 1;
        
        im2 = im .* imW_edges2;
        im3 = im .* imW_edges3;
        
    %% VISUALIZE
    
        if param.visualizeOn
    
            fig = figure('Color','w','Name', 'Final CRF-Refined MASK');        
                set(fig,  'Position', [0.05*scrsz(3) 0.01*scrsz(4) 0.90*scrsz(3) 0.850*scrsz(4)])

            rows = 3; cols = 4;       
            sliceOfInterest = 8;

            i = 0;            
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(im(:,:,sliceOfInterest), []); title('Denoised'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(znn(:,:,sliceOfInterest), []); title('before Densecrf'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edgesFusion(:,:,sliceOfInterest), []); title('edgesFusion"'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(znn_new(:,:,sliceOfInterest), []); title('after Densecrf'); colorbar

            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(imW(:,:,sliceOfInterest), []); title('after Densecrf | imW"'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edgesFusion(:,:,sliceOfInterest), []); title('edgesFusion2"'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(imW_edges1(:,:,sliceOfInterest), []); title('imW edges1'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(imW_edges2(:,:,sliceOfInterest), []); title('imW edges2'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(imW_edges3(:,:,sliceOfInterest), []); title('imW edges3'); colorbar

            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(log10(im2(:,:,sliceOfInterest) + 0.001), []); title('log10(im2)'); colorbar
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(log10(im3(:,:,sliceOfInterest) + 0.001), []); title('log10(im3)'); colorbar
            drawnow
            
        end
        
    %% OOF2 once more
        
        radii = 2;
        opts = [];
        is3D = false;
        OOF_2D = vesselness_OOF_wrapper(imW_edges2, radii, opts, is3D);
        OOF_2D = OOF_2D / max(OOF_2D(:));
        
        feature_2D = imW_edges2 + OOF_2D;
        feature_2D(feature_2D > 1) = 1;
    
        if param.visualizeOn
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(feature_2D(:,:,sliceOfInterest), []); title('log10(im3)'); colorbar
            drawnow
        end
        
    %% OUTPUT FINALLY
            
        
    
        % Scale to 8-bit
        disp('Scale to 8-bit range')
        limits = [min(feature_2D(:)) max(feature_2D(:))];
        absLimits = abs(limits)
        maxOfLimits = max(absLimits)

        % make sure that zero is now at 127, and values are
        % symmetrically on each side. Typically positive values are
        % larger so the highest value get 255 but the lowest value is
        % probably larger than 0
        feature_2D = feature_2D / maxOfLimits;
        feature_2D = feature_2D + 1; % 0 -> 1
        feature_2D = floor(feature_2D * (255/2)); % 1 -> 127 
        limitsScaled = [min(feature_2D(:)) max(feature_2D(:))]
        feature_2D_8bit = feature_2D / max(feature_2D(:)); % have to normalize after all
        
        % export the stack to disk
        if param.is3D
            fileNameOut = fullfile(outputFolder, strrep(fileNameOut, 'BM4D_denoised.tif', '_handCraftFeature.tif'));
        else
            fileNameOut = fullfile(outputFolder, strrep(fileNameOut, 'BM4D_denoised.tif', '_handCraftFeature_2D.tif'))
        end
        export_stack_toDisk(fileNameOut, feature_2D_8bit, 8)

    