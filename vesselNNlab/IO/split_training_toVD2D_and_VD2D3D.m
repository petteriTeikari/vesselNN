function [dataSplit, VD2D_range, VD2D3D_range] = split_training_toVD2D_and_VD2D3D(data, whichType, VD2D_range, VD2D3D_range, testTrainRation)
        
    if VD2D3D_range(1) == VD2D3D_range(2)
        if strcmp(whichType, 'test')
            VD2D3D_range(2) = length(data.it) * testTrainRation;
        else
            VD2D3D_range(2) = length(data.it);
        end
    end

    if strcmp(whichType, 'test')           
       VD2D_range(1) = ceil(VD2D_range(1) / testTrainRation);
       VD2D_range(2) = floor(VD2D_range(2) / testTrainRation);
       VD2D3D_range(1) = ceil(VD2D3D_range(1) / testTrainRation);
       VD2D3D_range(2) = floor(VD2D3D_range(2) / testTrainRation);

    end

    fieldNames = fieldnames(data);
    
        
    for i = 1 : length(fieldNames)
        dataSplit.VD2D.(fieldNames{i}) = data.(fieldNames{i})(VD2D_range(1):VD2D_range(2));
        dataSplit.VD2D3D.(fieldNames{i}) = data.(fieldNames{i})(VD2D3D_range(1):VD2D3D_range(2));
    end
