function [F,V] = reconstruct_marchingCubes_wrapper(segmentation, isoValue, downSampleFactor, physicalScaling, debugPlot)

    % Using Marching Cubes algorithm from Matlab FEX
    % http://www.mathworks.com/matlabcentral/fileexchange/32506-marching-cubes

    % Note that even though the name of the algorithm is Marching
    % Cubes, it can be implemented differently still in different
    % programs, see for example Wiemann et al. (2015), 
    % http://dx.doi.org/10.1007/s10846-014-0155-1
    
    % min-max values of the segmented data
    minIn = min(segmentation(:)); 
    maxIn = max(segmentation(:));
    
    xgv = 1 : 1*downSampleFactor(1) : size(segmentation,1);
    ygv = 1 : 1*downSampleFactor(1) : size(segmentation,2);
    zgv = 1 : 1*downSampleFactor(2) : size(segmentation,3);
    
    % downsample segmentation
    segmentTemp = zeros(size(segmentation,1)/downSampleFactor(1), ...
                        size(segmentation,2)/downSampleFactor(1), ...
                        size(segmentation,3));
                    
    for i = 1 : size(segmentation,3)
       segmentTemp(:,:,i) = imresize(segmentation(:,:,i), 1/downSampleFactor(1));
    end
    segmentation = segmentTemp;

        % we could scale now the indices to physical units (see e.g.
        % import_parseMetadata.m), the x and y resolution are
        % conveniently ~1 um (and z direction 5 um).
        % TODO: add later to be automagic
        xgv = xgv * physicalScaling(1);
        ygv = ygv * physicalScaling(2);
        zgv = zgv * physicalScaling(3);

    [X,Y,Z] = meshgrid(xgv,ygv,zgv);        

    tic;
    isovalue = isoValue * maxIn;
    [F,V] = MarchingCubes(X,Y,Z,segmentation,isovalue);
    time.marchingCubes = toc;

        % Optional arguments COLORS ans COLS can be used to produce 
        % interpolated mesh face colors. For usage, see Matlab's isosurface.m. 
        % [F,V,col] = MarchingCubes(x,y,z,c,iso,colors)

    cubes_numberOfFaces = length(F);
    cubes_numberOfVertices = length(V);

    if debugPlot
        
        patch('Faces',F,'Vertices', V, ...            
                'edgecolor', 'none', ...
                'facecolor', 'red');

            view(34,-38);
            daspect([1,1,0.1]); axis tight
            camlight 
            lighting gouraud
            xlabel('X'); ylabel('Y'); zlabel('Z')
            titStr2 = sprintf('%s\n%s\n%s', ['"Marching Cubes" (isovalue = ', num2str(isovalue,4), ') with a lighting'], ...
                             ['no of faces = ', num2str(cubes_numberOfFaces), ', no of vertices = ', num2str(cubes_numberOfVertices)], ...
                             ['computation time = ', num2str(time.marchingCubes,3), ' sec']);
            title(titStr2)

        % save the figure
        % export_fig(fullfile('figuresOut', 'reconstructionTesting.png'), '-r300', '-a1')

    end
    
    % EXTRACT THE MESH (Standard isosurface)

        % Horribly slow (20x slower than the Marching Cubes below) 
        % especially for large stacks (i.e. 512 x 512 x 67),
        % Do not use!
    
        % extract from the volumetric segmentation data
        % http://www.mathworks.com/help/matlab/ref/isosurface.html
        %{
        isovalue = 0.1 * maxIn;
        tic;
        [f,v] = isosurface(segmentation,isovalue);
        time.isosurface = toc;
        
        isosurf_numberOfFaces = length(f);
        isosurf_numberOfVertices = length(v);

        % plot the vertices
        subplot(1,3,2)
        patch('Faces',f,'Vertices',v, ...            
                'edgecolor', 'none', ...
                'facecolor', 'red');
            
            view(34,-38);
            daspect([1,1,0.1]); axis tight
            camlight 
            lighting gouraud
            xlabel('X'); ylabel('Y'); zlabel('Z')
            titStr = sprintf('%s\n%s\n%s', ['"isosurface" (isovalue = ', num2str(isovalue,4), ') with a lighting'], ...
                             ['no of faces = ', num2str(isosurf_numberOfFaces), ', no of vertices = ', num2str(isosurf_numberOfVertices)], ...
                             ['computation time = ', num2str(time.isosurface,3), ' sec']);
            title(titStr)
        %}
           