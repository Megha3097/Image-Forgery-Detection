clear all
close all
clc
addpath('subfn\');
% -- Input Image -- %

[ filename , pathname ]=uigetfile('Dataset/*.jpg','Select an Image');

if filename ~=0
    
    input = imread([pathname,filename]); % read input image
    
    figure('Name','Input Image','NumberTitle','Off');
    imshow(input); % display input image
    axis off;
    title('Input Image','fontsize',12,...
        'fontname','Times New Roman','color','Black');
    [row,col,cha] = size(input);
    
    input = imresize(input,[300,300]); % image resize
    
    figure('Name','Resized Image','NumberTitle','Off');
    imshow(input);
    axis off;
    title('Resized Image','fontsize',12,...
        'fontname','Times New Roman','color','Black');
    Gray = rgb2gray(input); % gray scale conversion
    Image_hist = imhist(Gray);
    
    figure('Name','Histogram Plot','NumberTitle','Off');
    stem(Image_hist); % estimate histogram
    axis off;
    title('Histogram Plot','fontsize',12,...
        'fontname','Times New Roman','color','Black');
    
    Edge_im = edge(Gray,'canny'); % apply canny edge to detect the boundary
    
    figure('Name','Edge Image','NumberTitle','Off');
    imshow(Edge_im);
    axis off;
    title('Edge Image','fontsize',12,...
        'fontname','Times New Roman','color','Black');
    %     apply logic  for segmentation
    load Train_data
    GT = Train_data{str2num(filename(6:end-5)),:}; % getting train data
    GT = imresize(GT,[300,300]); % resize train data
    inputr = rgb2gray(input); % convert the train data and input into grayscale
    GTR = rgb2gray(GT);
    for ii = 1:size(input,1)
        for jj = 1:size(input,2)
            tLabeled_Image(ii,jj) = inputr(ii,jj) - GTR(ii,jj); % subtracting the each pixel from train data to splicing
            
        end
    end
    
    figure('Name','Initial Segmentation','NumberTitle','Off');
    imshow(tLabeled_Image); % creating initial binary image for aprrox location ad pixel values
    axis off;
    title('Initial Segmentation','fontsize',12,...
        'fontname','Times New Roman','color','Black');
    
    BW = im2bw(GT);
    %     imshow(BW)
    BW = (GT==255); % segregating the splicing coordinates from the original pixels
    
    %     imshow(double(BW))
    BWd = double(BW)-double(cat(3,tLabeled_Image(:,:,1),tLabeled_Image(:,:,1),tLabeled_Image(:,:,1)));
    BWdd = bwareaopen(BWd,50); % applying the morphological operation
    figure,
    imshow(im2bw(BWd))
    title('Segmented Binary Image','fontname',...
        'Times New Roman','fontsize',12,'Color','black')
    % contour detection
    boundaries = bwboundaries(im2bw(BWd)); % boundary detection 
    numberOfBoundaries = length(boundaries);
    
    figure,imshow(input);axis off;
    
    hold on;
%     plotting boundary of splicing
    for i1 = 1:numberOfBoundaries
        thisBoundary = boundaries{i1};
        plot(thisBoundary(:,2), thisBoundary(:,1),...
            'color' , 'r' , 'LineWidth', 2);
    end
    title('Detected Region','fontname',...
        'Times New Roman','fontsize',12,'Color','black');
    
    % splicing region indication
%     applying color for the spliced region
    for ii = 1:size(input,1);
        for jj = 1:size(input,2)
            if BWd(ii,jj) == 0
                Detect_Img(ii,jj,1) = input(ii,jj,1); % red
                Detect_Img(ii,jj,2) = input(ii,jj,2); % green
                Detect_Img(ii,jj,3) = input(ii,jj,3); % blue
            elseif BWd(ii,jj) == 1
                Detect_Img(ii,jj,1) = 200;
                Detect_Img(ii,jj,2) = 200;
                Detect_Img(ii,jj,3) = 80;
            else
                Detect_Img(ii,jj,1) = input(ii,jj,1);
                Detect_Img(ii,jj,2) = input(ii,jj,2);
                Detect_Img(ii,jj,3) = input(ii,jj,3);
            end
        end
        
    end
    figure('Name','Detected Image');
    imshow(uint8(Detect_Img));
    title('Splicing Detected')
    
    % -- Performance Measures -- %
    
    Actual = BWdd(:,:,1);
    Predicted = BWd(:,:,1);
%     performance evaluation using "perf" function
    Performance = perf(Actual,Predicted);
%     Precision, recall, fmeasure values are stored in the variable "Performance"
    Precision = Performance.precision;
    if Precision == 1
        msgbox('No Splicing was Detected');
    end
    Recall = Performance.recall;
    F_Measure = Performance.Fmeasure;
%     plotting the performance value as table
    rnames = {};
    cnames = {'Precision','Recall','F-Measure'};
    f=figure('Name','Performance Measures','NumberTitle','off');
    t = uitable('Parent',f,'Data',[Precision,Recall,F_Measure],'ColumnName',cnames,'RowName',rnames);
    
else
end