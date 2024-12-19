% 清除工作区变量，清空命令窗口，并关闭所有图形窗口
clear; clc; close all;
% 读取图像
[filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
if ischar(filename)
    img = imread(fullfile(pathname, filename));
else
    error('没有选择文件');
end



% 显示原始灰度图像
figure;
subplot(2,2,1); imshow(uint8(img_gray)); title('原始灰度图像');

% 线性变换：对比度拉伸
min_val = min(img_gray(:));
max_val = max(img_gray(:));
img_linear = (img_gray - min_val) / (max_val - min_val) * 255;
subplot(2,2,2); imshow(uint8(img_linear)); title('线性变换后的图像');

% 对数变换：对比度增强
c = 255 / log(1 + max(img_gray(:))); % 计算缩放因子c
img_log = c * log(double(img_gray) + 1);
img_log = uint8(img_log); % 转换回uint8以显示
subplot(2,2,3); imshow(img_log); title('对数变换后的图像');

% 指数变换：对比度增强
gamma = 0.5; % 可调整的参数，用于控制指数曲线的形状
c = 255 / (255^gamma);
img_exp = c * img_gray.^gamma;
img_exp = uint8(img_exp); % 转换回uint8以显示
subplot(2,2,4); imshow(img_exp); title('指数变换后的图像');

% 确保所有处理后的图像值都在合理的范围内 [0, 255]
img_linear = min(max(img_linear, 0), 255);
img_log = min(max(img_log, 0), 255);
img_exp = min(max(img_exp, 0), 255);

% 再次显示确保范围正确的图像
figure;
subplot(2,2,1); imshow(uint8(img_gray)); title('原始灰度图像');
subplot(2,2,2); imshow(uint8(img_linear)); title('线性变换后的图像');
subplot(2,2,3); imshow(uint8(img_log)); title('对数变换后的图像');
subplot(2,2,4); imshow(uint8(img_exp)); title('指数变换后的图像');