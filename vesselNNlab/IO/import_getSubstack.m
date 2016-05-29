    function dataOut = import_getSubstack(data, imageStack, metadata, options, timePoint, channel, slices)
    
        if nargin == 0
            load('/home/petteri/Desktop/tempMeta.mat')
        else
            save('/home/petteri/Desktop/tempMeta.mat')
        end
    
        whos
        
        disp(metadata.main)
        sVector = size(data, 1)
        noOfChannels = metadata.main.noOfChannels
        noOfTimePoints = metadata.main.noOfTimePoints
        
        % see e.g. 
        % https://www.openmicroscopy.org/site/support/bio-formats5.1/developers/matlab-dev.html
        
        for s = 1 : length(sVector)
            
            noOfStacks = size(data{s,1},1)
            for stack = 1 : noOfStacks
                
                xyStack = data{s,1}{stack,1};
                xyLabel = data{s,1}{stack,2};
                xyRes = size(data{s,1}{stack,1})
                whos
                
                pause
            end
            
            
        end
        
        dataOut = []