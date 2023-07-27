function plotApp

% Calibration points:
water1   = 0;
digital1 = 0;

water2   = 5;
digital2 = 5;

% Calibration slope
m        = (water2-water1)/(digital2 - digital1);

% Define Variables
voltage  = 0;
step     = 0;
fig = uifigure('WindowState','fullscreen','Name','Plot App by Raaghav');
g = uigridlayout(fig,[6 6], 'BackgroundColor',[222/255 255/255 241/255]);
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

% Water versus height
axisWaterHeight = uiaxes(g);
axisWaterHeight.Layout.Row = [2 5];
axisWaterHeight.Layout.Column = [3 4];
axisWaterHeight.Title.String = 'Inches of Water Versus Height';
axisWaterHeight.XLabel.String = 'Water (in)';
axisWaterHeight.YLabel.String = 'Height (mm)';

% Velocity versus distance
axisVelocityDistance = uiaxes(g);
axisVelocityDistance.Layout.Row = [2 5];
axisVelocityDistance.Layout.Column = [5 6];
axisVelocityDistance.Title.String = 'Normalized Velocity Versus Distance';
axisVelocityDistance.XLabel.String = 'U/Uinf';
axisVelocityDistance.YLabel.String = 'h/diameter';

% Button to aquire the next datapoint and plot it
recordButton = uibutton(g, ...
    "Text","Record Next Point", ...
    "ButtonPushedFcn", @(src,event) plotButtonPushed());
recordButton.Layout.Row = 6;
recordButton.Layout.Column = 1;

% Button that saves data to a csv
saveButton = uibutton(g, ...
    "Text","Save", ...
    "ButtonPushedFcn", @(src,event) saveButtonPushed(),...
    "BackgroundColor",[149, 252, 158]/255);
saveButton.Layout.Row = 6;
saveButton.Layout.Column = 5;

% Button that ends live feed
endButton = uibutton(g, ...
    "Text","End Live", ...
    "ButtonPushedFcn", @(src,event) endButtonPushed(), ...
    "BackgroundColor",[242/255 19/255 83/255]);
endButton.Layout.Row = 6;
endButton.Layout.Column = 6;

% Panel to display latest value
valuePanel = uipanel(g, ...
    "Title","Latest Value", ...
    "BackgroundColor",[184/255 255/255 242/255]);
valuePanel.Layout.Row = 1;
valuePanel.Layout.Column = [1 2];
valuePanelValue = uilabel(valuePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
valuePanelValue.Position(3:4) = [80 44];

% Panel to display live value
livePanel = uipanel(g, ...
    "Title","Live Value", ...
    "BackgroundColor",[184/255 255/255 242/255]);
livePanel.Layout.Row = 1;
livePanel.Layout.Column = [3 4];
livePanelValue = uilabel(livePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
livePanelValue.Position(3:4) = [80 44];

% Dropdown menu that chooses steps taken with crank
stepSelector = uidropdown(g, ...
    'BackgroundColor',[222/255 255/255 241/255]);
stepSelector.Layout.Row = 1;
stepSelector.Layout.Column = 6;
stepSelector.Items = {'2', '1', '0.5'};
stepSelector.Value = '2';

% Field that allows you to change filename (first half)
discType = uieditfield(g, "Value", 'set disc type', ...
    'BackgroundColor',[229/255 202/255 250/255]);
discType.Layout.Row = 6;
discType.Layout.Column = 3;

% Field that allows you to change filename (second half)
stationType = uieditfield(g, "Value", 'set station', ...
    'BackgroundColor',[229/255 202/255 250/255]);
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
    livePanelValue.Text = sprintf('%5.3f',voltage);
    pause(0.5);
end
    function plotButtonPushed()
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
            endButton.BackgroundColor = [252 207 149]/255;
    end
end