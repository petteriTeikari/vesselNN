function metrics = segment_evaluateQuality(gt, gtOnDisk, segmentation, param_metrics)

    if nargin == 0
        % load('/home/petteri/Desktop/temp2.mat')
    else
        % save('/home/petteri/Desktop/temp2.mat')
    end
    
    %%   

    noOfSegmentationMethods = length(segmentation);
    
    % Go through each segmentation method used
    for m = 1 : noOfSegmentationMethods
        
        metrics{m} = segment_compareSegmentationToGroundTruth(uint8(gt), gtOnDisk, segmentation{m}, param_metrics);
        
    end
