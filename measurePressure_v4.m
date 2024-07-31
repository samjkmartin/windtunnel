function measurePressure_v3

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
sampleInterval = 0.05; % live value is updated every [] seconds
liveDelay = 0.2;  % display live value every [] seconds
defaultSampleTime = 10;    % Default number of seconds over which data is recorded
sampleSize = defaultSampleTime/sampleInterval;   % default [] slots of values in sample
liveTime = 3; % Number of seconds over which moving average pressure and velocity are calculated
liveSize = liveTime/sampleInterval; 
maxPressure = 4.5; % initial value so that live velocity will display before the first data is recorded

% Define Variables for memory
voltage    = 0;                % current value read by arduino
step       = -2;                % Counts cranks
sampleHolder = zeros(sampleSize,1); % Stores voltage values during data recording
liveHolder = zeros(liveSize,1); % Stores voltage values during main (live update) loop
white      = [1 1 1];          % RGB value for white

% define indicator colors for data collection
green = [0.25 .8 .4]; 
red = [0.85 .25 .4];

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
% Voltage versus time for most recent sample
axisVoltTime = uiaxes(grid);
axisVoltTime.Layout.Row    = [2 5];
axisVoltTime.Layout.Column = [1 2];
axisVoltTime.Title.String  = 'Voltage vs. Time for most recent sample';
axisVoltTime.XLabel.String = 'Time (sec)';
axisVoltTime.YLabel.String = 'Voltage (V)';

axisVoltTime.Title.Color   = white;
axisVoltTime.XLabel.Color  = white;
axisVoltTime.YLabel.Color  = white;
axisVoltTime.XColor        = white;
axisVoltTime.YColor        = white;

% Pressure versus cranks
axisPressureHeight = uiaxes(grid);
axisPressureHeight.Layout.Row    = [2 5];
axisPressureHeight.Layout.Column = [3 4];
axisPressureHeight.Title.String  = 'Pressure Versus Cranks';
axisPressureHeight.YLabel.String = 'Cranks (mm)';
axisPressureHeight.XLabel.String = 'Pressure (in H_2O)';

axisPressureHeight.Title.Color   = white;
axisPressureHeight.XLabel.Color  = white;
axisPressureHeight.YLabel.Color  = white;
axisPressureHeight.XColor        = white;
axisPressureHeight.YColor        = white;

% Velocity versus normalized height
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

% Panel to display latest recorded value
recordedPanel = uipanel(grid, ...
    "Title","Latest Recorded Values", ...
    "BackgroundColor",[148 191 190]/255);
recordedPanel.Layout.Row    = 1;
recordedPanel.Layout.Column = 4;
recordedPanelValue = uilabel(recordedPanel, ...
    "Text", ['waiting...' newline ' '], ...
    "Position", [55 60 150 44], ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
% recordedPanelValue.Position([1,3,4]) = [50,150,44];
recordedPanelValue.BackgroundColor = green;

% Panel to display live voltage value
livePanel = uipanel(grid, ...
    "Title","Live Voltage Reading", ...
    "BackgroundColor",[148 191 190]/255);
livePanel.Layout.Row    = 1;
livePanel.Layout.Column = 1;
livePanelValue = uilabel(livePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
livePanelValue.Position(3:4) = [80 44];

% Panel to display time-averaged pressure value
pressurePanel = uipanel(grid, ...
    "Title",['Pressure (in water) (' num2str(liveTime) '-sec moving avg)'], ...
    "BackgroundColor",[148 191 190]/255);
pressurePanel.Layout.Row    = 1;
pressurePanel.Layout.Column = 2;
pressurePanelValue = uilabel(pressurePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
pressurePanelValue.Position(3:4) = [80 44];

% Panel to display time-averaged normalized velocity value
velocityPanel = uipanel(grid, ...
    "Title",['U/Uinf (' num2str(liveTime) '-sec moving avg)'], ...
    "BackgroundColor",[148 191 190]/255);
velocityPanel.Layout.Row    = 1;
velocityPanel.Layout.Column = 3;
velocityPanelValue = uilabel(velocityPanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
velocityPanelValue.Position(3:4) = [80 44];

% Field that allows you to change sample recording time in seconds
sampleTimePanel = uipanel(grid, ...
    "Title","Recording Time (s)", ...
    "BackgroundColor",[247 111 142]/255);
sampleTimePanel.Layout.Row = 1;
sampleTimePanel.Layout.Column = 5;
sampleTime = uieditfield(sampleTimePanel, "numeric", ...
    "Value", defaultSampleTime, ...
    "ValueChangedFcn",@(sampleLength,event) sampleTimeChanged(),...
    'BackgroundColor',[247 111 142]/255);

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

% Initialize voltage - step plot data
voltX         = [];
stepY         = [];
avgVoltX      = [];

% Initialize pressure - height plot data
pressureX     = [];
% heightY       = []; 

% Initialize velocity - distance plot data
normVelocityX = [];
normHeightY   = [];

% Initialize other data to be eventually saved to CSV
stdDevPX      = [];
sampleHolderX = [];

% Arduino Attach – first string varies based on laptop and USB port used.
% To find port info: Plug in Arduino -> Arduino App -> Tools -> Port
% Raaghav right port: "/dev/cu.usbmodem2101"
% Sam 2015 left port: "/dev/cu.usbmodem14101"
% Sam 2015 right port "/dev/cu.usbmodem14201"
% Sam 2021 left upper port "/dev/cu.usbmodem101"
% Riley 2024 USB Port "/COM5"
a = arduino("/dev/cu.usbmodem14101", "Uno", Libraries = "I2C");

% Configure Pin
configurePin(a,'A0','AnalogInput');

% Set up the KeyPressFcn for the figure
set(appWindow, 'KeyPressFcn', @(src, event) onKeyPress(src, event));

stateLive   = 1;
stateUpdate = 0;
stateRecord = 0; 

timeDiff    = seconds(sampleInterval);

while stateLive == 1
    if stateRecord == 0 % if not recording, update the live moving averages
        time1 = datetime;
        time2 = time1 + timeDiff;

        % Collect data to be displayed live
        voltage             = readVoltage(a,'A0');
        liveHolder(1)       = [];
        liveHolder(liveSize) = voltage;
        % voltHolder = [voltHolder(2:end);voltage]; % this is an alternate way
        % % to update the array that doesn't involve dynamic resizing, although
        % % it seems to be slower than Raaghav's way

        % Define pressure (time-averaged) in inches of water and height in mm
        livePressureHolder  = liveHolder*m - digital1;
        livePressure = mean(livePressureHolder); % units: inches of water
        liveStdDevP = std(livePressureHolder); % units: inches of water

        % Normalized velocity and distance
        liveNormVelocity = sqrt(livePressure/maxPressure); % units: dimensionless (U/Uinf)
        liveStdDevU = 0.5*liveStdDevP/sqrt(livePressure*maxPressure); % units: dimensionless (DeltaU/Uinf)

        % update live displays every [liveDelay] seconds
        stateUpdate = stateUpdate + sampleInterval;
        if stateUpdate >= liveDelay
            livePanelValue.Text = sprintf('%5.3f',voltage);
            pressurePanelValue.Text  = sprintf('%5.3f ± %5.3f',livePressure,liveStdDevP);
            velocityPanelValue.Text  = sprintf('%5.3f ± %5.3f',liveNormVelocity,liveStdDevU);
            stateUpdate = stateUpdate - liveDelay;
        end

        % if datetime < time2
        %     disp(stateUpdate);
        % end

        while datetime < time2
        end
    else % record data once the record button has been pushed, then send it back to live after done recording
        % Move step forward
        step = step + str2double(stepSelector.Value);

        % clear the voltage array before collecting a sample
        sampleHolder = zeros(sampleSize,1);

        % collect the sample (fill the array of voltages to be averaged)
        stateUpdate = 0;
        tic
        for i=1:sampleSize
            time3 = datetime;
            time4 = time3 + timeDiff;

            voltage = readVoltage(a,'A0');
            sampleHolder(i) = voltage;

            % update live voltage display every [liveDelay] seconds
            stateUpdate = stateUpdate + sampleInterval;
            if stateUpdate >= liveDelay
                livePanelValue.Text = sprintf('%5.3f',voltage);
                stateUpdate = stateUpdate - liveDelay;
                % if datetime < time4
                %     disp(i);
                % end
            end

            while datetime < time4
                % disp(milliseconds(datetime-time3));
            end
        end
        toc

        % Append the voltage and step data to the cumulative data
        voltX     = [voltX; sampleHolder(1)]; % instantaneous voltage when the record button was first pushed
        stepY     = [stepY; step]; % number of cranks
        % Store average value
        avgVoltX  = [avgVoltX; mean(sampleHolder)];

        % Define pressure (time-averaged) in inches of water and height in mm
        pressureHolder  = sampleHolder*m - digital1;
        pressure = mean(pressureHolder); % units: inches of water
        stdDevP = std(pressureHolder); % units: inches of water

        height    = step * 3;

        % Append the pressure data to the cumulative data
        pressureX = [pressureX; pressure];
        % heightY   = [heightY; height];
        stdDevPX  = [stdDevPX; stdDevP];

        % Normalized velocity and distance
        maxPressure  = max(pressureX);
        normVelocity = sqrt(pressure/maxPressure); % units: dimensionless (U/Uinf)
        stdDevU = 0.5*stdDevP/sqrt(pressure*maxPressure); % units: dimensionless (DeltaU/Uinf)
        normHeight   = height/diameter;

        % Append the velocity distance data to the cumulative data
        normVelocityX = sqrt(pressureX/maxPressure);
        normHeightY   = [normHeightY; normHeight];

        % Append the sample vector to the array containing all samples
        sampleHolder = sampleHolder';
        if length(sampleHolder) == width(sampleHolderX)
            sampleHolderX = [sampleHolderX; sampleHolder];
        elseif isempty(sampleHolderX)
            sampleHolderX = sampleHolder;
        elseif length(sampleHolder) < width(sampleHolderX)
            lengthdiff = width(sampleHolderX) - length(sampleHolder);
            sampleHolder = [sampleHolder, zeros(1,lengthdiff)];
            sampleHolderX = [sampleHolderX; sampleHolder];
        elseif length(sampleHolder) > width(sampleHolderX)
            lengthdiff = length(sampleHolder) - size(sampleHolderX,2);
            sampleHolderX = [sampleHolderX, zeros(size(sampleHolderX,1),lengthdiff)];
            sampleHolderX = [sampleHolderX; sampleHolder];
        else
            warning('Sample Size Exception')
        end

        % change button color
        if recordButtonColor(1) > 0.1
            recordButtonColor = [(1-step/75) step/75 0];
            recordButton.BackgroundColor = recordButtonColor;
        end

        % Update latest value
        recordedPanelValue.Text = sprintf(['Pressure is %5.3f ± %5.3f' ...
            '\n U/Uinf is %5.3f ± %5.3f'], pressure, stdDevP, normVelocity, stdDevU);

        % Plot the cumulative data
        plot(axisVoltTime, sampleInterval*(1:(sampleTime/sampleInterval)), sampleHolder);
        plot(axisPressureHeight, pressureX, stepY)
        plot(axisVelocityHeight, normVelocityX, normHeightY)

        % figure
        % plot(sampleInterval*(1:length(pressureHolder)), pressureHolder)

        stateRecord = 0; % done recording, so go back to updating live moving averages

        % change the background color back to green to signal that data
        % has been collected and it is now okay to move the probe
        recordedPanelValue.BackgroundColor = green;
    end
end

    function recordButtonPushed()
        if recordedPanelValue.BackgroundColor == green
            stateRecord = 1;

            % change background color to red so that you don't move the probe while data collection is in progress
            recordedPanelValue.BackgroundColor = red;
        else
            recordButton.BackgroundColor = [0.9 0.9 0.2];
        end
    end

    function saveButtonPushed()
        data = [voltX(:), stepY(:), avgVoltX(:), pressureX(:), stdDevPX(:), sampleHolderX];

        fileName1  = discType.Value;
        fileName2  = stationType.Value;
        formatSpec = '%sS%s.csv';

        locationName = sprintf(formatSpec,fileName1,fileName2);

        writematrix(data, locationName)
        saveButton.Text = 'Saved';
        saveButton.BackgroundColor = [252 242 149]/255;
    end

    function endButtonPushed()
        stateLive = 0;
        endButton.Text      = 'Live Ended';
        livePanelValue.Text = 'Live Ended';
        pressurePanelValue.Text  = 'Live Ended';
        endButton.BackgroundColor = [252 207 149]/255;
    end

    function sampleTimeChanged()
        sampleSize = sampleTime.Value/sampleInterval;
        % sampleHolder = zeros(sampleSize,1); redundant
    end

% Define the onKeyPress function
    function onKeyPress(~,event)
        keyPressed = event.Key;

        % Check if the pressed key corresponds to 'a', 's', 'd', or 'space'
        if strcmp(keyPressed, 'a') || strcmp(keyPressed, 's') || strcmp(keyPressed, 'd') || strcmp(keyPressed, 'space')
            % Change the value in the dropdown based on the key
            if strcmp(keyPressed, 'space')
                recordButtonPushed()
            elseif strcmp(keyPressed, 'a')
                stepSelector.Value = '2';
                disp(stepSelector.Value)
            elseif strcmp(keyPressed, 's')
                stepSelector.Value = '1';
                disp(stepSelector.Value)
            elseif strcmp(keyPressed, 'd')
                stepSelector.Value = '0.5';
                disp(stepSelector.Value)
            end
        end
    end
end