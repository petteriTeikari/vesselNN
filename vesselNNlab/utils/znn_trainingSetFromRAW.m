function znn_trainingSetFromRAW(datasetFolder)

    %% SETTINGS

        % the raw .OIB files
        datasetFolder = '/media/petteri/480EBFF10EBFD5E2/Users/Petteri/Documents/MEGA/dataset/vessel_2PM';
        imFolder = fullfile(datasetFolder, 'rawFullOIB_stacks');

            % out, raw/denoised
            outFolder = fullfile(datasetFolder, 'rawBatch');
            denoisefFolder = fullfile(datasetFolder, 'denoisedBatch');


        % correspondence spreadsheet
        corrFolder = '/media/petteri/480EBFF10EBFD5E2/Users/Petteri/Documents/MEGA/dataset/vessel_2PM';
        corrFile = fullfile(corrFolder, 'filenameCorrespondence.xls')        
        corrTable = readtable(corrFile)
        
    %% PROCESS
    
        corrTable.OriginalFilename
        
    
        for i = 9 : 9 % length(corrTable.OriginalFilename)            
           
            fileIn = cell2mat(corrTable.OriginalFilename(i));
            timePoint = corrTable.t;
            channel = corrTable.Ch;
            slices = [corrTable.Slice1 corrTable.SliceEnd];
                        
            [data, imageStack, metadata, options] = importMicroscopyFile(fileIn, imFolder)
            dataOut = import_getSubstack(data, imageStack, metadata, options, timePoint(i), channel(i), slices(i,:));
            
        end
        
        
        
        
        
