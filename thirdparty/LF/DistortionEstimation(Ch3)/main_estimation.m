clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jinsun Park (zzangjinsun@gmail.com / zzangjinsun@kaist.ac.kr)
% Computer Vision and Image Processing Lab, KAIST, KOREA
%
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% Hae-Gon Jeon, Jaesik Park, Gyeongmin Choe, Jinsun Park, Yunsu Bok, Yu-Wing Tai and In So Kweon
% IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), Jun 2015
%
% This script estimates depth distortion by assuming center point is
% focused.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('subfunctions');

% Image path list
FOLDER = 'checker_15cm';
           
% Light field property
offset = 3;
ref = offset+1;
N = 2*offset+1;

% Estimation parameters for Lytro
GRID = 50;                                      % Number of grid
DIVISION = 0.05;                                % Pixel movement division
RANGE = [-5, 5];                                % Pixel movement range
TH_DISPARITY = DIVISION/2;                      % Minimum meaningful disparity
LAMBDA = 1;                                     % Relaxation coefficient
DISP = 1;                                       % Display flag
MAXITER = 1;                                    % Maximum iteration
N_FFT = 2^10;                                   % Point of FFT
MARGIN = 10;                                    % Boundary margin
TH_G = 140;                                     % Gradient threshold
FOCUS = [0.5, 0.5];                             % Relative focused point position
INITIALIZATION = 1;                             % Initialization flag
ft = 'poly22';                                  % Surface fitting model



tic



% Set image path
PATH_IMAGE = ['image\',FOLDER];

% Load images
LF = Make4DLF(PATH_IMAGE, 'png');

% Contrast adjustment
pixel_max = 250;
LF = LF*pixel_max/max(LF(:));

% Get the size of sub-aperture image
[~, ~, R, C, CH] = size(LF);

% Calculate focused point
CENTER = round([R*FOCUS(1), C*FOCUS(2)]);
[XX, YY] = meshgrid(1:C, 1:R);

ROWS = round(linspace(1,R+1,GRID+1));
COLS = round(linspace(1,C+1,GRID+1));

%% Calculate focused point disparity first to obtain pivot values
if(INITIALIZATION ~= 0)
    PIVOT_R = zeros(1,CH);
    PIVOT_C = zeros(1,CH);

    if(DISP ~= 0)
        fprintf(1,'Focal point initialization started.\n');
    end
    for ch=1:CH
        if(DISP ~= 0)
            fprintf(1,'CH : %3.0d / %3.0d\n',ch,CH);
        end
        % Row-wise estimation
        D_R_temp = zeros(R,C);
        D_R_ind = false(R,C);

        str_length = 0;
        for grid=1:GRID
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'ROW Grid : %5.0d / %5.0d\n',grid,GRID);
            end

            G_stack = zeros(N,C);

            r_center = round((ROWS(grid)+ROWS(grid+1))/2);

            % Grid gradient stacking
            for r=ROWS(grid):(ROWS(grid+1)-1)
                EPI = squeeze(LF(ref,:,r,:,ch));

                G = EPI(:,2:end) - EPI(:,1:(end-1));
                G = [G, G(:,end)];

                G_stack = G_stack + abs(G);
            end

            [SLOPE, INDEX] = ShearingSlopeEstimation(G_stack, RANGE, DIVISION, N_FFT, MARGIN, TH_G, 0);

            D_R_temp(r_center,INDEX) = SLOPE;
            D_R_ind(r_center,INDEX) = 1;
        end

        % Disparity fitting
        F = fit([XX(D_R_ind(:)), YY(D_R_ind(:))], D_R_temp(D_R_ind(:)), ft);
        D_R_temp_fit = reshape(F(XX(:), YY(:)),[R,C]);

        % Pivot value
        PIVOT_R(ch) = D_R_temp_fit(CENTER(1), CENTER(2));

        if(DISP ~= 0)
            fprintf(1,'Pivot value : %5.5f\n',PIVOT_R(ch));
        end



        % Column-wise estimation
        D_C_temp = zeros(R,C);
        D_C_ind = false(R,C);

        str_length = 0;
        for grid=1:GRID
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'COL Grid : %5.0d / %5.0d\n',grid,GRID);
            end
            G_stack = zeros(N,R);

            c_center = round((COLS(grid)+COLS(grid+1))/2);

            % Grid gradient stacking
            for c=COLS(grid):(COLS(grid+1)-1)
                EPI = squeeze(LF(:,ref,:,c,ch));

                G = EPI(:,2:end) - EPI(:,1:(end-1));
                G = [G, G(:,end)];

                G_stack = G_stack + abs(G);
            end

            [SLOPE, INDEX] = ShearingSlopeEstimation(G_stack, RANGE, DIVISION, N_FFT, MARGIN, TH_G, 0);

            D_C_temp(INDEX,c_center) = SLOPE;
            D_C_ind(INDEX,c_center) = 1;
        end

        % Disparity fitting
        F = fit([XX(D_C_ind(:)), YY(D_C_ind(:))], D_C_temp(D_C_ind(:)), ft);
        D_C_temp_fit = reshape(F(XX(:), YY(:)),[R,C]);

        % Pivot value
        PIVOT_C(ch) = D_C_temp_fit(CENTER(1), CENTER(2));

        if(DISP ~= 0)
            fprintf(1,'Pivot value : %5.5f\n',PIVOT_C(ch));
        end



        % LF Initialization with pivot value
        if(DISP ~= 0)
            fprintf(1,'Adjusting EPI with pivot value.\n');
        end

        str_length = 0;
        for r=1:R
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'ROW : %5.0d / %5.0d\n',r,R);
            end
            EPI = squeeze(LF(ref,:,r,:,ch));
            EPI_adj = EPIShearingPixel(EPI, repmat(PIVOT_R(ch),1,C), N_FFT);
            LF(ref,:,r,:,ch) = EPI_adj;
        end

        str_length = 0;
        for c=1:C
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'COL : %5.0d / %5.0d\n',c,C);
            end
            EPI = squeeze(LF(:,ref,:,c,ch));
            EPI_adj = EPIShearingPixel(EPI, repmat(PIVOT_C(ch),1,R), N_FFT);
            LF(:,ref,:,c,ch) = EPI_adj;
        end
    end

    if(DISP ~= 0)
        fprintf(1,'Initialization finished.\n');
    end
end
% End of initialization

%% Estimation Start
% Separated light field for row and column-wise fitting
LF_ROW = LF;
LF_COL = LF;

% Disparities
D_R = zeros(R,C,CH);
D_C = zeros(R,C,CH);

% Previous values
D_R_prev = D_R;
D_C_prev = D_C;

for ch=1:CH
    if(DISP ~= 0)
        fprintf(1,'CH : %3.0d / %3.0d\n',ch,CH);
    end

    for iter=1:MAXITER
        if(DISP ~= 0)
            fprintf(1,'Iteration : %3.0d / %3.0d\n',iter,MAXITER);
        end

        D_R_temp = zeros(R,C);
        D_R_ind = false(R,C);

        % Grid gradient stacking
        str_length = 0;
        for grid=1:GRID
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'ROW Grid : %5.0d / %5.0d\n',grid,GRID);
            end

            G_stack = zeros(N,C);

            r_center = round((ROWS(grid)+ROWS(grid+1))/2);

            for r=ROWS(grid):(ROWS(grid+1)-1)
                EPI = squeeze(LF_ROW(ref,:,r,:,ch));

                G = EPI(:,2:end) - EPI(:,1:(end-1));
                G = [G, G(:,end)];

                G_stack = G_stack + abs(G);
            end

            [SLOPE, INDEX] = ShearingSlopeEstimation(G_stack, RANGE, DIVISION, N_FFT, MARGIN, TH_G, 0);

            D_R_temp(r_center,INDEX) = SLOPE;
            D_R_ind(r_center,INDEX) = 1;
        end

        % Disparity fitting
        F = fit([XX(D_R_ind(:)), YY(D_R_ind(:))], D_R_temp(D_R_ind(:)), ft);
        D_R_temp_fit = reshape(F(XX(:), YY(:)),[R,C]);

        D_R_diff_max = max(abs(D_R_temp_fit(:)));

        if(D_R_diff_max < TH_DISPARITY)
            break;
        end

        % Disparity merging
        D_R_prev(:,:,ch) = D_R(:,:,ch);
        D_R(:,:,ch) = D_R(:,:,ch) + LAMBDA*D_R_temp_fit;

        if(DISP ~= 0)
            figure(1);
            subplot(1,2,1)
            surf(D_R_temp); xlabel('C'); ylabel('R'); title('D\_R\_grid'); set(gca,'YDir','reverse');
            subplot(1,2,2)
            surf(D_R_temp_fit); xlabel('C'); ylabel('R'); title('D\_R\_fit'); set(gca,'YDir','reverse');

            fprintf(1,'ROW / Max : %5.5f, Min : %5.5f, Max change : %5.5f\n',max(max(D_R(:,:,ch))), min(min(D_R(:,:,ch))), D_R_diff_max);
        end



        % EPI adjusting
        str_length = 0;
        for r=1:R
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'ROW : %5.0d / %5.0d\n',r,R);
            end
            EPI = squeeze(LF_ROW(ref,:,r,:,ch));
            EPI_adj = EPIShearingPixel(EPI, D_R(r,:,ch), N_FFT);
            LF_ROW(ref,:,r,:,ch) = EPI_adj;
        end

    end



    for iter=1:MAXITER
        if(DISP ~= 0)
            fprintf(1,'Iteration : %3.0d / %3.0d\n',iter,MAXITER);
        end

        D_C_temp = zeros(R,C);
        D_C_ind = false(R,C);

        % Grid gradient stacking
        str_length = 0;
        for grid=1:GRID
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'COL Grid : %5.0d / %5.0d\n',grid,GRID);
            end

            G_stack = zeros(N,R);

            c_center = round((COLS(grid)+COLS(grid+1))/2);

            for c=COLS(grid):(COLS(grid+1)-1)
                EPI = squeeze(LF_COL(:,ref,:,c,ch));

                G = EPI(:,2:end) - EPI(:,1:(end-1));
                G = [G, G(:,end)];

                G_stack = G_stack + abs(G);
            end

            [SLOPE, INDEX] = ShearingSlopeEstimation(G_stack, RANGE, DIVISION, N_FFT, MARGIN, TH_G, 0);

            D_C_temp(INDEX,c_center) = SLOPE;
            D_C_ind(INDEX,c_center) = 1;
        end

        % Disparity fitting
        F = fit([XX(D_C_ind(:)), YY(D_C_ind(:))], D_C_temp(D_C_ind(:)), ft);
        D_C_temp_fit = reshape(F(XX(:), YY(:)),[R,C]);

        D_C_diff_max = max(abs(D_C_temp_fit(:)));

        if(D_C_diff_max < TH_DISPARITY)
            break;
        end

        % Disparity merging
        D_C_prev(:,:,ch) = D_C(:,:,ch);
        D_C(:,:,ch) = D_C(:,:,ch) + LAMBDA*D_C_temp_fit;

        if(DISP ~= 0)
            figure(2);
            subplot(1,2,1)
            surf(D_C_temp); xlabel('C'); ylabel('R'); title('D\_C\_grid'); set(gca,'YDir','reverse');
            subplot(1,2,2)
            surf(D_C_temp_fit); xlabel('C'); ylabel('R'); title('D\_C\_fit'); set(gca,'YDir','reverse');

            fprintf(1,'COL / Max : %5.5f, Min : %5.5f, Max change : %5.5f\n',max(max(D_C(:,:,ch))), min(min(D_C(:,:,ch))), D_C_diff_max);
        end



        % EPI adjusting
        str_length = 0;
        for c=1:C
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'COL : %5.0d / %5.0d\n',c,C);
            end
            EPI = squeeze(LF_COL(:,ref,:,c,ch));
            EPI_adj = EPIShearingPixel(EPI, D_C(:,c,ch), N_FFT);
            LF_COL(:,ref,:,c,ch) = EPI_adj;
        end

    end
end

save(['data\',FOLDER,'.mat'], 'D_R', 'D_C');



toc
            
                
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    