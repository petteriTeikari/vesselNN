function labelPercentages()

    imFolder = '/home/petteri/znnData/dataset/vessel_2PM/labels';
    
    % get image listing
    fileListing_gt = dir(fullfile(imFolder, '*.tif'));
    
    % Visualize all as MIPs
    compute_vesselLabelPercentage(imFolder, fileListing_gt)
    
    
    
    function compute_vesselLabelPercentage(imFolder, fileListing)
        
        for file = 1 : length(fileListing)
            
            % import the image data
            [~, imageStack, ~, ~] = importMicroscopyFile(fileListing(file).name, imFolder);
            im = logical(imageStack{1}{1});
           
            % 
            isVessel = length(find(im == true));
            notVessel = length(find(im == false));
            noOfVoxels = length(im(:));
            
            misMatchIfAny = noOfVoxels - (isVessel + notVessel);
            if misMatchIfAny ~= 0
                warning('There are more than 2 labels in GT, check where things go wrong?')
            end
            
            vesselPercentage(file) = isVessel / noOfVoxels;
            vesselPercRounded(file) = str2double(num2str(100*vesselPercentage(file), 3));
       
        end
        
        vesselPercRounded