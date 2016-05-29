function [region, u] = segment_asetsPreWrapper3D(imageStack, vesselnessStack, sliceIndex, options)
   
    %% EDGES

        % find edges from vesselness stack that could be used as
        % regularization term for the segmentation
        %{
        edges = zeros(size(vesselnessStack));
        for i = 1 : size(vesselnessStack,3)
            edges(:,:,i) = segment_findEdges(vesselnessStack(:,:,i), 0);
        end        
        edges = abs(vesselnessStack);
        edges = edges / max(edges(:));  
        %}
        edges = vesselnessStack;
        
    %% Create the init region (from vessel)
    
        regionInit = segment_createRegionFromVessel(vesselnessStack);

    %% SEGMENTATION
        
        % actual call of the segmentation
        fileOutBase = 'iter3D_';
        visualize3D = true; 
        visualizeON = false;
        
        % Parameters
        maxLevelSetIterations = 15; % number of maximum time steps
        tau = 50; % speed parameter
        w1 = 0.2; % weight parameter for intensity data term
        w2 = 0.3; % weight parameter for the speed data term
        w3 = 0.5; % weight parameter for the vesselness
        
        % 6. Set up the parameters for the max flow optimizer:
        % [1] graph dimension 1
        % [2] graph dimension 2
        % [3] number of maximum iterations for the optimizer (default 200)
        % [4] an error bound at which we consider the solver converged (default
        %     1e-5)
        % [5] c parameter of the multiplier (default 0.2)
        % [6] step 7size for the gradient descent step when calulating the spatial
        %     flows p(x) (default 0.16)        
        [sx, sy, sz] = size(imageStack);
        maxIter = 200;
        errorBound = 1e-5;
        cMultiplier = 0.2;
        stepSize = 0.16;
        pars = [sx; sy; sz; maxIter; errorBound; cMultiplier; stepSize];
             
        % for creating alpha from the edges
        regWeight1 = 0.005; regWeight2 = 0.01; regWeight3 = 50;
        
        % Actual call
        secondPass = false;
        imgForSegmentation = imageStack;

        [region, u] = segment_asetsWrapper3D(imgForSegmentation, vesselnessStack, edges, regionInit, ...
                                         maxLevelSetIterations, tau, w1, w2, w3, pars, ...
                                         regWeight1, regWeight2, regWeight3, ...
                                         secondPass, sliceIndex, visualize3D, visualizeON, fileOutBase);

     