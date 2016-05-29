function segment_createDataMatricesOfMetrics(segmentation, metrics, out_folder)

    if nargin == 0
        %load('tempMetrics.mat')
    else
        %save('tempMetrics.mat')
    end
    whos
    
    noOfNetworks = size(metrics, 1);
    noOfFiles = size(metrics, 2);
    noOfSegmMethods = length(metrics{1,1});
    
    
    % handle variations in location difference based on the computer name
    [~, name] = system('hostname');
    name = strtrim(name); % remove possible white-space characters 
    
    if strcmp(name, 'petteri-ubuntu64koti') || strcmp(name, 'C7Pajek') 
    
        texOutput = '/home/petteri/Dropbox/Drafts_w_Biblio/vesselNN_lyx/tables';
        
    elseif strcmp(name, 'Petteri-Win7')
    
        texOutput = 'C:\Users\Petteri\Dropbox\Drafts_w_Biblio\vesselNN_lyx\tables';
        
    else 
        
        error('Computer Name?')
        
    end
    
    %% All the metrics computed 
    
        % metrics as rows
        % stacks as columns
        
        tableFormat = {'all'; 'subset'; 'summary'};
        fieldsWanted = {'all'; {'ADJRIND'; 'MUTINF'; 'AUC'; 'HDRFDST'; 'AVGDIST'; 'MAHLNBS'}; {'AVGDIST'}};
        
        % We chose to use the average Hausdorf distance as the metric, as
        % it seems to be the most suitable to evaluate complex boundaries
        % such as is the case with vasculature. For discussion see Taha and
        % Hanbury (2015), http://dx.doi.org/10.1186/s12880-015-0068-x
        
        paramTable.transposeTable = 0;
    
        % 'Full table' per each network
        for format = 1 : length(tableFormat)
            
            clear metricTable
            clear rowTitles            
            
            for network = 1 : noOfNetworks

                cellFields = textscan(out_folder{network}, '%s', 'Delimiter', '/');
                networkName{network} = cellFields{1}{end};

                for meth = 1 : noOfSegmMethods          
                    methodName{meth} = segmentation{network, 1}{meth}.name;
                                            
                    for file = 1 : noOfFiles
                        metrics % why no VD2D?
                        fieldsWanted
                        metrics_mat = parse_XMLtoMat(metrics{network, file}{meth}, fieldsWanted{format});
                        metricTable{network, meth, format}(:, file) = metrics_mat.matrix;
                        headers{file} = ['', num2str(file)];
                        rowTitles{network, meth, format} = metrics_mat.headers;
                        if file == noOfFiles                                
                            headers{file+1} = 'Mean';
                            headers{file+2} = 'SD';
                        end
                    end

                    % compute mean +- SD
                    for metricInd = 1 : size(metricTable{network, meth, format},1)
                        metricTable{network, meth, format}(metricInd, file+1) = mean(metricTable{network, meth, format}(metricInd, :));
                        metricTable{network, meth, format}(metricInd, file+2) = std(metricTable{network, meth, format}(metricInd, :));
                    end
                    
                    if strcmp(tableFormat{format}, 'all') || strcmp(tableFormat{format}, 'subset')                        
                        latex = latexTable_wrapper(metricTable{network, meth, format}, headers, rowTitles{network, meth, format}, tableFormat{format}, paramTable, texOutput, networkName{network}, methodName{meth});
                    end
                    
                end            
            end
            
            if strcmp(tableFormat{format}, 'summary')
                metricSummary = create_summaryTable(metricTable, headers, rowTitles, tableFormat{format}, format, paramTable, texOutput, networkName, methodName, fieldsWanted{format}, network, meth, metrics_mat);
                latex = latexTable_wrapper(metricSummary.data, metricSummary.headers, metricSummary.rowTitles, tableFormat{format}, paramTable, texOutput, 'summary', 'summary');
            end

        end