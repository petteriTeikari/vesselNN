function metrics = parse_resultsXML(fileXML)

    if nargin == 0       
        fileXML = '/home/petteri/Dropbox/vesselNN/3rdParty/EvaluateSegmentation/builds/results.xml';
    end
    
    % Use xml2struct by Wouter Falkena
    % http://www.mathworks.com/matlabcentral/fileexchange/28518-xml2struct
    
    s = xml2struct(fileXML);
    
    % ground truth
    gt = s.measurement.fixed_dash_image.Attributes;
    
    % segmentation
    segm = s.measurement.moving_dash_image.Attributes;
    
    % metrics
    metrics = s.measurement.metrics;
    
    % timing
    timing = s.measurement.time.Attributes;
    
    % dimension
    dimension = s.measurement.dimention.Attributes; % note the typo [sic!]
        % note, starts counting from 0, so dimensions of
        % 511x511x14, actually mean 512x512x15
    
    selectedFields = 'all';
    % metrics = parse_XMLtoMat(metrics, selectedFields)
    
    selectedFields = {'RNDIND'; 'VARINFO'};
    % metrics = parse_XMLtoMat(metrics, selectedFields)
   
    