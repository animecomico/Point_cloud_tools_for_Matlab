function obj = estimateRedundancy(obj, trafoModel)

% Initialize problem (call constructor method)
adj = glsAdj2;

% Similarity transformation ----------------------------------------------------

if strcmpi(trafoModel, 'sim')

    % Add trafo parameters -----------------------------------------------------

    for i = 1:2

        % Add 3 angle parameters
        [adj, idxPrm_opk{i}] = adj.addPrm('x0'   , {0 0 0}, ...
                                          'label', {'om' 'ph' 'ka'}, ...
                                          'ref'  , {num2str(i)});

        % Add 3 translation parameters
        [adj, idxPrm_t{i}] = adj.addPrm('x0'   , {0 0 0}, ...
                                        'label', {'tx' 'ty' 'tz'}, ...
                                        'ref'  , {num2str(i)});

        % Add 1 scale parameter
        [adj, idxPrm_m{i}] = adj.addPrm('x0'    , {1}, ...
                                        'label' , {'m'}, ...
                                        'ref'   , {num2str(i)});

    end

    % Set parameters of first pc constant
    adj.prm.const(idxPrm_opk{1}(:)) = 1; % affine parameters
    adj.prm.const(idxPrm_t{1}(:))   = 1; % translation
    adj.prm.const(idxPrm_m{1}(:))   = 1; % scale

    % Get sigma of correspondences
    sigdp_priori = sqrt( obj.A1.nx.^2*obj.sigX1(1)^2 + obj.A1.nx.^2*obj.sigX2(1)^2 + ...
                         obj.A1.ny.^2*obj.sigX1(2)^2 + obj.A1.ny.^2*obj.sigX2(2)^2 + ...
                         obj.A1.nz.^2*obj.sigX1(3)^2 + obj.A1.nz.^2*obj.sigX2(3)^2);

    % Consider weights
    sigdp_priori = sigdp_priori./sqrt(obj.A.w);

    % Add observations
    [adj, idxObs_X1] = adj.addObs('l'    , {obj.X1(:,1) obj.X1(:,2) obj.X1(:,3)}, ...
                                  'const', {true});

    [adj, idxObs_X2] = adj.addObs('l'    , {obj.X2(:,1) obj.X2(:,2) obj.X2(:,3)}, ...
                                  'const', {true});

    [adj, idxObs_n1] = adj.addObs('l'    , {obj.A1.nx obj.A1.ny obj.A1.nz}, ...
                                  'const', {true});

    [adj, idxObs_dp] = adj.addObs('l'          , {zeros(size(obj.X1,1),1)}, ...
                                  'sigl_priori', {sigdp_priori});

    % Add constraints
    adj = adj.addCon('fun', @conSimPoint2Plane, ...
                     'prm', struct('om1', idxPrm_opk{1}(1), ...
                                   'ph1', idxPrm_opk{1}(2), ...
                                   'ka1', idxPrm_opk{1}(3), ...
                                   'tx1', idxPrm_t{1}(1)  , ...
                                   'ty1', idxPrm_t{1}(2)  , ...
                                   'tz1', idxPrm_t{1}(3)  , ...
                                   'm1' , idxPrm_m{1}     , ...        
                                   'om2', idxPrm_opk{2}(1), ...
                                   'ph2', idxPrm_opk{2}(2), ...
                                   'ka2', idxPrm_opk{2}(3), ...
                                   'tx2', idxPrm_t{2}(1)  , ...
                                   'ty2', idxPrm_t{2}(2)  , ...
                                   'tz2', idxPrm_t{2}(3)  , ...
                                   'm2' , idxPrm_m{2})    , ...
                     'obs', struct('x1' , idxObs_X1(:,1)  , ...
                                   'y1' , idxObs_X1(:,2)  , ...
                                   'z1' , idxObs_X1(:,3)  , ...
                                   'x2' , idxObs_X2(:,1)  , ...
                                   'y2' , idxObs_X2(:,2)  , ...
                                   'z2' , idxObs_X2(:,3)  , ...
                                   'nx1', idxObs_n1(:,1)  , ...
                                   'ny1', idxObs_n1(:,2)  , ...
                                   'nz1', idxObs_n1(:,3)  , ...
                                   'dp' , idxObs_dp));

end

% Affine transformation --------------------------------------------------------

if strcmpi(trafoModel, 'aff')

    % Add trafo parameters -----------------------------------------------------
    
    for i = 1:2

        % Add 9 affine parameters
        [adj, idxPrm_a{i}] = adj.addPrm('x0'    , {1 0 0 0 1 0 0 0 1}, ...
                                        'label' , {'a11' 'a12' 'a13' 'a21' 'a22' 'a23' 'a31' 'a32' 'a33'}, ...
                                        'ref'   , {num2str(i)});

        % Add 3 translation parameters
        [adj, idxPrm_t{i}] = adj.addPrm('x0'    , {0 0 0}, ...
                                        'label' , {'tx' 'ty' 'tz'}, ...
                                        'ref'   , {num2str(i)});

    end

    % Set parameters of first pc constant
    adj.prm.const(idxPrm_a{1}(:)) = 1; % affine parameters
    adj.prm.const(idxPrm_t{1}(:)) = 1; % translation
    
    % Get sigma of correspondences
    sigdp_priori = sqrt( obj.A1.nx.^2*obj.sigX1(1)^2 + obj.A1.nx.^2*obj.sigX2(1)^2 + ...
                         obj.A1.ny.^2*obj.sigX1(2)^2 + obj.A1.ny.^2*obj.sigX2(2)^2 + ...
                         obj.A1.nz.^2*obj.sigX1(3)^2 + obj.A1.nz.^2*obj.sigX2(3)^2);

    % Consider weights
    sigdp_priori = sigdp_priori./sqrt(obj.A.w);

    % Add observations
    [adj, idxObs_X1] = adj.addObs('l'    , {obj.X1(:,1) obj.X1(:,2) obj.X1(:,3)}, ...
                                  'const', {true});

    [adj, idxObs_X2] = adj.addObs('l'    , {obj.X2(:,1) obj.X2(:,2) obj.X2(:,3)}, ...
                                  'const', {true});

    [adj, idxObs_n1] = adj.addObs('l'    , {obj.A1.nx obj.A1.ny obj.A1.nz}, ...
                                  'const', {true});

    [adj, idxObs_dp] = adj.addObs('l'          , {zeros(size(obj.X1,1),1)}, ...
                                  'sigl_priori', {sigdp_priori});

    % Add constraints
    adj = adj.addCon('fun', @conAffPoint2PlaneSimple, ...
                     'prm', struct('a111', idxPrm_a{1}(1) , ...
                                   'a121', idxPrm_a{1}(2) , ...
                                   'a131', idxPrm_a{1}(3) , ...
                                   'a211', idxPrm_a{1}(4) , ...
                                   'a221', idxPrm_a{1}(5) , ...
                                   'a231', idxPrm_a{1}(6) , ...
                                   'a311', idxPrm_a{1}(7) , ...
                                   'a321', idxPrm_a{1}(8) , ...
                                   'a331', idxPrm_a{1}(9) , ...
                                   'a112', idxPrm_a{2}(1) , ...
                                   'a122', idxPrm_a{2}(2) , ...
                                   'a132', idxPrm_a{2}(3) , ...
                                   'a212', idxPrm_a{2}(4) , ...
                                   'a222', idxPrm_a{2}(5) , ...
                                   'a232', idxPrm_a{2}(6) , ...
                                   'a312', idxPrm_a{2}(7) , ...
                                   'a322', idxPrm_a{2}(8) , ...
                                   'a332', idxPrm_a{2}(9) , ...
                                   'tx1' , idxPrm_t{1}(1) , ...
                                   'ty1' , idxPrm_t{1}(2) , ...
                                   'tz1' , idxPrm_t{1}(3) , ...
                                   'tx2' , idxPrm_t{2}(1) , ...
                                   'ty2' , idxPrm_t{2}(2) , ...
                                   'tz2' , idxPrm_t{2}(3)), ...
                     'obs', struct('x1'  , idxObs_X1(:,1)   , ...
                                   'y1'  , idxObs_X1(:,2)   , ...
                                   'z1'  , idxObs_X1(:,3)   , ...
                                   'x2'  , idxObs_X2(:,1)   , ...
                                   'y2'  , idxObs_X2(:,2)   , ...
                                   'z2'  , idxObs_X2(:,3)   , ...
                                   'nx1' , idxObs_n1(:,1)   , ...
                                   'ny1' , idxObs_n1(:,2)   , ...
                                   'nz1' , idxObs_n1(:,3)   , ...
                                   'dp'  , idxObs_dp));

end

% Solve and save results -------------------------------------------------------

% Solve adjustment!
adj = adj.solve;

% Save redundancy parts
obj.A.red = adj.obs.r(idxObs_dp);

end