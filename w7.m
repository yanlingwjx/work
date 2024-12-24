function w7()
    % 1. 加载图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
    else
        error('没有选择文件');
    end

    % 2. 预处理：将图像转换为灰度图像
    gray_img = rgb2gray(img);

    % 3. 自适应阈值分割
    adapthist_eq = adapthisteq(gray_img);
    bw_img = imbinarize(adapthist_eq);

    % 4. 形态学操作：开运算和闭运算
    se = strel('disk', 5); % 定义圆形结构元素，半径为5
    bw_opened = imopen(bw_img, se); % 开运算
    bw_closed = imclose(bw_opened, se); % 闭运算

    % 5. 边界检测
    edges = edge(double(bw_closed), 'canny'); % 使用Canny算子检测边缘
    
    % 创建掩膜：首先填充边缘内的区域，然后反转掩膜以提取目标
    filledEdges = imfill(edges, 'holes');
    mask = ~filledEdges; % 反转掩膜以选择目标而不是背景

    % 将掩膜应用到原始彩色图像上，提取目标
    targetFromMask = img;
    targetFromMask(repmat(~mask, [1, 1, size(img, 3)]) == 0) = 0; % 将背景设置为黑色

    % 6. 特征提取：LBP 和 HOG
    % 设置LBP参数
    P = 8; R = 1;

    % 提取原始图像的LBP和HOG特征
    lbpFeatureOriginal = computeLBP(gray_img, P, R);
    [hogFeatureOriginal, hogVisualizationOriginal] = extractHOGFeatures(double(gray_img), 'CellSize', [16 16]);

    % 提取目标区域的LBP和HOG特征
    gray_targetFromMask = rgb2gray(targetFromMask);
    lbpFeatureTarget = computeLBP(gray_targetFromMask, P, R);
    [hogFeatureTarget, hogVisualizationTarget] = extractHOGFeatures(double(gray_targetFromMask), 'CellSize', [16 16]);

    % 7. 可视化结果
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');
    subplot(2,3,4); imshow(targetFromMask, []); title('从背景中提取的目标');
    subplot(2,3,2); imshow(gray_img); hold on; plot(hogVisualizationOriginal); title('原始图像的HOG特征');
    subplot(2,3,5); imshow(gray_targetFromMask, []); hold on; plot(hogVisualizationTarget); title('目标区域的HOG特征');
    subplot(2,3,3); imshow(mat2gray(lbpFeatureOriginal)); title('原始图像的LBP特征');
    subplot(2,3,6); imshow(mat2gray(lbpFeatureTarget)); title('目标区域的LBP特征');
    hold off;

    % 局部函数定义开始
    function lbpFeature = computeLBP(grayImg, P, R)
        % 计算图像的LBP特征
        [rows, cols] = size(grayImg);
        lbpImg = zeros(rows, cols, 'uint8'); % 使用 uint8 类型

        for i = R+1:rows-R
            for j = R+1:cols-R
                centerPixel = double(grayImg(i, j));
                code = uint8(0); % 初始化为 uint8 类型
                for n = 0:P-1
                    theta = 2*pi*n/P;
                    xp = round(i + R*cos(theta));
                    yp = round(j - R*sin(theta));

                    if xp >= 1 && xp <= rows && yp >= 1 && yp <= cols
                        if double(grayImg(xp, yp)) >= centerPixel
                            code = bitset(code, P-n, 1, 'uint8'); % 设置第 (P-n) 位
                        end
                    end
                end
                lbpImg(i, j) = code;
            end
        end
        lbpFeature = lbpImg;
    end
end