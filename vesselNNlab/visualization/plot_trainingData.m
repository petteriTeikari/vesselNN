function plot_trainingData()

    imFolder = '/home/petteri/znnData/dataset/vessel_2PM/denoised';
    
    % get image listing
    fileListing_im = dir(fullfile(imFolder, '*.tif'));
    
    % Visualize all as MIPs
    visualize_trainingStacks_MIP(imFolder, fileListing_im)
    
    
    
    function visualize_trainingStacks_MIP(imFolder, fileListing)
        
        rows = 3; cols = 4; % manual quick'n'dirty
        fig = figure('Color', 'w');
        
            scrsz = get(0,'ScreenSize'); % get screen size for plotting
            set(fig,  'Position', [0.10*scrsz(3) 0.01*scrsz(4) 0.60*scrsz(3) 0.90*scrsz(4)])
        
        for file = 1 : length(fileListing)
            
            % import the image data
            [~, imageStack, ~, ~] = importMicroscopyFile(fileListing(file).name, imFolder);
            im = double(imageStack{1}{1});
            
            % MIP
            MIP{file} = max(im, [], 3);
            
            % MEAN
            meanStack{file} = mean(im, 3);
            
            % Normalize
            MIP{file} = MIP{file} / max(MIP{file}(:));
            meanStack{file} = meanStack{file} / max(meanStack{file}(:));

            
            sp(file) = subplot(rows,cols,file);
                imH(file) = imshow(MIP{file}, []);
                    tit(file) = title(['Stack #', num2str(file)]);
            
            drawnow
                    
        end
        
        % Style
        
        % Ubuntu, try:
        % sudo apt-get install xfonts-75dpi xfonts-100dpi
        % if fonts not displaying correctly
        
        dpi = 200;
        aa = 2; % anti-alias level
        export_fig(fullfile(imFolder, 'MIP_traininSet.png'), ['-r', num2str(dpi)], ['-a', num2str(aa)])
        
        %{
        fig2 = figure('Color', 'w');
            set(fig2,  'Position', [0.30*scrsz(3) 0.01*scrsz(4) 0.60*scrsz(3) 0.90*scrsz(4)])

            for file = 1 : length(fileListing)
                sp(file) = subplot(rows,cols,file);
                imH(file) = imshow(meanStack{file}, []);
                    tit(file) = title(['Stack #', num2str(file)]);
            
                drawnow
            end
        %}