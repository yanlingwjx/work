function transform_image_manual()
    % 打开一幅图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
    else
        error('没有选择文件');
    end

    % 显示原始图像
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');

    % 缩放图像
    scale_factor_1 = 0.75; % 缩小为原来的75%
    resized_img_1 = manual_resize(img, scale_factor_1);
    subplot(2,3,2); imshow(resized_img_1); title(['缩放比例: ', num2str(scale_factor_1)]);

    scale_factor_2 = 1.5; % 放大1.5倍
    resized_img_2 = manual_resize(img, scale_factor_2);
    subplot(2,3,3); imshow(resized_img_2); title(['缩放比例: ', num2str(scale_factor_2)]);

    % 旋转图像
    rotation_angle_1 = 45; % 逆时针旋转45度
    rotated_img_1 = manual_rotate(img, rotation_angle_1);
    subplot(2,3,4); imshow(rotated_img_1); title(['旋转角度: ', num2str(rotation_angle_1), '度']);

    rotation_angle_2 = -30; % 顺时针旋转30度
    rotated_img_2 = manual_rotate(img, rotation_angle_2);
    subplot(2,3,5); imshow(rotated_img_2); title(['旋转角度: ', num2str(rotation_angle_2), '度']);

    % 结合缩放和旋转
    combined_transformed_img = manual_rotate(manual_resize(img, 0.75), 45);
    subplot(2,3,6); imshow(combined_transformed_img); title('缩放与旋转结合');
end

function resized_img = manual_resize(img, scale_factor)
    % 获取原始图像尺寸
    [height, width, channels] = size(img);
    
    % 计算新的图像尺寸
    new_height = round(height * scale_factor);
    new_width = round(width * scale_factor);
    
    % 初始化输出图像
    if channels == 3
        resized_img = zeros(new_height, new_width, 3, 'uint8');
    else
        resized_img = zeros(new_height, new_width, 'uint8');
    end
    
    % 遍历新图像的每个像素，找到对应的原图像素位置并插值
    for y = 1:new_height
        for x = 1:new_width
            % 计算原图中的对应位置
            orig_x = (x - 0.5) / scale_factor + 0.5;
            orig_y = (y - 0.5) / scale_factor + 0.5;
            
            % 使用双线性插值获取新位置的像素值
            resized_img(y, x, :) = bilinear_interpolation(img, orig_x, orig_y, channels);
        end
    end
end

function pixel_value = bilinear_interpolation(img, x, y, channels)
    % 双线性插值函数
    height = size(img, 1);
    width = size(img, 2);

    % 确定四个最近邻点
    x1 = floor(x); x2 = min(ceil(x), width);
    y1 = floor(y); y2 = min(ceil(y), height);

    % 如果坐标超出边界，则返回黑色（或根据需求设置）
    if x1 < 1 || x2 > width || y1 < 1 || y2 > height
        if channels == 3
            pixel_value = uint8([0, 0, 0]);
        else
            pixel_value = uint8(0);
        end
        return;
    end

    % 计算权重
    w1 = (x2 - x) * (y2 - y);
    w2 = (x - x1) * (y2 - y);
    w3 = (x2 - x) * (y - y1);
    w4 = (x - x1) * (y - y1);

    % 插值计算
    if channels == 3
        pixel_value = uint8(w1 * img(y1, x1, :) + w2 * img(y1, x2, :) + ...
                            w3 * img(y2, x1, :) + w4 * img(y2, x2, :));
    else
        pixel_value = uint8(w1 * img(y1, x1) + w2 * img(y1, x2) + ...
                            w3 * img(y2, x1) + w4 * img(y2, x2));
    end
end

function rotated_img = manual_rotate(img, angle_degrees)
    % 获取原始图像尺寸
    [height, width, channels] = size(img);
    
    % 将角度转换为弧度
    theta = deg2rad(angle_degrees);
    
    % 构建旋转矩阵
    rotation_matrix = [cos(theta), -sin(theta); sin(theta), cos(theta)];
    
    % 计算旋转后的图像尺寸
    corners = [1, 1; width, 1; width, height; 1, height];
    rotated_corners = bsxfun(@minus, corners, [width/2, height/2]) * rotation_matrix';
    rotated_corners = bsxfun(@plus, rotated_corners, [width/2, height/2]);
    
    new_width = ceil(max(rotated_corners(:,1)) - min(rotated_corners(:,1)));
    new_height = ceil(max(rotated_corners(:,2)) - min(rotated_corners(:,2)));
    
    % 初始化输出图像
    if channels == 3
        rotated_img = zeros(new_height, new_width, 3, 'uint8');
    else
        rotated_img = zeros(new_height, new_width, 'uint8');
    end
    
    % 计算中心偏移量
    center_offset = [(new_width - width) / 2, (new_height - height) / 2];
    
    % 遍历新图像的每个像素，找到对应的原图像素位置并插值
    for y = 1:new_height
        for x = 1:new_width
            % 计算原图中的对应位置
            [orig_x, orig_y] = apply_inverse_rotation([x, y] - center_offset, rotation_matrix, width, height);
            
            % 检查是否在原图范围内
            if orig_x >= 1 && orig_x <= width && orig_y >= 1 && orig_y <= height
                rotated_img(y, x, :) = bilinear_interpolation(img, orig_x, orig_y, channels);
            end
        end
    end
end

function [x, y] = apply_inverse_rotation(point, rotation_matrix, original_width, original_height)
    % 应用逆旋转矩阵
    inv_rotation_matrix = inv(rotation_matrix);
    transformed_point = point * inv_rotation_matrix';
    x = transformed_point(1) + original_width / 2;
    y = transformed_point(2) + original_height / 2;
end