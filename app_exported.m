classdef app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        lbpFeatureandhogFeatureButton  matlab.ui.control.Button
        extract_target_from_imageButton  matlab.ui.control.Button
        edge_detectionButton           matlab.ui.control.Button
        image_processing_with_noise_and_filteringButton  matlab.ui.control.Button
        transform_imageButton          matlab.ui.control.Button
        logEnhancedImgandenhancedLinearImgButton  matlab.ui.control.Button
        histogram_processingButton     matlab.ui.control.Button
        Button                         matlab.ui.control.Button
        UIAxes                         matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: Button
        function ButtonPushed(app, event)
            [file,path] = uigetfile({'*.jpg;*.png;*.bmp','Image Files'});
            if isequal(file,0)
                disp('User selected Cancel');
            else
                fullpath = fullfile(path,file);
                img = imread(fullpath);
                imshow(img, 'Parent', app.UIAxes);
            end
        end

        % Button pushed function: histogram_processingButton
        function histogram_processingButtonPushed(app, event)
                    w1();
        end

        % Button pushed function: logEnhancedImgandenhancedLinearImgButton
        function logEnhancedImgandenhancedLinearImgButtonPushed(app, event)
           w2();
        end

        % Button pushed function: transform_imageButton
        function transform_imageButtonPushed(app, event)
            w3();
        end

        % Button pushed function: 
        % image_processing_with_noise_and_filteringButton
        function image_processing_with_noise_and_filteringButtonPushed(app, event)
            w4();
        end

        % Button pushed function: edge_detectionButton
        function edge_detectionButtonPushed(app, event)
            w5();
        end

        % Button pushed function: extract_target_from_imageButton
        function extract_target_from_imageButtonPushed(app, event)
            w6();
        end

        % Button pushed function: lbpFeatureandhogFeatureButton
        function lbpFeatureandhogFeatureButtonPushed(app, event)
            w7();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 648 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '处理图像')
            app.UIAxes.Position = [298 164 300 185];

            % Create Button
            app.Button = uibutton(app.UIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.Position = [57 326 100 23];
            app.Button.Text = '选择处理图像';

            % Create histogram_processingButton
            app.histogram_processingButton = uibutton(app.UIFigure, 'push');
            app.histogram_processingButton.ButtonPushedFcn = createCallbackFcn(app, @histogram_processingButtonPushed, true);
            app.histogram_processingButton.Position = [40 287 133 23];
            app.histogram_processingButton.Text = 'histogram_processing';

            % Create logEnhancedImgandenhancedLinearImgButton
            app.logEnhancedImgandenhancedLinearImgButton = uibutton(app.UIFigure, 'push');
            app.logEnhancedImgandenhancedLinearImgButton.ButtonPushedFcn = createCallbackFcn(app, @logEnhancedImgandenhancedLinearImgButtonPushed, true);
            app.logEnhancedImgandenhancedLinearImgButton.Position = [7 245 233 23];
            app.logEnhancedImgandenhancedLinearImgButton.Text = 'logEnhancedImgandenhancedLinearImg';

            % Create transform_imageButton
            app.transform_imageButton = uibutton(app.UIFigure, 'push');
            app.transform_imageButton.ButtonPushedFcn = createCallbackFcn(app, @transform_imageButtonPushed, true);
            app.transform_imageButton.Position = [7 199 234 23];
            app.transform_imageButton.Text = 'transform_image';

            % Create image_processing_with_noise_and_filteringButton
            app.image_processing_with_noise_and_filteringButton = uibutton(app.UIFigure, 'push');
            app.image_processing_with_noise_and_filteringButton.ButtonPushedFcn = createCallbackFcn(app, @image_processing_with_noise_and_filteringButtonPushed, true);
            app.image_processing_with_noise_and_filteringButton.Position = [7 164 250 23];
            app.image_processing_with_noise_and_filteringButton.Text = 'image_processing_with_noise_and_filtering';

            % Create edge_detectionButton
            app.edge_detectionButton = uibutton(app.UIFigure, 'push');
            app.edge_detectionButton.ButtonPushedFcn = createCallbackFcn(app, @edge_detectionButtonPushed, true);
            app.edge_detectionButton.Position = [57 122 100 23];
            app.edge_detectionButton.Text = 'edge_detection';

            % Create extract_target_from_imageButton
            app.extract_target_from_imageButton = uibutton(app.UIFigure, 'push');
            app.extract_target_from_imageButton.ButtonPushedFcn = createCallbackFcn(app, @extract_target_from_imageButtonPushed, true);
            app.extract_target_from_imageButton.Position = [28 82 159 23];
            app.extract_target_from_imageButton.Text = 'extract_target_from_image';

            % Create lbpFeatureandhogFeatureButton
            app.lbpFeatureandhogFeatureButton = uibutton(app.UIFigure, 'push');
            app.lbpFeatureandhogFeatureButton.ButtonPushedFcn = createCallbackFcn(app, @lbpFeatureandhogFeatureButtonPushed, true);
            app.lbpFeatureandhogFeatureButton.Position = [30 40 154 23];
            app.lbpFeatureandhogFeatureButton.Text = 'lbpFeatureandhogFeature';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end