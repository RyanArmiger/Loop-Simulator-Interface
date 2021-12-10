%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BiAP Controller
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef Loop < handle
    properties
        % Loop settings
        Settings = '';
        
        tableInsulin = [];
        glucVector = [];
        mealVector = [];
        timeVector = [];        
        bTime = 0;
        bValue = 0;
        
    end
    
    methods

        %% Constructor
        function obj = Loop(time, timeICR, ICR, timeISF, ISF, timeBasal, basal)
            
            myCell = cell(1,4);
            myCell(1,:) = {'bolus', datetime('01-01-1970 00:00:00','InputFormat','dd-MM-yyyy HH:mm:ss'), datetime('01-01-1970 00:00:00','InputFormat','dd-MM-yyyy HH:mm:ss'), 0};
            obj.bTime = timeBasal;
            obj.bValue = basal;
            obj.tableInsulin = cell2table(myCell, 'VariableNames', {'type', 'startDate', 'endDate', 'value'});
%                 Example last temp basal: [ "basal", "2019-08-15T12:01:24+00:00", "2019-08-15T12:31:24+00:00", 0.0 ]
            
            %Loop Specific
            maxBasal = max(basal);
            bArr = circshift(timeBasal,-1);
            bMinutes = (bArr - timeBasal) * 60;
            basalM = bMinutes(bMinutes > 0);
            tBasalShort = timeBasal(timeBasal < 24);
            timeBasalArr = Loop.timeArrFormat(tBasalShort);
            obj.Settings = ['"settings_dictionary": {' ...
                '"default_absorption_times": [ 120.0, 180.0, 240.0 ],' ...
                '"insulin_delay": 10,' ... % As per ExponentialInsulinModelPreset
                '"max_basal_rate": ', jsonencode(maxBasal*4), ','  ...  %Set as rule of thumb suggested in docs. Adjust to taste
                '"max_bolus": 15.0,' ...
                '"model": [ 360.0, 75 ],' ... % As per ExponentialInsulinModelPreset: humalogNovologAdult/Child 75/65
                '"rate_rounder": null,' ... % Define based on pump. Set to null for no rounding
                '"suspend_threshold": null },' ... 
                '"basal_rate_start_times": ', timeBasalArr, ',' ...
                '"basal_rate_units": "U/hr",' ...
                '"basal_rate_values": ', Loop.numArrFormat(basal), ',' ...
                '"basal_rate_minutes": ', Loop.numArrFormat(basalM), ',' ...
                '"carb_ratio_start_times": ',  Loop.timeArrFormat(timeICR), ',' ...
                '"carb_ratio_value_units": "g/U",' ...
                '"carb_ratio_values": ', Loop.numArrFormat(ICR), ',' ...
                '"carb_value_units": "g",' ...
                '"offset_applied_to_dates": 0,' ...
                '"sensitivity_ratio_end_times": ', Loop.timeArrFormat(circshift(timeISF,-1)), ',' ...
                '"sensitivity_ratio_start_times": ', Loop.timeArrFormat(timeISF), ',' ...
                '"sensitivity_ratio_value_units": "mg/dL/U",' ...
                '"sensitivity_ratio_values": ', Loop.numArrFormat(ISF), ',' ... 
                '"target_range_end_times": [ "00:00:00" ],' ...
                '"target_range_maximum_values": [ 110.0 ],' ...
                '"target_range_minimum_values": [ 80.0 ],' ...
                '"target_range_start_times": [ "00:00:00" ],' ...
                '"target_range_value_units": "mg/dL",']; 
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Loop_run
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [Insulin, BasalRate] = Loop_run(obj, Time, G, Meal, Exercise)

%           filter non 0 doses
            formatOut = 'yyyy-mm-ddTHH:MM:SS+00:00';
            timeToCalculate = jsonencode(datestr(Time,formatOut));
            basalIns = obj.tableInsulin(strcmp(obj.tableInsulin.type, 'tempbasal'), :);
            if isempty(basalIns) == 0 
                
                stringBasalIns = basalIns(end,:);
                
                altEndDate =  datestr(min(Time, stringBasalIns.endDate), formatOut);

                stringBasalIns.startDate = datestr(stringBasalIns.startDate,formatOut);
                stringBasalIns.endDate = datestr(stringBasalIns.endDate,formatOut);

%             [ "basal", "2019-08-15T12:01:24+00:00", "2019-08-15T12:31:24+00:00", 0.0 ]

                stringBasalInsAlt = stringBasalIns;
                stringBasalInsAlt.endDate = altEndDate;
                lastTempRateAlt = jsonencode(table2cell(stringBasalInsAlt));
                
            else 
                lastTempRateAlt = '[]';
            end
             
            
            dateFilter = Time - hours(6);
            dateFilterMI = Time - hours(6);
            dateFilterM = Time - hours(6); 

            filteredInsulin = obj.tableInsulin(obj.tableInsulin.startDate > dateFilterMI, :);
            
            filteredInsulinAlt = filteredInsulin;
            tempIdxs = strcmp(filteredInsulinAlt.type, 'tempbasal');
            trIdx = find(tempIdxs,1,'last');
            filteredInsulinAlt.endDate(trIdx) =  min(Time, filteredInsulinAlt.endDate(trIdx));
            tempIdxs = strcmp(filteredInsulinAlt.type, 'basal');
            basIdx = find(tempIdxs,1,'last');
            filteredInsulinAlt.endDate(basIdx) =  min(Time, filteredInsulinAlt.endDate(basIdx));
                        
            filteredGluc = obj.glucVector(obj.timeVector > dateFilter);
            filteredTimestamp = obj.timeVector(obj.timeVector > dateFilter);
            filteredMeal = obj.mealVector((obj.timeVector > dateFilterM & obj.mealVector > 0));
            filteredMealDates = obj.timeVector((obj.timeVector > dateFilterM & obj.mealVector > 0));
            absorptionTimes = 180*ones(1,length(filteredMeal)); %default meal absorptions
             
            inputDictAlt = ['{"carb_absorption_times": ', Loop.numArrFormat(absorptionTimes), ',' ...
                '"carb_dates": ', Loop.dateArrFormat(filteredMealDates), ',' ...
                '"carb_values": ', Loop.numArrFormat(filteredMeal), ',' ...
                '"dose_end_times": ', Loop.dateArrFormat(filteredInsulinAlt.endDate), ',' ...
                '"dose_start_times": ', Loop.dateArrFormat(filteredInsulinAlt.startDate), ',' ...
                '"dose_types": ', jsonencode(filteredInsulinAlt.type), ',' ...
                '"dose_value_units": "U or U/hr",' ...
                '"dose_values": ', Loop.numArrFormat(filteredInsulinAlt.value.'), ',' ...
                '"dose_delivered_units": ', Loop.nullArrFormat(filteredInsulinAlt.value.'), ',' ...
                '"glucose_dates": ', Loop.dateArrFormat(filteredTimestamp), ',' ...
                '"glucose_units": "mg/dL", ' ...
                '"glucose_values": ', Loop.numArrFormat(filteredGluc) , ',' ...
                '"last_temporary_basal": ', lastTempRateAlt, ',' ...
                obj.Settings ...
                '"time_to_calculate_at": ', timeToCalculate, '}'];            
            recommendationsAlt = py.loop_data_manager_interface.parse_dictionary_from_json_string(inputDictAlt);

            resultStruct = jsondecode(char(recommendationsAlt));

            %get last temp rate idx
            tempIdxs = strcmp(obj.tableInsulin.type, 'tempbasal');
            trIdx = find(tempIdxs,1,'last');
            %get last basal          
            basalIdxs = strcmp(obj.tableInsulin.type, 'basal');
            basIdx = find(basalIdxs,1,'last');          
            %get last susp
            suspIdxs = strcmp(obj.tableInsulin.type, 'suspend');
            suspIdx = find(suspIdxs,1,'last');  
            lastIdx = max([trIdx, basIdx, suspIdx]);
            Insulin = 0;
            [BasalRate, ScheduledEnd] = Loop.select_basal_insulin(obj.bValue,obj.bTime,Time); %Set to scheduled rate as default
            EndDate = Time + minutes(ScheduledEnd);

            if isstruct(resultStruct) == 1
                if isempty(resultStruct.recommended_temp_basal) == 0
                    BasalDuration = resultStruct.recommended_temp_basal(2);
                    if BasalDuration == 0 % Cancel temp rate                         
                        obj.tableInsulin.endDate(lastIdx) = min(Time, obj.tableInsulin.endDate(lastIdx)); %Set previous rate as ended if not already
                        obj.tableInsulin = [obj.tableInsulin;  {'basal', Time, EndDate, BasalRate}];  

                    else % Set new temp rate                        
%                         Set previous rate as ended whether basal or
%                         tempbasal
                        obj.tableInsulin.endDate(lastIdx) = min(Time, obj.tableInsulin.endDate(lastIdx)); %Set previous rate as ended if not already
                        BasalRate = resultStruct.recommended_temp_basal(1);
%                         if basal rate 0 add suspend else add tempbasal
                        EndDate = Time + minutes(BasalDuration);
                        if BasalRate == 0
                             obj.tableInsulin = [obj.tableInsulin;  {'tempbasal', Time, EndDate, BasalRate}]; 
                         else
                            obj.tableInsulin = [obj.tableInsulin;  {'tempbasal', Time, EndDate, BasalRate}]; 
                         end
                    end          
                else % Keep current temp/ transfer to scheduled after duration
                    if  Time < obj.tableInsulin.endDate(lastIdx)
                        BasalRate = obj.tableInsulin.value(lastIdx);
                    else
                        obj.tableInsulin = [obj.tableInsulin;  {'basal', Time, EndDate, BasalRate}];  
                    end
                end
                
                if isempty(resultStruct.recommended_bolus) == 0
                    if iscell(resultStruct.recommended_bolus(1,1)) == 1
                        InsulinCell = resultStruct.recommended_bolus(1,1);
                        Insulin = InsulinCell{1};
                    else
                        Insulin = resultStruct.recommended_bolus(1,1);
                    end

                end
            end
                        
        end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    methods (Static)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% select_basal_insulin: select basal from basal profile
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [currentBasal, scheduledEnd] = select_basal_insulin(basal, timeBasal, time)


            % ACCESS TABLES@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   
            startBasal1 = timeBasal(1);
            endBasal1 = timeBasal(2);
            basal1 = basal(1);
            startBasal2 = timeBasal(2);
            endBasal2 = timeBasal(1);
            basal2 = basal(2);
            % @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       

            % transission 
            if endBasal1 < startBasal1 
                pmamTransition1 = true;
            else
                pmamTransition1 = false;  
            end

            if endBasal2 < startBasal2 
                pmamTransition2 = true;
            else
                pmamTransition2 = false;  
            end

            if (~pmamTransition1 && time.Hour >= startBasal1 && time.Hour < endBasal1) || (pmamTransition1 && (time.Hour < endBasal1 || time.Hour >= startBasal1))
              if endBasal1 == 0
                  endHour = 24;
              else
                  endHour = endBasal1;
              end
              currentBasal = basal1;
              scheduledEnd = (endHour*60) - (time.Hour * 60 + time.Minute);
            elseif (~pmamTransition2 && time.Hour >= startBasal2 && time.Hour < endBasal2) || (pmamTransition2 && (time.Hour < endBasal2 || time.Hour >= startBasal2))
              if endBasal2 == 0
                  endHour = 24;
              else
                  endHour = endBasal2;
              end
              currentBasal = basal2;
              scheduledEnd = (endHour*60) - (time.Hour * 60 + time.Minute);
            end
            
            if scheduledEnd < 0 
                fprintf('bad');
            end
         
        end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function str = timeArrFormat(Arr)
            formatOut = 'HH:MM:SS';
            if length(Arr) > 1
                dateArr = arrayfun(@(x) datenum([0, 0, 0, x, 0, 0]),Arr);
                str = jsonencode(datestr(dateArr,formatOut));
            elseif length(Arr) == 1
                dateArr = arrayfun(@(x) datenum([0, 0, 0, x, 0, 0]),Arr);
                str = ['[', jsonencode(datestr(dateArr,formatOut)),']'];
            else 
                str = '[]';
            end
        end       
        function str = numArrFormat(Arr)
            str =  ['[',regexprep(num2str(Arr),'\s+',','),']'];
        end
        function str = nullArrFormat(Arr)
            str = '[';
            for i = 1:length(Arr)
                if i ~= length(Arr)
                    str = append(str,'null,');
                else 
                    str = append(str,'null');
                end
            end
            str = append(str,']');
        end
        function str = dateArrFormat(Arr)
            formatOut = 'yyyy-mm-ddTHH:MM:SS+00:00';
            if length(Arr) > 1
                str = jsonencode(datestr(Arr,formatOut));
            elseif length(Arr) == 1
                str = ['[', jsonencode(datestr(Arr,formatOut)),']'];
            else
                str = '[]';
            end
        end
        
        
    end
    
    
end
