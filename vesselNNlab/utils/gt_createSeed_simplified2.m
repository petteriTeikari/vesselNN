function gt_createSeed_simplified2(im, param, sliceOfInterest, fileName)

    % Local testing    
    if nargin == 0
        pathImage = '/home/petteri/znnData/dataset/vessel_2PM/denoised/undone/'; 
        fileName = 'poon2015_adMouseLowSNR_BM4D_denoised.tif';
        [~, imageStack, ~, ~] = importMicroscopyFile(fileName, pathImage);
        im = single(imageStack{1}{1});
        im = im / max(im(:));       
       
        pathImage_znn = '/home/petteri/znnData/experiments/VD2D3D_tanh';
        fileName_znn = 'out_sample10_output_0.tif';
        try
            [~, imageStack, ~, ~] = importMicroscopyFile(fileName_znn, pathImage_znn);
            znn = single(imageStack{1}{1});
            znn = znn / max(znn(:));
        catch err
            err
            znn = ones(size(im));
        end
        param.visualizeOn = true;        
        sliceOfInterest = 6;
       
    end
    
    % get the current path (where this .m file is), and cd to that
    fileNameM = mfilename; fullPath = mfilename('fullpath');
    pathCode = strrep(fullPath, fileNameM, '');
    if ~isempty(pathCode); cd(pathCode); end
    
    % get screen size for plotting
    scrsz = get(0,'ScreenSize'); 
    

    %% Use the handcraft feature filter as a "pre-process" step

        % no znn-weighing this time
        param.is3D = false;
        param.saveToDisk = false;
        [featureScaled, featureSigned] = handcraftVesselFeature(im, ones(size(im)), param, [], []);

        % save('featureScaled.mat', 'featureScaled')
        % load featureScaled.mat
        
    %% Weigh the input with this
    
        imW = featureScaled .* im;        
        h = imshow([im(:,:,sliceOfInterest),imW(:,:,sliceOfInterest)], []); colorbar
        
    %% Weigh this with ZNN
    
        imW_znn = imW .* znn;        
        h = imshow([imW(:,:,sliceOfInterest),imW_znn(:,:,sliceOfInterest)], []); colorbar
        
    %% Use the 3D handcraft feature filter as the next preprocessing step
     
        % no znn-weighing this time
        param.is3D = true;
        param.saveToDisk = false;
        [featureScaled2, featureSigned2] = handcraftVesselFeature_3D(imW_znn, znn, param, [], []);
       
     
    %% Weigh the input with this
    
        [min(featureSigned2(:)) max(featureSigned2(:))]
        imW2 = featureSigned2 .* imW_znn;        
        h = imshow([im(:,:,sliceOfInterest),imW(:,:,sliceOfInterest)], []); colorbar
        
    %% Get the edges
           
        opts.suppressFaintEdges = true;
        opts.edges.modelFasnm='vessel2PM';
        edges = vesselness_structuredEdgesWrapper(imW2, opts); 
        
        edgesW = edges .* imW_znn;
        edgesW = edgesW / max(edgesW(:));
        
        h = imshow([imW2(:,:,sliceOfInterest), edgesW(:,:,sliceOfInterest)], []); colorbar
        
    %% MDOF
    
        radii = 1:3; 
        disp('   MDOF 3D')
        
        scales = radii(1):radii(end); % TODO: seems not to be working
        scaleStep = scales(2) - scales(1);
        intensityScaling = 'imAdjust'; % none, gamma, sigmoid, log10, hdrToneMapping?
       
        MDOF_3D_edges = vesselness_MDOF_ImageJ_wrapper(edgesW, scales, scaleStep, intensityScaling);       
        MDOF = MDOF_3D_edges / max(MDOF_3D_edges(:));
        
    %% Find the initial binary mask using active level sets 
    
        options = [];
        imW2s = resize_stack(imW2, 1/2);
        edgesWs = resize_stack(edgesW, 1/2);
        MDOFs = resize_stack(MDOF, 1/2);
        % save(fullfile('/home/petteri/Desktop', 'forASETS.mat'))
        % load(fullfile('/home/petteri/Desktop', 'forASETS.mat'))
      
        %%
        close all
        [edgeMask, u] = segment_asetsPreWrapper3D(edgesW, MDOF, sliceOfInterest, options);
        
        outputPath = fullfile(pathCode, '..', 'imagesOutTemp');        
        fileOut = fullfile(outputPath, [strrep(fileName, '.tif', ''), '_edgeMask_fullRes_w02_03-05.tif']);
        export_stack_toDisk(fileOut, edgeMask)
        
        %% get the contour
        for i = 1 : size(im,3)
            maskPerimeter(:,:,i) = bwperim(edgeMask(:,:,i));
        end
        
        h = imshow([edgeMask(:,:,sliceOfInterest), maskPerimeter(:,:,sliceOfInterest)], []); colorbar

        
    %% refine this mask with Dense CRF
        
        param.echoOn = false;
        param.resizeForDebug = false;
        param.constrictGTs = false;
    
        %{
        imLog = log10(imW + 0.05);
        imLog = imLog - min(imLog(:));
        imLog = imLog / max(imLog(:));
        %}
        
        inferTrain = 'inference';
        warning off; tic        
        CRFmask = segment_CRF_wrapper(im, uint8(edgeMask), inferTrain, '', param);
        warning on; toc
        
        h = imshow([mask(:,:,sliceOfInterest), CRFmask(:,:,sliceOfInterest)], []); colorbar
        CRFmask = mask;
        
    %% Manually fix the mask    
        
        CRFmaskFixed = zeros(size(CRFmask));
        CRFcontours = zeros(size(CRFmask));
        for slice = 1 : size(CRFmask, 3)
            
            % remove isolated pixels
            pixelThreshold = 9;
            CRFmaskFixed(:,:,slice)  = bwareaopen(CRFmask(:,:,slice), pixelThreshold);
            
            % close image to remove small holes or discontinuities
            se = strel('disk',2);
            CRFmaskFixed(:,:,slice) = imclose(CRFmaskFixed(:,:,slice),se);
            
            CRFcontours(:,:,slice) = bwperim(CRFmask(:,:,slice));
            
            %CRFcontours(:,:,slice) = bwmorph(CRFmaskFixed(:,:,slice),'skel',Inf);

        end
        
        h = imshow([CRFmask(:,:,sliceOfInterest), CRFmaskFixed(:,:,sliceOfInterest)], []); colorbar

        
    %% PLOT THE RESULTS (ground truth seed)
    
        if param.visualizeOn
            
            fig5 = figure('Color','w','Name', 'Final CRF-Refined MASK');        
                set(fig5,  'Position', [0.05*scrsz(3) 0.01*scrsz(4) 0.90*scrsz(3) 0.850*scrsz(4)])

            edgeSeed_RGB_slice = repmat(im(:,:,sliceOfInterest), [1 1 3]);
            edgeSeed_RGB_slice(:,:,1) = edgeMask(:,:,sliceOfInterest); % add seed to red channel
              
            edgeSeedCRF_RGB_slice = repmat(im(:,:,sliceOfInterest), [1 1 3]);
            edgeSeedCRF_RGB_slice(:,:,1) = CRFmaskFixed(:,:,sliceOfInterest); % add seed to red channel
            
            edgeSeedCRFc_RGB_slice = repmat(im(:,:,sliceOfInterest), [1 1 3]);
            edgeSeedCRFc_RGB_slice(:,:,1) = CRFcontours(:,:,sliceOfInterest); % add seed to red channel
            
            rows = 2; cols = 2;            

            i = 0;            
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(im(:,:,sliceOfInterest), []); title('Denoised + Str. Edges');
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edgeSeed_RGB_slice, []); title('before Densecrf');
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edgeSeedCRF_RGB_slice, []); title('MASK after Densecrf');
            i = i + 1; sp(i) = subplot(rows,cols,i); imshow(edgeSeedCRFc_RGB_slice, []); title('CONTOURS after Densecrf');
                        
        end
        
    %% EXPORT THE RESULTS
    
        outputPath = fullfile(pathCode, '..', 'imagesOutTemp');
        
        fileOut = fullfile(outputPath, [strrep(fileName, '.tif', ''), '_seedCRF_Contours.tif']);
        export_stack_toDisk(fileOut, CRFcontours)
        
        fileOut = fullfile(outputPath, [strrep(fileName, '.tif', ''), '_seed_Contours.tif']);
        export_stack_toDisk(fileOut, maskPerimeter)
        
        % fileOut = fullfile(outputPath, [strrep(fileName, '.tif', ''), '_seedMask.tif']);
        % export_stack_toDisk(fileOut, CRFmaskFixed)
