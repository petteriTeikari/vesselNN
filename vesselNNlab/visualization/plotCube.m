function plotCube()

    path = '/home/petteri/Dropbox/Drafts_w_Biblio/vesselNN_lyx/figures/schematics';
    
    i = 0;
    i = i + 1; imName{i} = 'poon2015_mixedSize1_BM4D_denoised.tif';
    i = i + 1; imName{i} = 'poon2015_mixedSize1_manualLabel_v2.tif';
    i = i + 1; imName{i} = 'VD2D.tif';
    i = i + 1; imName{i} = 'VD2D3D.tif';
    
    topSlice = 14;
    noOfSlices = topSlice;
    dpi = 300;
    aa = 2; % anti-alias level
    
    % how the cube is rotated in space
    angles = [-74 40];
    
    for i = 1 : length(imName)
        
        if i <= length(imName)
        
            % import
            [~, imageStack, ~, ~] = importMicroscopyFile(imName{i}, path);
            im = uint8(imageStack{1}{1});  
            
        else
            
            % you can weigh here
            
        end
        
        % visualize
        visualize_plotStackAsCube(im, imName{i}, path, topSlice, noOfSlices, dpi, aa, angles)
        
    end

function visualize_plotStackAsCube(im, imName, path, topSlice, noOfSlices, dpi, aa, angles)

    % http://www.mathworks.com/matlabcentral/answers/32070-rgb-images-on-a-3d-cube
    im = im(:,:,topSlice-noOfSlices+1:topSlice);
    
    % create three 2D images to the side
    top = im(:,:,end);
    front = squeeze(im(:,end,:)); 
    side = squeeze(im(end,:,:));
    whos
    
    cdata_top = top;
    cdata_front = front;
    cdata_side = side;
    
    figure('Color', 'w')
    
    % top
    surface([-1 1; -1 1], [-1 -1; 1 1], [1 1; 1 1], ...
        'FaceColor', 'texturemap', 'CData', cdata_top );
    
    % front
    surface([-1 1; -1 1], [-1 -1; -1 -1], [-1 -1; 1 1], ...
        'FaceColor', 'texturemap', 'CData', cdata_front);
    
    % side
    surface([-1 -1; -1 -1], [-1 1; -1 1], [-1 -1; 1 1], ...
        'FaceColor', 'texturemap', 'CData', cdata_side );
    
    daspect([1 1 0.5*round(size(im,2)/size(im,3))])
    axis off
    view(angles);
    colormap gray    
    drawnow
    
    
    export_fig(fullfile(path, strrep(imName, '.tif', '_cube.png')), ['-r', num2str(dpi)], ['-a', num2str(aa)])