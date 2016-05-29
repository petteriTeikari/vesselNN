function visualize_theSegmentationResults(fileInd, im, gt, znn, segmStruct, metrics, noOfStacks, noOfColsPerStack, networkName, methodName, imFileName, computeAgain, bestOrWorst)
    
    if nargin == 0
        load('tempVisuSegm.mat')
    else
        save('tempVisuSegm.mat')
    end
    
    % get the current path (where this .m file is), and cd to that
    currDir = pwd;
    fileName = mfilename; fullPath = mfilename('fullpath');
    pathCode = strrep(fullPath, fileName, '');
    cd(pathCode)

    % make the path absolute
    indicesDir  = fullfile(pathCode, 'visualizationIndices');
    evalSegmDir  = fullfile(pathCode, '..', '3rdParty', 'EvaluateSegmentation', 'builds');
        
    % get the segmentation binary matrix from structure
    segm = logical(segmStruct.labelStack);
    
    
    % Init the figure
    if fileInd == 1
        
        close all
        fig = figure('Color', 'w');
        
            scrsz = get(0,'ScreenSize'); % get screen size for plotting
            set(fig,  'Position', [0.10*scrsz(3) 0.01*scrsz(4) 0.60*scrsz(3) 0.90*scrsz(4)])

           
        
    end
    
    % subplot layout
    rows = ceil(noOfStacks / 2); 
    cols = noOfColsPerStack * (noOfStacks / rows);
    
    % Get the indices for worst-case and best-case scenario    
    [sliceIndex, quality] = visualize_getSliceIndicesForBestAndWorst(gt, segm, imFileName, indicesDir, evalSegmDir, computeAgain, bestOrWorst);

    
    %% PLOT
    
        alpha = 0.55; % transparency
        gamma = 0.65; % gamma correction
    
        im(:,:,sliceIndex) = 255 * (im(:,:,sliceIndex) / 255) .^ gamma;
        
        % Plot input image
        i = 1;
        subIndex = (fileInd-1)*noOfColsPerStack + i;  
            sp(i) = subplot(rows,cols,subIndex);
            p(i) = imshow(im(:,:,sliceIndex) .^ 0.5, []);
            titleString = sprintf('%s\n%s', ['Stack ', num2str(fileInd)], ['slice=', num2str(sliceIndex)]);
            tit(i) = title(titleString);

            
        % Ground truth
        i = i + 1;
        color = [1 0 0];        
        subIndex = (fileInd-1)*noOfColsPerStack + i;
            sp(i) = subplot(rows,cols,subIndex);
            gtRGB = visualize_imToRGB(im(:,:,sliceIndex), gt(:,:,sliceIndex), color, alpha);
            p(i) = imshow(gtRGB, []);
            tit(i) = title(['Label']);


        % ZNN
        i = i + 1;
        color = [0 1 0];
        subIndex = (fileInd-1)*noOfColsPerStack + i;
            sp(i) = subplot(rows,cols,subIndex);
            znnRGB = visualize_imToRGB(im(:,:,sliceIndex), znn(:,:,sliceIndex), color, alpha);
            p(i) = imshow(znnRGB, []);
            tit(i) = title(['ZNN']);


        % Segmentation
        i = i + 1;
        color = [0 0 1];
        subIndex = (fileInd-1)*noOfColsPerStack + i;
            sp(i) = subplot(rows,cols,subIndex);
            segmRGB = visualize_imToRGB(im(:,:,sliceIndex), segm(:,:,sliceIndex), color, alpha);
            p(i) = imshow(segmRGB, []);
            titleString = sprintf('%s\n%s', ['Mask'], ['AVD=', num2str(quality(sliceIndex),'%.2f')]);
            tit(i) = title(titleString);
            
            
            
        % Style
        set(tit, 'FontSize', 7)        
        
        if fileInd == noOfStacks
            
            export_fig(fullfile(indicesDir, [networkName, '_', methodName, '_', bestOrWorst, '.png']), '-r300', '-a2')
            
        end

        drawnow
    
    function RGB = visualize_imToRGB(im, overlay, color, alpha)
        
        RGB = repmat(im,[1 1 3]);
        
        % normalize
        RGB = RGB / max(RGB(:));
                
        %[min(overlay(:)) max(overlay(:))]
        %[min(RGB(:)) max(RGB(:))]
        
        overlayRGB = zeros(size(RGB));
        for j = 1 : 3
            overlayRGB(:,:,j) = alpha * color(j) * overlay;
        end
            
        RGB = (0.8*RGB) + overlayRGB;
    
    function [index, quality] = visualize_getSliceIndicesForBestAndWorst(gt, segm, imFileName, indicesDir, evalSegmDir, computeAgain, bestOrWorst)
        
        % check first if they have been calculated
        indices_FileNames = dir(fullfile(indicesDir, '*.mat'));
        for i = 1 : length(indices_FileNames)
            fileNames{i} = indices_FileNames(i).name;            
        end
        outputFilename = strrep(imFileName, '.tif', '');
        
        ifComputedAlready = false;
        if ~isempty(indices_FileNames)
            ifTrueC = strfind(fileNames, [outputFilename, '_', bestOrWorst]);
            ifTrue = find(not(cellfun('isempty', ifTrueC)));
            if ~isempty(ifTrue)
                ifComputedAlready = true;
            end
        end
        
        if ifComputedAlready && ~computeAgain            
            outputFilename = [outputFilename, '_' bestOrWorst, '.mat'];
            load(fullfile(indicesDir, outputFilename))            
            
        else
        
            % evaluate the quality slice-by-slice
            for slice = 1 : size(gt, 3)

                gtFileName = 'gt_temp.tif';
                segmFileName = 'segm_temp.tif';
                segmentation.fullPath = fullfile(indicesDir, segmFileName);

                % write to disk
                imwrite(uint8(255*gt(:,:,slice)), fullfile(indicesDir, gtFileName))
                imwrite(uint8(255*segm(:,:,slice)), segmentation.fullPath)

                % compute metrics
                param_metrics.methods = 'all';
                metrics = segment_compareSegmentationToGroundTruth(gt, fullfile(indicesDir, gtFileName), segmentation, param_metrics);
                metricsMat = parse_XMLtoMat(metrics, {'AVGDIST'});

                quality(slice,1) = metricsMat.matrix;

            end
            
            if strcmp(bestOrWorst, 'best')
                [~,index] = min(quality);
            elseif strcmp(bestOrWorst, 'worst')
                [~,index] = max(quality);
            end

            outputFilename = [outputFilename, '_' bestOrWorst, '.mat'];
            save(fullfile(indicesDir, outputFilename), 'quality', 'index')
            
        end
        
        
