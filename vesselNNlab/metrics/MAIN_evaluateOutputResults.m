function MAIN_evaluateOutputResults()

    % NOTE! Now the algorithm assumes that the sorting is identical in all
    % of the folders, and there is no "intelligent" name matching. In other
    % words the 1st file of each folder (in alphabetical order) should be
    % of the corresponding stack

    % handle variations in location difference based on the computer name
    [~, name] = system('hostname');
    name = strtrim(name); % remove possible white-space characters 
    
    if strcmp(name, 'petteri-ubuntu64koti') || strcmp(name, 'C7Pajek') 
    
        mainFolder = '/media/petteri/480EBFF10EBFD5E2/Users/Petteri/Documents/MEGA/';
        
    elseif strcmp(name, 'Petteri-Win7')
    
        mainFolder = 'C:\Users\Petteri\MEGA';
        
    elseif strcmp(name, 'petteri-ubuntuKoti')
        
        mainFolder = '/media/petteri/965480B154809621/Users/Petteri/MEGA';
        
    else
       
        error(['No paths defined for computer: "', name, '"'])
        
    end

    % input image folder
    % im_folder = '/home/petteri/znnData/dropBoxed/denoised';
    im_folder = fullfile(mainFolder, 'dataset', 'vessel_2PM', 'denoised');
    imW_folder = fullfile(mainFolder, 'dataset', 'vessel_2PM', 'weighed');
    mask_folder = fullfile(mainFolder, 'dataset', 'vessel_2PM', 'masks');
        % will be created from the data, the outputs of segmentation

    % ground truth folder
    gt_folder = fullfile(mainFolder, 'dataset', 'vessel_2PM', 'labels');

    % output folder(s)
    i = 0; 
    i = i + 1; out_folder{i} = fullfile(mainFolder, 'experiments', 'OUTPUTS', 'VD2D3D_v3');
    i = i + 1; out_folder{i} = fullfile(mainFolder, 'experiments', 'OUTPUTS', 'VD2D3D_v2');
    %i = i + 1; out_folder{i} = fullfile(mainFolder, 'experiments', 'OUTPUTS', 'VD2D3D');
    %i = i + 1; out_folder{i} = fullfile(mainFolder, 'experiments', 'OUTPUTS', 'VD2D');
    
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
       [out_FileNames{j},index] = sort_nat(out_FileNames{j}, 'ascend');
       
    end
    
    
    %% SEGMENT NOW THE RESULTS
    
        param_segment = [];
       
        out = cell(length(out_folder),length(im_FileNames));
        im = cell(length(im_FileNames),1);
        
        % note, no check yet that the filename lengths match
        for network = 1 : length(out_folder)

            for file = 1 : length(im_FileNames)
                
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
                
                if ispc
                    delimiterString = '\';
                else
                    delimiterString = '/';
                end
                cellFields = textscan(out_folder{network}, '%s', 'Delimiter', delimiterString);
                networkName{network} = cellFields{1}{end};
                
                fileOut = strrep(nameIn, '.tif', '_weighed_');
                fileOut = sprintf('%s%s%s', fileOut, networkName{network}, '.tif');
                export_stack_toDisk(fullfile(imW_folder, fileOut), imW/max(imW(:)), 8);

                % COMPUTATIONS

                    % segment the input image with output, various methods can be
                    % used within the segmentation subfunction
                    
                    % TODO!
                    segmentation{network, file} = segment_networkOutput(im{file}, out{network, file}, fileOut, mask_folder, param_segment);                    
                    
                
            end

        end
        
        save(fullfile(imW_folder, 'segmResults.mat'))
    
    %% EVALUATE THE QUALITY OF THE SEGMENTATION
    
        param_metrics.methods = 'all';
        % param_metrics.methods = 'excludeAverageDistance'; % that takes the most time, and is the most useful

        gt = cell(length(im_FileNames),1);

        tic
        for network = 1 : length(out_folder)
            
            for file = 1 : length(im_FileNames)
                
                % import the ground truthnameIn = im_FileNames(file).name
                nameIn = gt_FileNames(file).name;
                folderIn = gt_folder;
                [~, imageStack, ~, ~] = importMicroscopyFile(nameIn, folderIn);
                gt{file} = double(imageStack{1}{1});
        
                % evaluate the segmentation quality, again multiple metrics
                % can be used within this subfunction
                gtOnDisk = fullfile(folderIn, nameIn);
                
                % TODO!
                metrics{network, file} = segment_evaluateQuality(gt{file}, gtOnDisk, segmentation{network, file}, param_metrics);
                
                % ERRORS - Possible
                
                    % Matlab 2012a
                    % "/usr/local/MATLAB/R2012a/bin/glnxa64/libstdc++.so.6:
                    % version `GLIBCXX_3.4.15' not found"
                    % https://fantasticzr.wordpress.com/2013/05/29/matlab-error-libstdc-so-version-glibcxx_3-4-15-not-found/
                    
                    % sudo ln -sf /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.16 /usr/local/MATLAB/R2012a/bin/glnxa64/libstdc++.so.6

                    
                    % spaces in paths
                    % Image doesn't exist: /media/petteri/965480B154809621/Documents
                
                % NOTE! the output gets quite messy with "parfor" as the
                % calls are not sequential
                
                [network file]
                save(['metricsLoop_net', num2str(network), '_file', num2str(file), '.mat'], 'metrics')
                disp('loop .mat save')
                                
            end
            
            
            
        end
        toc
        save('metrics.mat', 'metrics', 'segmentation')
        
    %% CREATE MATRICES
    
        %save('metrics.mat', 'metrics', 'segmentation')
        %save(fullfile('C:\Users\Petteri\Desktop', 'allSegmVariables.mat'))
        %load(fullfile('C:\Users\Petteri\Desktop', 'allSegmVariables.mat'))
        load('metrics.mat')
        segment_createDataMatricesOfMetrics(segmentation, metrics, out_folder)
        
    %% VISUALIZE THE RESULTS 
    
        noOfStacks = length(im_FileNames);
        noOfColsPerStack = 4; % im / gt / znn / segmentation
        computeAgain = false; % whether you need to re-compute the best/worst slice indices (Takes time)
        bestOrWorst = {'best'; 'worst'};
        
        for network = 1 : length(out_folder)
            for meth = 1 : length(segmentation{network, 1})
                for best = 1 : length(bestOrWorst)
                    for file = 1 : noOfStacks                                    
                        visualize_theSegmentationResults(file, im{file}, logical(gt{file}), out{network, file}, segmentation{network, file}{meth}, ...
                            metrics{network, file}{meth}, noOfStacks, noOfColsPerStack, networkName{network}, segmentation{network, file}{meth}.name, im_FileNames(file).name, ...
                            computeAgain, bestOrWorst{best})
           
                    end
                end
                
            end
        end
