function measurePressure

% Calibration points:
pressure1   = 0;
digital1 = 0;

pressure2   = 5;
digital2 = 5;

% Calibration slope
m = (pressure2-pressure1)/(digital2 - digital1);

% Disc diameter in mm
diameter = 50;

% Adjustable Variables
sampleInterval   = 0.04; % live value is updated every [] seconds
liveDelay    = 0.1;  % display live value every [] seconds
avgTime     = 1;    % Default number of seconds over which average voltage is calculated
avgSize      = avgTime/sampleInterval;   % default [] slots of values in avg

% Define Variables for memory
voltage    = 0;                % current value read by arduino
step       = 0;                % Counts cranks
voltHolder = zeros(1,avgSize); % Holds past voltage values
white      = [1 1 1];          % RGB value for white

% Create uifigure
appWindow = uifigure('WindowState','maximized', ...
    'Name','App for Pressure Transducer by Raaghav and Sam');

% Set universal font size
fontsize(appWindow, 24, "points")

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
axisVoltStep.YLabel.String = 'Steps (cranks)';

axisVoltStep.Title.Color   = white;
axisVoltStep.XLabel.Color  = white;
axisVoltStep.YLabel.Color  = white;
axisVoltStep.XColor        = white;
axisVoltStep.YColor        = white;

% Pressure versus height
axisPressureHeight = uiaxes(grid);
axisPressureHeight.Layout.Row    = [2 5];
axisPressureHeight.Layout.Column = [3 4];
axisPressureHeight.Title.String  = 'Pressure Versus Height';
axisPressureHeight.YLabel.String = 'Height (mm)';
axisPressureHeight.XLabel.String = 'Pressure (in H_2O)';

axisPressureHeight.Title.Color   = white;
axisPressureHeight.XLabel.Color  = white;
axisPressureHeight.YLabel.Color  = white;
axisPressureHeight.XColor        = white;
axisPressureHeight.YColor        = white;

% Velocity versus height
axisVelocityHeight = uiaxes(grid);
axisVelocityHeight.Layout.Row    = [2 5];
axisVelocityHeight.Layout.Column = [5 6];
axisVelocityHeight.Title.String  = 'Normalized Velocity Versus Normalized Height';
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
valuePanelValue.Position(3:4) = [100,44];

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
    "Value", avgTime, ...
    "ValueChangedFcn",@(avgLength,event) avgTimeChanged(),...
    'BackgroundColor',[247 111 142]/255);


% Initialize voltage - step plot data
voltX         = [];
stepY         = [];
avgVoltX      = [];

% Initialize pressure - height plot data
pressureX     = [];
heightY       = [];
stdDevPX      = [];

% Initialize velocity - distance plot data
normVelocityX = [];
normHeightY   = [];

% Arduino Attach – first string varies based on laptop and USB port used.
% To find port info: Plug in Arduino -> Arduino App -> Tools -> Port
% Raaghav right port: "/dev/cu.usbmodem2101"
% Sam 2015 left port: "/dev/cu.usbmodem14101"
% Sam 2015 right port "/dev/cu.usbmodem14201"
% Sam 2021 left upper port "/dev/cu.usbmodem101"
a = arduino("/dev/cu.usbmodem14101", "Uno", Libraries = "I2C");

% Configure Pin
configurePin(a,'A0','AnalogInput');

% Set up the KeyPressFcn for the figure
set(appWindow, 'KeyPressFcn', @(src, event) onKeyPress(src, event));

stateLive   = 1;
stateUpdate = 0;

timeDiff    = sampleInterval*10^(-5);

while stateLive == 1
    time3 = now;
    time4 = time3 + timeDiff;

    voltage             = readVoltage(a,'A0');
    voltHolder(1)       = [];
    voltHolder(avgSize) = voltage;
    stateUpdate = stateUpdate + sampleInterval;

    if stateUpdate >= liveDelay
        livePanelValue.Text = sprintf('%5.3f',voltage);
        avgPanelValue.Text  = sprintf('%5.3f',mean(voltHolder));

        if voltHolder(1) == 0
            avgPanelValue.BackgroundColor = [0.85 .25 .4];
        else
            avgPanelValue.BackgroundColor = [0.25 .8 .4];
        end
        stateUpdate = 0;
    end

    while now <= time4
        % disp(now-time3);
    end
end

    function recordButtonPushed()
        if avgPanelValue.BackgroundColor == [0.25 .8 .4]
            % Define voltage
            voltage   = readVoltage(a,'A0');

            % Append the voltstep data to the cumulative data
            voltX     = [voltX, voltage];
            stepY     = [stepY, step];
            % Store average value
            avgVoltX  = [avgVoltX, mean(voltHolder)];

            % Define pressure (time-averaged) in inches of water and height in mm
            pressureHolder  = voltHolder*m - digital1; 
            pressure = mean(pressureHolder); % units: inches of water
            stdDevP = std(pressureHolder); % units: inches of water
            
            height    = step * 3;

            % Append the pressure height data to the cumulative data
            pressureX = [pressureX, pressure]; 
            heightY   = [heightY, height];
            stdDevPX  = [stdDevPX, stdDevP]; 

            % Normalized velocity and distance
            maxPressure  = max(pressureX);
            normVelocity = sqrt(pressure/maxPressure); % units: dimensionless (U/Uinf)
            stdDevU = 0.5*stdDevP/sqrt(pressure*maxPressure); % units: dimensionless (DeltaU/Uinf)
            normHeight   = height/diameter;

            % Append the velocity distance data to the cumulative data
            normVelocityX = sqrt(pressureX/maxPressure);
            normHeightY   = [normHeightY, normHeight];

            % change button color
            if recordButtonColor(1) <= 0.1
            else
                recordButtonColor = [(1-step/70) step/70 0];
                recordButton.BackgroundColor = recordButtonColor;
            end

            % Update latest value
            valuePanelValue.Text = sprintf(['Pressure is %5.3f ± %5.3f' ...
                '\n U/Uinf is %5.3f ± %5.3f'], pressure, stdDevP, normVelocity, stdDevU);

            % Plot the cumulative data
            plot(axisVoltStep, avgVoltX, stepY);
            plot(axisPressureHeight, pressureX, heightY)
            plot(axisVelocityHeight, normVelocityX, normHeightY)

            voltHolder = zeros(avgSize,1);

            % Move step forward
            step      = step + str2double(stepSelector.Value);
        else
            recordButton.BackgroundColor = [0.9 0.9 0.2];
        end
    end

    function saveButtonPushed()
        data = [voltX(:), stepY(:), avgVoltX(:), pressureX(:), stdDevPX(:)];

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
        endButton.Text      = 'Live Ended';
        livePanelValue.Text = 'Live Ended';
        avgPanelValue.Text  = 'Live Ended';
        endButton.BackgroundColor = [252 207 149]/255;
    end

    function avgTimeChanged()
        avgSize = avgTime.Value/sampleInterval;
        voltHolder = zeros(avgSize,1);
    end

% Define the onKeyPress function
    function onKeyPress(~,event)
        keyPressed = event.Key;

        % Check if the pressed key corresponds to 'a', 's', 'd', or 'space'
        if strcmp(keyPressed, 'a') || strcmp(keyPressed, 's') || strcmp(keyPressed, 'd') || strcmp(keyPressed, 'space')
            % Change the value in the dropdown based on the key
            if strcmp(keyPressed, 'a')
                stepSelector.Value = '2';
                disp(stepSelector.Value)
            elseif strcmp(keyPressed, 's')
                stepSelector.Value = '1';
                disp(stepSelector.Value)
            elseif strcmp(keyPressed, 'd')
                stepSelector.Value = '0.5';
                disp(stepSelector.Value)
            elseif strcmp(keyPressed, 'space')
                recordButtonPushed()
            end
        end
    end
end