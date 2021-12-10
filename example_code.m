%% Init example code %%%%%%

% Python bridge setup
envPath = '/Users/username/opt/anaconda3/envs/envName/bin/'; %Conda env location of pyloopkit
loopPath = '/Users/Path/To/PyLoopKit/pyloopkit/'; %Modified update folder location
%     pe = pyenv('Version',[envPath, 'python']); % IMPORTANT. Run this line of code once per opening matlab. Then comment out, or will error. 
if count(py.sys.path,loopPath) == 0 %Imports pyloopkit module path
    insert(py.sys.path,int32(0),loopPath);
end
py.importlib.import_module('loop_data_manager_interface')

%  Settings
timeICR = [3 11 17];
ICR = [Quest.OB Quest.OB Quest.OB];
timeISF = [0 8 16];
ISF = [Quest.MD Quest.MD Quest.MD];
timeBasal = [0 12 24];
basal = [Quest.basal Quest.basal];

time = datetime('01-01-2020 00:00:00','InputFormat','dd-MM-yyyy HH:mm:ss');     % timestamp
controller.specific.loop = Loop(time, timeICR, ICR, timeISF, ISF, timeBasal, basal); % initialise controller

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Control loop example code %%%%%
%This code only requests a simple meal bolus and basal adjustments

% Add data to controller
specificparams.time = specificparams.time + minutes(5);       % increment 5 min to timestamp
specificparams.loop.glucVector = [specificparams.loop.glucVector Glucose];                        % store glucose vector
specificparams.loop.timeVector = [specificparams.loop.timeVector specificparams.time];       % increment 5 min to timestamp

if Meal_announcement.gramsCHO ~= 0
    specificparams.loop.mealVector = [specificparams.loop.mealVector Meal_announcement.gramsCHO];
else
    specificparams.loop.mealVector = [specificparams.loop.mealVector 0];
end

% Call loop
[Insulin, BasalRate] = loop_run(specificparams.loop, specificparams.time, Glucose, Meal_announcement.gramsCHO, Exercise_announcement.intensity);

if Meal_announcement.gramsCHO ~= 0
    specificparams.loop.tableInsulin = [specificparams.loop.tableInsulin;  {'bolus', specificparams.time, specificparams.time + minutes(1), Insulin}];  
end

IIRt = (BasalRate)/60*6000/specificparams.BW;  % basal insulin rate

GnIRt = 0;
insulin_bolus = Insulin;
rescueCHO = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%