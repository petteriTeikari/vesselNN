function evaluateOutputResults()

    % NOTE! Now the algorithm assumes that the sorting is identical in all
    % of the folders, and there is no "intelligent" name matching. In other
    % words the 1st file of each folder (in alphabetical order) should be
    % of the corresponding stack

    % handle variations in location difference based on the computer name
    [~, name] = system('hostname');
    name = strtrim(name); % remove possible white-space characters 
    
    if strcmp(name, 'petteri-ubuntu64koti') || strcmp(name, 'C7Pajek')
    
        % input image folder
        im_folder = '/home/petteri/znnData/dropBoxed/denoised';
        imW_folder = '/home/petteri/znnData/dropBoxed/weighed';
        mask_folder = '/home/petteri/znnData/dropBoxed/masks';
        
        % ground truth folder
        gt_folder = '/home/petteri/znnData/dropBoxed/labels';

        % output folder(s)
        i = 0; 
        i = i + 1; out_folder{i} = '/home/petteri/znnData/dropBoxed/VD2D3D';
        i = i + 1; out_folder{i} = '/home/petteri/znnData/dropBoxed/VD2D';
        
        
    else
       
        error(['No paths defined for computer: "', name, '"'])
        
    end

    % get filename listing
    im_FileNames = dir(fullfile(im_folder, '*.tif'));
    gt_FileNames = dir(fullfile(gt_folder, '*.tif'));
    for j = 1 : length(out_folder)
       out_FileNamesFull{j} =  dir(fullfile(out_folder{j}, '*.tif'));
       
       for file = 1 : length(out_FileNamesFull{j})
            out_FileNames{j}{file} = out_FileNamesFull{j}(file).name;
       end
       
       % now Matlab does not sort correctly as ZNN does not include zero
       % padding for indices, so we use sort_nat so that sample10 does not
       % appear before sample1 for example
       % http://www.mathworks.com/matlabcentral/fileexchange/10959-sort-nat--natural-order-sort
       [out_FileNames{j},index] = sort_nat(out_FileNames{j},'ascend');
       
    end
    
    
    %% SEGMENT NOW THE RESULTS
    
        param_segment = [];
       
        out = cell(length(out_folder),length(im_FileNames));
        im = cell(length(im_FileNames),1);
        
        % note, no check yet that the filename lengths match
        for network = 1 : length(out_folder)

            for file = 10 : 10 %  length(im_FileNames)
                
                % import the results
                nameIn = out_FileNames{network}{file};
                folderIn = out_folder{network};
                [~, imageStack, ~, ~] = importMicroscopyFile(nameIn, folderIn);
                out{network, file} = double(imageStack{1}{1});

                % import the input image
                nameIn = im_FileNames(file).name;
                folderIn = im_folder;
                [~, imageStack, ~, ~] = importMicroscopyFile(nameIn, folderIn);
                im{file} = double(imageStack{1}{1});
                
                % export the weighed image
                imW = out{network, file} .* im{file};
                cellFields = textscan(out_folder{network}, '%s', 'Delimiter', '/');
                networkName{network} = cellFields{1}{end};
                fileOut = strrep(nameIn, '.tif', '_weighed_');
                fileOut = sprintf('%s%s%s', fileOut, networkName{network}, '.tif');
                export_stack_toDisk(fullfile(imW_folder, fileOut), imW/max(imW(:)), 8);

                % COMPUTATIONS

                    % segment the input image with output, various methods can be
                    % used within the segmentation subfunction
                    % segmentation{network, file} = segment_networkOutput(im{file}, out{network, file}, fileOut, mask_folder, param_segment);                    
                    
                
            end

        end
        
        % save(fullfile(imW_folder, 'segmResults.mat'))
    
    %% EVALUATE THE QUALITY OF THE SEGMENTATION
    
        param_metrics.methods = 'all';
        % param_metrics.methods = 'excludeAverageDistance'; % that takes the most time, and is the most useful

        gt = cell(length(im_FileNames),1);

        tic
        for network = 1 : length(out_folder)
            
            parfor file = 1 : length(im_FileNames)
                
                % import the ground truthnameIn = im_FileNames(file).name
                nameIn = gt_FileNames(file).name;
                folderIn = gt_folder;
                [~, imageStack, ~, ~] = importMicroscopyFile(nameIn, folderIn);
                gt{file} = double(imageStack{1}{1});
        
                % evaluate the segmentation quality, again multiple metrics
                % can be used within this subfunction
                gtOnDisk = fullfile(folderIn, nameIn);
                metrics{network, file} = segment_evaluateQuality(gt{file}, gtOnDisk, segmentation{network, file}, param_metrics);
                
                % NOTE! the output gets quite messy with "parfor" as the
                % calls are not sequential
                                
            end
            
        end
        toc
        % save('metrics.mat', 'metrics', 'segmentation')
        
    %% CREATE MATRICES
    
        % save('metrics.mat', 'metrics', 'segmentation')
        % load('metrics.mat')
        segment_createDataMatricesOfMetrics(segmentation, metrics, out_folder)
        
    %% VISUALIZE THE RESULTS 
    
        noOfStacks = length(im_FileNames);
        noOfColsPerStack = 4; % im / gt / znn / segmentation
        computeAgain = false % whether you need to re-compute the best/worst slice indices (Takes time)
        bestOrWorst = {'best'; 'worst'};
        
        for network = 1 : 1 % length(out_folder)
            for meth = 1 : length(segmentation{network, 1})
                for best = 1 : length(bestOrWorst)
                    for file = 1 : noOfStacks                                    
                        visualize_theSegmentationResults(file, im{file}, logical(gt{file}), out{network, file}, segmentation{network, file}{meth}, ...
                            metrics{network, file}{meth}, noOfStacks, noOfColsPerStack, networkName{network}, segmentation{network, file}{meth}.name, im_FileNames(file).name, ...
                            computeAgain, bestOrWorst{best})
           
                    end
                end
                pause
            end
        end