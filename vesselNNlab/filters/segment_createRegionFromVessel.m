function regionInit = segment_createRegionFromVessel(vessel)
    
    plotON = false;
    regionMask = zeros(size(vessel));
    ind1 = floor(0.05*size(vessel,1)); ind2 = ceil(0.95*size(vessel,1));
    regionMask(ind1:ind2, ind1:ind2, :) = 1;

    regionInit = zeros(size(vessel));
    regionInit2 = regionInit; regionInit3 = regionInit; 
    regionInit4 = regionInit; regionInit5 = regionInit;
    region = regionInit;
    
    for i = 1 : size(vessel,3)
        
        regionInit(:,:,i) = im2bw(abs(vessel(:,:,i)),0.02);
        myfilter = fspecial('gaussian',[3 3], 2);
        regionInit2(:,:,i) = imfilter(double(regionInit(:,:,i)), myfilter, 'replicate');

        se = strel('disk',2);
        regionInit3(:,:,i) = imclose(regionInit2(:,:,i) ,se); % Perform a morphological close operation on the image.
        regionInit4(:,:,i) = imfill(regionInit3(:,:,i));

        % get rid of the borders
        regionInit5(:,:,i) = regionMask(:,:,i) .* regionInit4(:,:,i);
        
        % dilate a bit 
        se = strel('disk',12);
        regionInit6(:,:,i) = imdilate(regionInit5(:,:,i), se);
        
        region(:,:,i) = im2bw(regionInit6(:,:,i), 0.9);
        
        if plotON
            subplot(1,3,1); imshow(abs(vessel(:,:,i)), []);
            subplot(1,3,2); imshow(regionInit3(:,:,i), []);
            subplot(1,3,3); imshow(region(:,:,i), []);
        end

    end