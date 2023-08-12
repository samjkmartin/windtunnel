function plotApp

% Calibration points:
water1   = 0;
digital1 = 0;

water2   = 5;
digital2 = 5;

% Calibration slope
m = (water2-water1)/(digital2 - digital1);

% Disc diameter in mm
diameter = 50;

% Adjustable Variables
refreshDelay = 0.01; % live value is updated every [] seconds
liveDelay    = 0.1; % display live value every [] seconds
avgDelay     = 1; % Default number of seconds over which average voltage is calculated
avgSize      = avgDelay/refreshDelay;   % default [] slots of values in avg

% Define Variables for memory
voltage    = 0;                % current value read by arduino
step       = 0;                % Counts cranks
voltHolder = zeros(1,avgSize); % Holds past voltage values
white      = [1 1 1];          % RGB value for white

% Create uifigure
appWindow = uifigure('WindowState','maximized', ...
    'Name','Plot App for Pressure Transducer by Raaghav');

% Application grid for layout of app elements
grid = uigridlayout(appWindow,[6 6], ...
    'BackgroundColor',[92 0 41]/255);
grid.RowHeight   = {'1x','2x','2x','2x','2x','1x'};
grid.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};

% Plots to visualize data as its collected
% Voltage versus steps
axisVoltStep = uiaxes(grid);
axisVoltStep.Layout.Row    = [2 5];
axisVoltStep.Layout.Column = [1 2];
axisVoltStep.Title.String  = 'Voltage Versus Steps';
axisVoltStep.XLabel.String = 'Voltage (V)';
axisVoltStep.YLabel.String = 'Steps (crank)';

axisVoltStep.Title.Color   = white;
axisVoltStep.XLabel.Color  = white;
axisVoltStep.YLabel.Color  = white;
axisVoltStep.XColor        = white;
axisVoltStep.YColor        = white;

% Water versus height
axisWaterHeight = uiaxes(grid);
axisWaterHeight.Layout.Row    = [2 5];
axisWaterHeight.Layout.Column = [3 4];
axisWaterHeight.Title.String  = 'Inches of Water Versus Height';
axisWaterHeight.YLabel.String = 'Height (mm)';
axisWaterHeight.XLabel.String = 'Water (in)';

axisWaterHeight.Title.Color   = white;
axisWaterHeight.XLabel.Color  = white;
axisWaterHeight.YLabel.Color  = white;
axisWaterHeight.XColor        = white;
axisWaterHeight.YColor        = white;

% Velocity versus height
axisVelocityHeight = uiaxes(grid);
axisVelocityHeight.Layout.Row    = [2 5];
axisVelocityHeight.Layout.Column = [5 6];
axisVelocityHeight.Title.String  = 'Normalized Velocity Versus Distance';
axisVelocityHeight.XLabel.String = 'U/Uinf';
axisVelocityHeight.YLabel.String = 'h/diameter';

axisVelocityHeight.Title.Color   = white;
axisVelocityHeight.XLabel.Color  = white;
axisVelocityHeight.YLabel.Color  = white;
axisVelocityHeight.XColor        = white;
axisVelocityHeight.YColor        = white;

% Interactable elements
% Button to aquire the next datapoint and plot it
recordButtonColor = [1 0 0];
recordButton      = uibutton(grid, ...
    "Text","Record Next Point", ...
    "ButtonPushedFcn", @(src,event) recordButtonPushed(), ...
    "BackgroundColor", recordButtonColor);
recordButton.Layout.Row    = 6;
recordButton.Layout.Column = 1;

% Button that saves data to a csv
saveButton = uibutton(grid, ...
    "Text","Save", ...
    "ButtonPushedFcn", @(src,event) saveButtonPushed(),...
    "BackgroundColor",[247 111 142]/255);
saveButton.Layout.Row    = 6;
saveButton.Layout.Column = 5;

% Button that ends live feed
endButton = uibutton(grid, ...
    "Text","End Live", ...
    "ButtonPushedFcn", @(src,event) endButtonPushed(), ...
    "BackgroundColor",[8 103 136]/255);
endButton.Layout.Row    = 6;
endButton.Layout.Column = 6;

% Panel to display latest value
valuePanel = uipanel(grid, ...
    "Title","Latest Value", ...
    "BackgroundColor",[148 191 190]/255);
valuePanel.Layout.Row    = 1;
valuePanel.Layout.Column = 1;
valuePanelValue = uilabel(valuePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
valuePanelValue.Position(3:4) = [80 44];

% Panel to display live value
livePanel = uipanel(grid, ...
    "Title","Live Value", ...
    "BackgroundColor",[148 191 190]/255);
livePanel.Layout.Row    = 1;
livePanel.Layout.Column = 2;
livePanelValue = uilabel(livePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
livePanelValue.Position(3:4) = [80 44];

% Panel to display average value
avgPanel = uipanel(grid, ...
    "Title","Average Value", ...
    "BackgroundColor",[148 191 190]/255);
avgPanel.Layout.Row    = 1;
avgPanel.Layout.Column = 3;
avgPanelValue = uilabel(avgPanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
avgPanelValue.Position(3:4) = [80 44];

% Dropdown menu that chooses steps taken with crank
stepPanel = uipanel(grid, ...
    "Title","Step Selector", ...
    "BackgroundColor",[172 247 193]/255);
stepPanel.Layout.Row    = 1;
stepPanel.Layout.Column = 6;
stepSelector = uidropdown(stepPanel, ...
    'BackgroundColor',[172 247 193]/255);
stepSelector.Items = {'2', '1', '0.5'};
stepSelector.Value = '2';

% Field that allows you to change filename (first half)
discType = uieditfield(grid, "Value", 'set disc type', ...
    'BackgroundColor',[247 111 142]/255);
discType.Layout.Row = 6;
discType.Layout.Column = 3;

% Field that allows you to change filename (second half)
stationType = uieditfield(grid, "Value", 'set station', ...
    'BackgroundColor',[247 111 142]/255);
stationType.Layout.Row = 6;
stationType.Layout.Column = 4;

% Field that allows you to change rolling avg time in seconds
avgTimePanel = uipanel(grid, ...
    "Title","Averaging Time (s)", ...
    "BackgroundColor",[247 111 142]/255);
avgTimePanel.Layout.Row = 1;
avgTimePanel.Layout.Column = 4;
avgTime = uieditfield(avgTimePanel, "numeric", ...
    "Value", avgDelay, ...
    "ValueChangedFcn",@(avgLength,event) avgTimeChanged(),...
    'BackgroundColor',[247 111 142]/255);


% Initialize voltage - step plot data
voltX         = [];
stepY         = [];
avgVoltX      = [];

% Initialize water - height plot data
waterX        = [];
heightY       = [];

% Initialize velocity - distance plot data
normVelocityX = [];
normHeightY   = [];

% Arduino Attach – first string varies based on laptop and USB port used.
% To find port info: Plug in Arduino -> Arduino App -> Tools -> Port
% Raaghav right port: "/dev/cu.usbmodem2101"
% Sam left port: "/dev/cu.usbmodem14101"
% Sam right port "/dev/cu.usbmodem14201"
a = arduino("/dev/cu.usbmodem2101", "Uno", Libraries = "I2C");

% Configure Pin
configurePin(a,'A0','AnalogInput');

% Set up the KeyPressFcn for the figure
set(appWindow, 'KeyPressFcn', @(src, event) onKeyPress(src, event));

stateLive   = 1;
stateUpdate = 0;
while stateLive == 1
    stateUpdate = stateUpdate + refreshDelay;
    voltage             = readVoltage(a,'A0');
    voltHolder(1)       = [];
    voltHolder(avgSize) = voltage;

    if stateUpdate >= liveDelay
        livePanelValue.Text = sprintf('%5.3f',voltage);
        avgPanelValue.Text  = sprintf('%5.3f',mean(voltHolder));

        stateUpdate = 0;
    end

    pause(refreshDelay);
end

    function recordButtonPushed()
        % Define voltage and step
        voltage   = readVoltage(a,'A0');
        step      = step + str2double(stepSelector.Value);

        % Append the voltstep data to the cumulative data
        voltX     = [voltX, voltage];
        stepY     = [stepY, step];
        % Store average value
        avgVoltX  = [avgVoltX, mean(voltHolder)];

        % Define inches of water (time-averaged) and height in mm
        water     = mean(voltHolder) * m;
        height    = step * 3;

        % Append the waterheight data to the cumulative data
        waterX    = [waterX, water];
        heightY   = [heightY, height];

        % Normalized velocity and distance
        maxWater  = max(waterX);
        normVelocity  = sqrt(water/maxWater);
        normHeight  = height/diameter;

        % Append the velocitydistance data to the cumulative data
        normVelocityX = [normVelocityX, normVelocity];
        normHeightY = [normHeightY, normHeight];

        % change button color
        if recordButtonColor(1) == 0
        else
            recordButtonColor = [(1-step/70) step/70 0];
            recordButton.BackgroundColor = recordButtonColor;
        end

        % Update latest value
        valuePanelValue.Text = sprintf(['Voltage is %5.3f' ...
            '\n U/Uinf is %5.3f'],voltage,normVelocity);

        % Plot the cumulative data
        plot(axisVoltStep, avgVoltX, stepY);
        plot(axisWaterHeight, waterX, heightY)
        plot(axisVelocityHeight, normVelocityX, normHeightY)
    end

    function saveButtonPushed()
        data = [voltX(:), stepY(:), avgVoltX(:), waterX(:)];

        fileName1  = discType.Value;
        fileName2  = stationType.Value;
        formatSpec = '%s%s.csv';

        locationName = sprintf(formatSpec,fileName1,fileName2);

        writematrix(data, locationName)
        saveButton.Text = 'Saved';
        saveButton.BackgroundColor = [252 242 149]/255;
    end

    function endButtonPushed()
        stateLive = 0;
        endButton.Text = 'Live Ended';
        livePanelValue.Text = 'Live Ended';
        avgPanelValue.Text  = 'Live Ended';
        endButton.BackgroundColor = [252 207 149]/255;
    end

    function avgTimeChanged()
        avgSize = avgTime.Value/refreshDelay;
    end

    % Define the onKeyPress function
    function onKeyPress(~,event)
        keyPressed = event.Key;

        % Check if the pressed key corresponds to 'a', 's', or 'd'
        if strcmp(keyPressed, 'a') || strcmp(keyPressed, 's') || strcmp(keyPressed, 'd') || strcmp(keyPressed, 'space')
            % Change the value in the dropdown based on the key
            if strcmp(keyPressed, 'a')
                stepSelector.Value = '2';
            elseif strcmp(keyPressed, 's')
                stepSelector.Value = '1';
            elseif strcmp(keyPressed, 'd')
                stepSelector.Value = '0.5';
            elseif strcmp(keyPressed, 'space')
                recordButtonPushed()
            end 
        end
    end
end