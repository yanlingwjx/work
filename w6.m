function extract_target_from_image()
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

    % 5. 边界检测（可选）
    edges = edge(double(bw_closed), 'canny'); % 使用Canny算子检测边缘

    % 6. 用户交互式选择目标区域
    figure;
    imshow(img);
    title('请在图像中选择目标区域');
    roi = imrect();
    wait(roi); % 等待用户完成选择

    % 获取用户选择的矩形位置
    if ismethod(roi, 'getPosition') % 检查是否支持getPosition方法
        roiPosition = round(roi.getPosition());
    else
        error('无法获取ROI位置');
    end

    % 检查用户是否取消了选择或选择了无效区域
    if isempty(roiPosition) || any(roiPosition <= 0) || ...
       (roiPosition(1)+roiPosition(3) > size(gray_img, 2)) || ...
       (roiPosition(2)+roiPosition(4) > size(gray_img, 1))
        error('选择的区域无效或为空');
    end

    % 提取用户选择的目标区域
    targetRegion = imcrop(gray_img, roiPosition);

    % 7. 可视化结果
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');
    subplot(2,3,2); imshow(gray_img, []); title('灰度图像');
    subplot(2,3,3); imshow(bw_img); title('二值化图像');
    subplot(2,3,4); imshow(bw_closed); title('清理后的二值图像');
    subplot(2,3,5); imshow(edges); title('边缘检测结果');
    subplot(2,3,6); imshow(targetRegion); title('用户选择的目标区域');

    % 如果需要保存结果，可以取消下面这行的注释
    % imwrite(uint8(mask .* 255), fullfile(pathname, 'extracted_target.png'));

    % 8. 特征提取：LBP 和 HOG
    % 设置LBP参数
    P = 8; R = 1;

    % 提取原始图像的LBP和HOG特征
    lbpFeatureOriginal = computeLBP(gray_img, P, R);
    [hogFeatureOriginal, hogVisualizationOriginal] = extractHOGFeatures(double(gray_img), 'CellSize', [8 8]);

    % 提取目标区域的LBP和HOG特征
    lbpFeatureTarget = computeLBP(targetRegion, P, R);
    [hogFeatureTarget, hogVisualizationTarget] = extractHOGFeatures(double(targetRegion), 'CellSize', [8 8]);

    % 9. 可视化特征
    figure;
    subplot(2,2,1); imshow(img); hold on; plot(hogVisualizationOriginal); title('原始图像的HOG特征');
    subplot(2,2,2); imshow(targetRegion); hold on; plot(hogVisualizationTarget); title('目标区域的HOG特征');
    subplot(2,2,3); imshow(mat2gray(lbpFeatureOriginal)); title('原始图像的LBP特征');
    subplot(2,2,4); imshow(mat2gray(lbpFeatureTarget)); title('目标区域的LBP特征');
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