function latex = latexTable_wrapper(data, colLabels, rowLabels, tableFormat, paramTable, texOutput, networkName, methodName)

    rowLabels
    colLabels
    data

    % Write this table as .tex file so it can be included
    % easily in LyX, use "latexTable" by Eli Duenisch           
    input.data = data;
    input.tableColLabels = colLabels;
    input.tableRowLabels = rowLabels;

    input.transposeTable = 0;  % Switch transposing/pivoting your table
    input.dataFormatMode = 'column'; % Determine whether input.dataFormat is applied column or row based
    input.dataFormat = {'%.2f',length(colLabels)}; % 2 digits precision
    input.tableColumnAlignment = 'c'; % center
    input.tableBorders = 1; % Switch table borders on/off
    
    
    % remove "forbidden" characters from LateX markup
    input.tableCaption = ['Results of ', networkName, ' architecture using the ', strrep(methodName, '_', ' '), ' for segmentation']; % LaTex table caption
        % TODO: strrep for "_"
    input.tableLabel = ['all_', networkName, '_', methodName]; % LaTex table label

    latex = latexTable(input);
    
    outputFilename = [tableFormat, '_', networkName, '_', methodName, '.tex']
    fid = fopen(fullfile(texOutput, outputFilename),'wt');
    for i = 1 : length(latex)
        if i == 1
            fprintf(fid, '%s\n' ,'\scriptsize{');
        end
        fprintf(fid, '%s\n' ,latex{i});

        if i == length(latex)
            fprintf(fid, '%s\n' ,'}');
        end
    end
    fclose(fid);