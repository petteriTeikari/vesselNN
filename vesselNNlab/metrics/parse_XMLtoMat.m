function metrics = parse_XMLtoMat(metricsXML, selectedFields)
        
    fieldNames = fieldnames(metricsXML);

    if ~iscell(selectedFields)
        if strcmp(selectedFields, 'all')

           % disp('Processing all the fields')
           % make table from all of the field names
           for i = 1 : length(fieldNames)
               metrics.headers{i} = metricsXML.(fieldNames{i}).Attributes.symbol;
               metrics.description{i} = metricsXML.(fieldNames{i}).Attributes.name;
               metrics.type{i} = metricsXML.(fieldNames{i}).Attributes.type;
               metrics.matrix(i,1) = str2double(metricsXML.(fieldNames{i}).Attributes.value);
           end

        end
    else

        % disp('Processing only wanted fields (metrics)')
        % make table from selected field names
        j = 0;
        foundMatrix = zeros(length(selectedFields),1); 

           for i = 1 : length(fieldNames)

               % check if given field can be found
               IndexC = strcmp(selectedFields, fieldNames{i});
               Index = find(IndexC == 1);

               % 
               if ~isempty(Index)
                   % disp(['.. FOUND field = ', fieldNames{i}, ' (wanted = ', selectedFields{Index}, ')'])
                   j = j + 1;
                   foundMatrix(Index) = 1;
                   metrics.headers{j} = metricsXML.(fieldNames{i}).Attributes.symbol;
                   metrics.description{j} = metricsXML.(fieldNames{i}).Attributes.name;
                   metrics.type{j} = metricsXML.(fieldNames{i}).Attributes.type;
                   metrics.matrix(j,1) = str2double(metricsXML.(fieldNames{i}).Attributes.value);
               end
           end

           % check whether you found everything that you wanted
           notFound = find(foundMatrix == 0);
            if ~isempty(notFound)

                for i = 1 : length(notFound)
                    warning([' NEVER FOUND field = ', selectedFields{notFound(i)}, '), maybe a TYPO?'])
                end

            end

    end




