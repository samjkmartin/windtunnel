function pastVersion
% Calibration points:
water1   = 0;
digital1 = 0;
water2   = 5;
digital2 = 5;
% Calibration slope
m        = (water2-water1)/(digital2 - digital1);

% Adjustable Variables
delay    = 0.5;
avgSize  = 5;

% Define Variables for memory
voltage  = 0;
step     = 0;
vHolder  = zeros(1,avgSize);
white = [1 1 1];
fig = uifigure('WindowState','maximized', ...
    'Name','Plot App by Raaghav');
g = uigridlayout(fig,[6 6], 'BackgroundColor',[92 0 41]/255);
g.RowHeight = {'1x','2x','2x','2x','2x','1x'};
g.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};
% Plots to visualize data as its collected
% Voltage versus steps
axisVoltStep = uiaxes(g);
axisVoltStep.Layout.Row = [2 5];
axisVoltStep.Layout.Column = [1 2];
axisVoltStep.Title.String = 'Voltage Versus Steps';
axisVoltStep.XLabel.String = 'Voltage (V)';
axisVoltStep.YLabel.String = 'Steps (crank)';
axisVoltStep.Title.Color = white;
axisVoltStep.XLabel.Color = white;
axisVoltStep.YLabel.Color = white;
axisVoltStep.XColor = white;
axisVoltStep.YColor = white;
% Water versus height
axisWaterHeight = uiaxes(g);
axisWaterHeight.Layout.Row = [2 5];
axisWaterHeight.Layout.Column = [3 4];
axisWaterHeight.Title.String = 'Inches of Water Versus Height';
axisWaterHeight.YLabel.String = 'Height (mm)';
axisWaterHeight.XLabel.String = 'Water (in)';
axisWaterHeight.Title.Color = white;
axisWaterHeight.XLabel.Color = white;
axisWaterHeight.YLabel.Color = white;
axisWaterHeight.XColor = white;
axisWaterHeight.YColor = white;
% Velocity versus distance
axisVelocityDistance = uiaxes(g);
axisVelocityDistance.Layout.Row = [2 5];
axisVelocityDistance.Layout.Column = [5 6];
axisVelocityDistance.Title.String = 'Normalized Velocity Versus Distance';
axisVelocityDistance.XLabel.String = 'U/Uinf';
axisVelocityDistance.YLabel.String = 'h/diameter';
axisVelocityDistance.Title.Color = white;
axisVelocityDistance.XLabel.Color = white;
axisVelocityDistance.YLabel.Color = white;
axisVelocityDistance.XColor = white;
axisVelocityDistance.YColor = white;
% Interactable elements
% Button to aquire the next datapoint and plot it
recordButtonColor = [1 0 0];
recordButton = uibutton(g, ...
    "Text","Record Next Point", ...
    "ButtonPushedFcn", @(src,event) recordButtonPushed(), ...
    "BackgroundColor", recordButtonColor);
recordButton.Layout.Row = 6;
recordButton.Layout.Column = 1;
% Button that saves data to a csv
saveButton = uibutton(g, ...
    "Text","Save", ...
    "ButtonPushedFcn", @(src,event) saveButtonPushed(),...
    "BackgroundColor",[247 111 142]/255);
saveButton.Layout.Row = 6;
saveButton.Layout.Column = 5;
% Button that ends live feed
endButton = uibutton(g, ...
    "Text","End Live", ...
    "ButtonPushedFcn", @(src,event) endButtonPushed(), ...
    "BackgroundColor",[8 103 136]/255);
endButton.Layout.Row = 6;
endButton.Layout.Column = 6;
% Panel to display latest value
valuePanel = uipanel(g, ...
    "Title","Latest Value", ...
    "BackgroundColor",[148 191 190]/255);
valuePanel.Layout.Row = 1;
valuePanel.Layout.Column = 1;
valuePanelValue = uilabel(valuePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
valuePanelValue.Position(3:4) = [80 44];
% Panel to display live value
livePanel = uipanel(g, ...
    "Title","Live Value", ...
    "BackgroundColor",[148 191 190]/255);
livePanel.Layout.Row = 1;
livePanel.Layout.Column = 2;
livePanelValue = uilabel(livePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
livePanelValue.Position(3:4) = [80 44];
% Panel to display average value
avgPanel = uipanel(g, ...
    "Title","Average Value", ...
    "BackgroundColor",[148 191 190]/255);
avgPanel.Layout.Row = 1;
avgPanel.Layout.Column = 3;
avgPanelValue = uilabel(avgPanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
avgPanelValue.Position(3:4) = [80 44];
% Dropdown menu that chooses steps taken with crank
stepSelector = uidropdown(g, ...
    'BackgroundColor',[172 247 193]/255);
stepSelector.Layout.Row = 1;
stepSelector.Layout.Column = 6;
stepSelector.Items = {'2', '1', '0.5'};
stepSelector.Value = '2';
% Field that allows you to change filename (first half)
discType = uieditfield(g, "Value", 'set disc type', ...
    'BackgroundColor',[247 111 142]/255);
discType.Layout.Row = 6;
discType.Layout.Column = 3;
% Field that allows you to change filename (second half)
stationType = uieditfield(g, "Value", 'set station', ...
    'BackgroundColor',[247 111 142]/255);
stationType.Layout.Row = 6;
stationType.Layout.Column = 4;
% Initialize voltage - step plot data
voltX     = [];
stepY     = [];
% Initialize water - height plot data
waterX    = [];
heightY   = [];
% Initialize velocity - distance plot data
velocityX = [];
distanceY = [];
% Arduino Attach
a = arduino("/dev/cu.usbmodem2101", "Uno", Libraries = "I2C");
% Configure Pins
configurePin(a,'A0','AnalogInput');
configurePin(a,'D3','DigitalOutput');
% Generate 'random' data to read
writePWMVoltage(a,'D3',3);
stateA = 1;
while stateA == 1
    voltage   = readVoltage(a,'A0');
    vHolder(1) = [];
    vHolder(avgSize) = voltage;
    livePanelValue.Text = sprintf('%5.3f',voltage);
    avgPanelValue.Text = sprintf('%5.3f',mean(vHolder));
    pause(delay);
end
    function recordButtonPushed()
        % Define voltage and step
        voltage   = readVoltage(a,'A0');
        step      = step + str2double(stepSelector.Value);
        % Append the voltstep data to the cumulative data
        voltX     = [voltX, voltage];
        stepY     = [stepY, step];
        % Define inches of water and height in mm
        water     = voltage * m;
        height    = step * 3;
        % Append the waterheight data to the cumulative data
        waterX    = [waterX, water];
        heightY   = [heightY, height];
        % Normalized velocity and distance
        maxWater  = max(waterX);
        velocity  = sqrt(water/maxWater);
        distance  = height/50;
        % Append the velocitydistance data to the cumulative data
        velocityX = [velocityX, velocity];
        distanceY = [distanceY, distance];
        % change button color
        if recordButtonColor(1) == 0
        else
            recordButtonColor = [(1-step/70) step/70 0];
            recordButton.BackgroundColor = recordButtonColor;
        end
        % Update latest value
        valuePanelValue.Text = sprintf('%5.3f',voltage);
        
        % Plot the cumulative data
        plot(axisVoltStep, voltX, stepY);
        plot(axisWaterHeight, waterX, heightY)
        plot(axisVelocityDistance, velocityX, distanceY)
    end
    function saveButtonPushed()
        data = [voltX(:), stepY(:)];
        fileName1  = discType.Value;
        fileName2  = stationType.Value;
        formatSpec = '%s%s.csv';
        locationName = sprintf(formatSpec,fileName1,fileName2);
        writematrix(data, locationName)
        saveButton.Text = 'Saved';
        saveButton.BackgroundColor = [252 242 149]/255;
    end
    function endButtonPushed()
            stateA = 0;
            endButton.Text = 'Live Ended';
            livePanelValue.Text = 'Live Ended';
            avgPanelValue.Text  = 'Live Ended';
            endButton.BackgroundColor = [252 207 149]/255;
    end
end