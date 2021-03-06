envPath = '/Users/username/opt/anaconda3/envs/py-loop/bin/';
loopPath = '/Users/username/Path/To/PyLoopKit/pyloopkit/';
% To go in init /*
% if exist('pe') == 0  % IMPORTANT. Run this line of code once per opening matlab. Then comment out, or will error. 
%     pe = pyenv('Version',[envPath, 'python']);
% end
if count(py.sys.path,loopPath) == 0
    insert(py.sys.path,int32(0),loopPath);
end

runTestLoop

function str = numArrFormat(Arr)
    str =  ['[',regexprep(num2str(Arr),'\s+',','),']'];
end

function str = dateArrFormat(Arr)
    formatOut = 'yyyy-mm-ddTHH:MM:SS+00:00';
    str = jsonencode(datestr(Arr,formatOut));
end

function str = timeArrFormat(Arr)
    dateArr = arrayfun(@(x) datenum([0, 0, 0, x, 0, 0]),Arr);
    formatOut = 'HH:MM:SS';
    str = jsonencode(datestr(dateArr,formatOut));
end

function result = runTestLoop

%     py.importlib.import_module('loop_data_manager_interface') 
%     Quest = load('TestQuest/quest.mat').Quest;
    ob = 13.772570217009898;
    md = 39.503018260492440;
    basal = 1.248551265211330;
    
    timeICR = [3 11 17];
    ICR = [ob ob ob];
    timeISF = [0 8 16];
    ISF = [md md md];
    timeBasal = [0 12 24];
    basal = [basal basal];
    
    bArr = circshift(timeBasal,-1);
    bMinutes = (bArr - timeBasal) * 60;
    basalM = bMinutes(bMinutes > 0);
    tBasalShort = timeBasal(timeBasal < 24);
 
    settings = ['"settings_dictionary": {' ...
                '"default_absorption_times": [ 120.0, 180.0, 240.0 ],' ...
                '"insulin_delay": 10,' ... % As per ExponentialInsulinModelPreset
                '"max_basal_rate": 15.0,' ...
                '"max_bolus": 15.0,' ...
                '"model": [ 360.0, 75 ],' ... % As per ExponentialInsulinModelPreset: humalogNovologAdult
                '"rate_rounder": null,' ... % Define based on pump. Set to null for no rounding
                '"suspend_threshold": null },'...
                '"basal_rate_start_times": ', timeArrFormat(tBasalShort) , ',' ...
                '"basal_rate_units": "U/hr",' ...
                '"basal_rate_values": ', numArrFormat(basal), ',' ...
                '"basal_rate_minutes": ', numArrFormat(basalM), ',' ...
                '"carb_ratio_start_times": ',  timeArrFormat(timeICR), ',' ...
                '"carb_ratio_value_units": "g/U",' ...
                '"carb_ratio_values": ', numArrFormat(ICR), ',' ...
                '"carb_value_units": "g",' ...
                '"offset_applied_to_dates": 0,' ...
                '"sensitivity_ratio_end_times": ', timeArrFormat(circshift(timeISF,-1)), ',' ...
                '"sensitivity_ratio_start_times": ', timeArrFormat(timeISF), ',' ...
                '"sensitivity_ratio_value_units": "mg/dL/U",' ...
                '"sensitivity_ratio_values": ', numArrFormat(ISF), ',' ...
                '"target_range_end_times": [ "00:00:00" ],' ...
                '"target_range_maximum_values": [ 110.0 ],' ...
                '"target_range_minimum_values": [ 80.0 ],' ...
                '"target_range_start_times": [ "00:00:00" ],' ...
                '"target_range_value_units": "mg/dL",']; 
            
    inputDict = ['{"carb_absorption_times": [ 180.0 ],' ...
                '"carb_dates": [ "2019-08-15T12:01:06+00:00" ],' ...
                '"carb_values": [ 15.0 ],' ...
                '"dose_end_times": [ "2019-08-15T12:02:28+00:00" ],' ...
                '"dose_start_times": [ "2019-08-15T12:01:16+00:00" ],' ...
                '"dose_types": [ "bolus" ],' ...
                '"dose_value_units": "U or U/hr",' ...
                '"dose_values": [ 1.8 ],' ...
                '"dose_delivered_units": [ 1.8 ],' ...
                '"glucose_dates": [ "2019-08-14T15:59:34+00:00", "2019-08-14T16:04:34+00:00", "2019-08-14T16:09:34+00:00", "2019-08-14T16:14:34+00:00", "2019-08-14T16:19:34+00:00", "2019-08-14T16:24:34+00:00", "2019-08-14T16:29:34+00:00", "2019-08-14T16:34:34+00:00", "2019-08-14T16:39:34+00:00", "2019-08-14T16:44:34+00:00", "2019-08-14T16:49:34+00:00", "2019-08-14T16:54:34+00:00", "2019-08-14T16:59:34+00:00", "2019-08-14T17:04:34+00:00", "2019-08-14T17:09:34+00:00", "2019-08-14T17:14:34+00:00", "2019-08-14T17:19:34+00:00", "2019-08-14T17:24:34+00:00", "2019-08-14T17:29:34+00:00", "2019-08-14T17:34:34+00:00", "2019-08-14T17:39:34+00:00", "2019-08-14T17:44:34+00:00", "2019-08-14T17:49:34+00:00", "2019-08-14T17:54:34+00:00", "2019-08-14T17:59:34+00:00", "2019-08-14T18:04:34+00:00", "2019-08-14T18:09:34+00:00", "2019-08-14T18:14:34+00:00", "2019-08-14T18:19:34+00:00", "2019-08-14T18:24:34+00:00", "2019-08-14T18:29:34+00:00", "2019-08-14T18:34:34+00:00", "2019-08-14T18:39:34+00:00", "2019-08-14T18:44:34+00:00", "2019-08-14T18:49:34+00:00", "2019-08-14T18:54:34+00:00", "2019-08-14T18:59:34+00:00", "2019-08-14T19:04:34+00:00", "2019-08-14T19:14:34+00:00", "2019-08-14T19:19:34+00:00", "2019-08-14T19:24:34+00:00", "2019-08-14T19:29:34+00:00", "2019-08-14T19:34:34+00:00", "2019-08-14T19:39:34+00:00", "2019-08-14T19:44:34+00:00", "2019-08-14T19:49:34+00:00", "2019-08-14T19:54:34+00:00", "2019-08-14T19:59:34+00:00", "2019-08-14T20:04:34+00:00", "2019-08-14T20:09:34+00:00", "2019-08-14T20:14:34+00:00", "2019-08-14T20:19:34+00:00", "2019-08-14T20:24:34+00:00", "2019-08-14T20:34:34+00:00", "2019-08-14T20:39:34+00:00", "2019-08-14T20:44:34+00:00", "2019-08-14T20:49:34+00:00", "2019-08-14T20:54:34+00:00", "2019-08-14T20:59:34+00:00", "2019-08-14T21:04:34+00:00", "2019-08-14T21:09:34+00:00", "2019-08-14T21:14:34+00:00", "2019-08-14T21:19:34+00:00", "2019-08-14T21:24:34+00:00", "2019-08-14T21:29:34+00:00", "2019-08-14T21:34:34+00:00", "2019-08-14T21:39:34+00:00", "2019-08-14T21:44:34+00:00", "2019-08-14T21:49:34+00:00", "2019-08-14T21:54:34+00:00", "2019-08-14T21:59:34+00:00", "2019-08-14T22:04:34+00:00", "2019-08-14T22:09:34+00:00", "2019-08-14T22:14:34+00:00", "2019-08-14T22:19:34+00:00", "2019-08-14T22:24:34+00:00", "2019-08-14T22:29:34+00:00", "2019-08-14T22:34:34+00:00", "2019-08-14T22:39:34+00:00", "2019-08-14T22:44:34+00:00", "2019-08-14T22:49:34+00:00", "2019-08-14T22:54:34+00:00", "2019-08-14T22:59:34+00:00", "2019-08-14T23:04:34+00:00", "2019-08-14T23:09:34+00:00", "2019-08-14T23:14:34+00:00", "2019-08-14T23:19:34+00:00", "2019-08-14T23:24:34+00:00", "2019-08-14T23:29:34+00:00", "2019-08-14T23:34:34+00:00", "2019-08-14T23:39:34+00:00", "2019-08-14T23:44:34+00:00", "2019-08-14T23:49:34+00:00", "2019-08-14T23:54:34+00:00", "2019-08-14T23:59:34+00:00", "2019-08-15T00:04:34+00:00", "2019-08-15T00:09:34+00:00", "2019-08-15T00:19:34+00:00", "2019-08-15T00:24:34+00:00", "2019-08-15T00:29:34+00:00", "2019-08-15T00:34:34+00:00", "2019-08-15T00:39:34+00:00", "2019-08-15T00:49:34+00:00", "2019-08-15T00:54:34+00:00", "2019-08-15T00:59:34+00:00", "2019-08-15T01:04:34+00:00", "2019-08-15T01:09:34+00:00", "2019-08-15T01:14:34+00:00", "2019-08-15T01:19:34+00:00", "2019-08-15T01:24:34+00:00", "2019-08-15T01:29:34+00:00", "2019-08-15T01:34:34+00:00", "2019-08-15T01:44:34+00:00", "2019-08-15T01:49:34+00:00", "2019-08-15T01:54:34+00:00", "2019-08-15T01:59:34+00:00", "2019-08-15T02:04:34+00:00", "2019-08-15T02:09:34+00:00", "2019-08-15T02:14:34+00:00", "2019-08-15T02:19:34+00:00", "2019-08-15T02:24:34+00:00", "2019-08-15T02:29:34+00:00", "2019-08-15T02:34:34+00:00", "2019-08-15T02:39:34+00:00", "2019-08-15T02:44:34+00:00", "2019-08-15T02:49:34+00:00", "2019-08-15T02:54:34+00:00", "2019-08-15T02:59:34+00:00", "2019-08-15T03:04:34+00:00", "2019-08-15T03:09:34+00:00", "2019-08-15T03:14:34+00:00", "2019-08-15T03:19:34+00:00", "2019-08-15T03:24:34+00:00", "2019-08-15T03:29:34+00:00", "2019-08-15T03:34:34+00:00", "2019-08-15T03:39:34+00:00", "2019-08-15T03:44:34+00:00", "2019-08-15T03:54:34+00:00", "2019-08-15T03:59:34+00:00", "2019-08-15T04:04:34+00:00", "2019-08-15T04:09:34+00:00", "2019-08-15T04:14:34+00:00", "2019-08-15T04:19:34+00:00", "2019-08-15T04:24:34+00:00", "2019-08-15T04:29:34+00:00", "2019-08-15T04:34:34+00:00", "2019-08-15T04:39:34+00:00", "2019-08-15T04:44:34+00:00", "2019-08-15T04:49:34+00:00", "2019-08-15T04:54:34+00:00", "2019-08-15T04:59:34+00:00", "2019-08-15T05:04:34+00:00", "2019-08-15T05:14:34+00:00", "2019-08-15T05:19:34+00:00", "2019-08-15T05:24:34+00:00", "2019-08-15T05:29:34+00:00", "2019-08-15T05:34:34+00:00", "2019-08-15T05:39:34+00:00", "2019-08-15T05:44:34+00:00", "2019-08-15T05:49:34+00:00", "2019-08-15T05:54:34+00:00", "2019-08-15T05:59:34+00:00", "2019-08-15T06:04:34+00:00", "2019-08-15T06:09:34+00:00", "2019-08-15T06:14:34+00:00", "2019-08-15T06:19:34+00:00", "2019-08-15T06:24:34+00:00", "2019-08-15T06:29:34+00:00", "2019-08-15T06:34:34+00:00", "2019-08-15T06:39:34+00:00", "2019-08-15T06:44:34+00:00", "2019-08-15T06:49:34+00:00", "2019-08-15T06:54:34+00:00", "2019-08-15T06:59:34+00:00", "2019-08-15T07:04:34+00:00", "2019-08-15T07:09:34+00:00", "2019-08-15T07:14:34+00:00", "2019-08-15T07:19:34+00:00", "2019-08-15T07:24:34+00:00", "2019-08-15T07:29:34+00:00", "2019-08-15T07:34:34+00:00", "2019-08-15T07:39:34+00:00", "2019-08-15T07:44:34+00:00", "2019-08-15T07:49:34+00:00", "2019-08-15T07:54:34+00:00", "2019-08-15T07:59:34+00:00", "2019-08-15T08:04:34+00:00", "2019-08-15T08:09:34+00:00", "2019-08-15T08:14:34+00:00", "2019-08-15T08:19:34+00:00", "2019-08-15T08:24:34+00:00", "2019-08-15T08:29:34+00:00", "2019-08-15T08:34:34+00:00", "2019-08-15T08:39:34+00:00", "2019-08-15T08:44:34+00:00", "2019-08-15T08:49:34+00:00", "2019-08-15T08:59:34+00:00", "2019-08-15T09:04:34+00:00", "2019-08-15T09:09:34+00:00", "2019-08-15T09:14:34+00:00", "2019-08-15T09:19:34+00:00", "2019-08-15T09:24:34+00:00", "2019-08-15T09:29:34+00:00", "2019-08-15T09:34:34+00:00", "2019-08-15T09:39:34+00:00", "2019-08-15T09:44:34+00:00", "2019-08-15T09:49:34+00:00", "2019-08-15T09:54:34+00:00", "2019-08-15T09:59:34+00:00", "2019-08-15T10:04:34+00:00", "2019-08-15T10:09:34+00:00", "2019-08-15T10:14:34+00:00", "2019-08-15T10:19:34+00:00", "2019-08-15T10:24:34+00:00", "2019-08-15T10:29:34+00:00", "2019-08-15T10:34:34+00:00", "2019-08-15T10:39:34+00:00", "2019-08-15T10:44:34+00:00", "2019-08-15T10:49:34+00:00", "2019-08-15T10:54:34+00:00", "2019-08-15T10:59:34+00:00", "2019-08-15T11:04:34+00:00", "2019-08-15T11:09:34+00:00", "2019-08-15T11:14:34+00:00", "2019-08-15T11:19:34+00:00", "2019-08-15T11:24:34+00:00", "2019-08-15T11:29:34+00:00", "2019-08-15T11:34:34+00:00", "2019-08-15T11:39:34+00:00", "2019-08-15T11:44:34+00:00", "2019-08-15T11:49:34+00:00", "2019-08-15T11:59:34+00:00" ],' ...
                '"glucose_units": "mg/dL", ' ...
                '"glucose_values": [ 77.8431, 78.6174, 74.7099, 73.6911, 75.3619, 73.7085, 73.2515, 75.5302, 73.6933, 75.7026, 77.1816, 76.1534, 79.2052, 79.7937, 79.7537, 81.0337, 85.1745, 88.0466, 87.6304, 89.0616, 91.8319, 94.8804, 97.1487, 98.6019, 102.117, 103.847, 104.079, 105.067, 109.949, 111.65, 113.074, 113.513, 117.764, 119.16, 118.075, 120.223, 119.881, 123.29, 124.093, 125.948, 123.64, 126.71, 126.822, 125.682, 124.479, 124.334, 124.035, 119.836, 116.497, 118.028, 117.654, 114.739, 114.294, 109.69, 107.602, 105.903, 103.382, 102.263, 101.098, 96.0431, 96.7679, 92.608, 91.2174, 88.4772, 86.6316, 86.4879, 83.8147, 83.7989, 79.9742, 75.8581, 77.0695, 77.8335, 76.9333, 74.2657, 73.4788, 76.5883, 73.2023, 76.54, 73.7773, 76.6489, 77.2713, 77.085, 77.9986, 79.8621, 81.4842, 83.8608, 85.3719, 85.1984, 87.5674, 91.2177, 93.1499, 95.4969, 96.8808, 99.5071, 101.683, 100.801, 104.866, 109.019, 111.677, 111.283, 114.608, 114.652, 118.283, 120.204, 121.518, 122.023, 123.037, 126.006, 122.888, 124.091, 126.679, 125.76, 123.031, 122.901, 122.161, 121.252, 118.454, 120.972, 116.615, 115.944, 115.212, 113.465, 112.111, 111.4, 108.013, 104.554, 100.357, 101.408, 96.9136, 96.486, 92.2181, 91.1047, 89.8017, 89.1681, 86.5785, 83.4567, 80.7432, 79.6869, 77.1415, 79.0935, 75.7406, 77.025, 74.6618, 74.5476, 75.2275, 75.2536, 75.4142, 76.6245, 77.6969, 78.7665, 76.868, 78.5595, 82.1978, 83.4184, 86.9034, 87.5243, 90.0957, 91.6499, 95.0419, 95.2091, 96.5843, 101.986, 101.045, 102.766, 107.477, 108.071, 110.465, 114.103, 116.457, 117.244, 119.508, 118.518, 119.349, 122.101, 122.509, 122.785, 126.153, 125.569, 125.336, 125.132, 125.737, 125.49, 124.272, 126.277, 122.299, 122.104, 122.267, 118.216, 117.492, 117.147, 113.577, 113.347, 111.508, 109.672, 106.626, 108.043, 98.6274, 99.1374, 94.1759, 94.0125, 90.457, 91.2137, 88.4876, 86.8427, 83.5002, 81.9709, 79.6651, 81.214, 76.9306, 77.1428, 78.3553, 73.941, 76.3824, 76.9276, 74.223, 74.3457, 74.5073, 77.6573, 75.7749, 75.9766, 80.2442, 80.9427, 80.5092, 81.6895, 85.4774, 85.1116, 87.2988, 90.3004, 91.8455, 92.713, 94.8871, 100.287 ],' ...
                '"last_temporary_basal": [],' ...
                settings ...
                '"time_to_calculate_at": "2019-08-15T12:01:24+00:00" }'];


    recommendations = py.loop_data_manager_interface.parse_dictionary_from_json_string(inputDict);
    resultStruct = jsondecode(char(recommendations));
    result = resultStruct;
end
