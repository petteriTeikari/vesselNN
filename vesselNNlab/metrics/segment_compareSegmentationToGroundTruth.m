% Wrapper for EvaluateSegmentation
function metrics = segment_compareSegmentationToGroundTruth(gt, gtOnDisk, segmentation, param_metrics)

    % Note!
    % gt - is a matrix
    % segmentation - structure containing fields
    
    % EvaluateSegmentation is a C++ program so we run it from the command
    % line, and need to write the matrices to disk (or read from existing
    % files, supported formats are the ones supported by ITK)
        
    %% get directory
    
        % get the current path (where this .m file is), and cd to that
        currDir = pwd;
        fileName = mfilename; fullPath = mfilename('fullpath');
        pathCode = strrep(fullPath, fileName, '');
        cd(pathCode)

        % make the path absolute
        evalSegmDir  = fullfile(pathCode, '..', '3rdParty', 'EvaluateSegmentation', 'builds');
        imageTemp = fullfile(pathCode, '..', '3rdParty', 'EvaluateSegmentation', 'tempImFolder');

    %% write gt to disk
    
        % gtFileName = 'gtTemp.tif';
        % export_stack_toDisk(fullfile(imageTemp, gtFileName), gt, 8)
    
    %% construct the call
    
        % we evaluate using all the metrics, if you want this to be faster,
        % exclude the "Average Hausdorff Distance" as it takes the most of the time
        outputFile = fullfile(evalSegmDir, 'results.xml');
        
        if strcmp(param_metrics.methods, 'all')
            outputFlag = '–use all';
            
        elseif strcmp(param_metrics.methods, 'excludeAverageDistance')
            outputFlag = '–use DICE,JACRD,GCOERR,VOLSMTY,KAPPA,AUC,RNDIND,ADJRIND,ICCORR,MUTINF,FALLOUTCOEFVAR,VARINFO,PROBDST,MAHLNBS,SNSVTY,SPCFTY,PRCISON,FMEASR@0.5@,ACURCY';
            
        elseif strcmp(param_metrics.methods, 'all')
            
            % need to define for cell list of fields
            
        else
            
            whyHere = param_metrics.methods
            
        end
        
        callString = [fullfile(evalSegmDir, 'EvaluateSegmentation'), ' ', gtOnDisk, ' ', ...
                      segmentation.fullPath, ' ', outputFlag, ' ', '-xml', ' ', outputFile]
        
        try
            system(callString)
        catch err
            
            err
            err.identifier
            % TODO: Probably have weird errors here if there are problems
            % with directory definitions
        end
        
    %% parse the created XML
    
        metrics = parse_resultsXML(outputFile);
        % metrics_mat = parse_XMLtoMat(metrics);
        
        % TODO: save each metric file to disk as .mat file?
        
        