function metricSummary = create_summaryTable(metricTable, headers, rowTitles, tableFormat, format, paramTable, texOutput, networkName, methodName, fieldsWanted, network, meth, metrics_mat)

    if nargin == 0
        load('metricTemp.mat')
    else
        save('metricTemp.mat')
    end
    
    %%
  
    % are constant
    metricSummary.headers = headers;
    
    for network = 1 : size(metricTable, 1)        
        networkNewLine = 0;
        
        for meth = 1 : size(metricTable, 2)
            
            % +1 for the header row (network label)
            rowIndex = (network-1)*(size(metricTable, 2)+1) + meth + networkNewLine;
            if networkNewLine == 0
                networkNewLine = 1;                
                % write the header row here
                metricSummary.rowTitles{rowIndex} = networkName{network};
                noOfCols = length(metricTable{network, meth, format})
                metricSummary.data(rowIndex,:) = NaN(1,noOfCols);                
                rowIndex = rowIndex + 1;
            end
           
            % TODO: add method, and network to the same table
            
            %{
            if meanOnlyWanted
            metricSummary.data = metricTable{network, meth, format}(:, end-1:end)
            metricSummary.headers{1} = headers{end-1};
            metricSummary.headers{2} = headers{end}
            metricSummary.rowTitles = rowTitles{network, meth, format}
            %}
            
            metricSummary.data(rowIndex,:) = metricTable{network, meth, format};          
            
            % remove "forbidden" characters from LateX markup
            metricSummary.rowTitles{rowIndex} = strrep(methodName{meth}, '_', ' ');
            
        end
        
    end
    
    