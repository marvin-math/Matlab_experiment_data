
%Please save this file to the folder where you saved the
%participants data. The code operates on the current folder. The functions
%are saved at the end of this file. This is
%just because I thought it neater for you just having to download one file
%in the correct folder.
%you can just run the whole file. All tasks will be executed.


% read in the data of the Participants and restructure it. One .csv file per participant.
all_files = dir(pwd);
sub_files = dir([pwd filesep '*-face_task.log']);
nos = size(sub_files,1);

block_count = 0;
trial_count = 1;
current_row = 1;


for j=1:nos
    data = cell2table (cell(0,7), 'VariableNames', {'ID', 'block', 'trial', 'task', 'protagonist', 'emotion', 'rt(ms)'});
    table_ = readtable(sub_files(j).name, 'Delimiter', '\t');
    nos1 = size(table_,1);
    for i=1:nos1 %iterates through all the rows
        event_type = table_{i, 3}; %identifies the EventType of that row
        if strcmpi(event_type,'Picture')
            type_str_ = table_{i, 5};
            if strcmpi(type_str_,'stm')
                % if it is a stimulus, get task, protagonist and id
                [task, protagonist] = parse_cond_to_string(table_{i, 6});
                emotion = parse_emotion_to_string(table_{i, 7});
                id = table_{i, 1};

                % skip all entries until Response
                i = i + 1;
                while ~strcmpi(table_{i, 3}, 'Response')
                    i = i + 1;
                end
                
                % get response time in milliseconds
                response_time = table_{i, 9} / 10;
                
                %define row and order in which row elements are to be
                %displayed
                row = {id block_count trial_count task protagonist emotion response_time};
                data = [data; row];

                trial_count = trial_count + 1;
            end
            
            % if type_str_ is txt, start new block, start trial count again
            if strcmpi(type_str_,'txt')
                block_count = block_count + 1;
                trial_count = 1;
            end
        end
        filename = ['proband', num2str(j), '.csv'];
        writetable(data, filename)
    end
end


% statistical analysis of the data
sub_files_2 = dir([pwd filesep 'proband*.csv']);
nos2 = size(sub_files_2,1);
final_table = [];
for e = 1 : nos2
    table2 = readtable(sub_files_2(e).name);
    categories = {'ID', 'task', 'protagonist', 'emotion'};
    median_table2 = groupsummary(table2, categories, 'median', 'rt_ms_'); %compute median for all possible combinations of task, protagonist, emotion
    mean_table2 = groupsummary(table2, categories, 'mean', 'rt_ms_'); %the same as above for mean
    std_table2 = groupsummary(table2, categories, 'std', 'rt_ms_'); %the same as above for sd
    summary_table = [median_table2(:, [1 2 3 4 6]) mean_table2(:,6) std_table2(:,6)]; %combine the relevant parts of the above tables 
    final_table = [final_table; summary_table]; %combine the summary tables of all probands
end
disp(final_table)
filename1 = 'summarytable.csv' ;
writetable(final_table, filename1);


% which task was the hardest, based on reaction times? --> I first
% calculated the sums of the means of the respective task types and then
% averaged them. These overall averages are somewhat comparable as sample 
% sizes are identical.

aff_data = 0;
ctr_data = 0;
tom_data = 0;
nos3 = size(final_table, 1);
for z=1:nos3
    
    task_type = final_table{z, 2};
    if strcmpi(task_type, 'aff')
        mean_aff = final_table{z, 6};
        aff_data = aff_data+mean_aff;
        
    elseif strcmpi(task_type, 'tom')
        mean_tom = final_table{z, 6};
        tom_data = tom_data+mean_tom;
        
    elseif strcmpi(task_type, 'ctr')
        mean_ctr = final_table{z, 6};
        ctr_data = ctr_data+mean_ctr;
     
    end

end

overall_mean_aff = aff_data / 24; % calculate the mean of all means of task type 'aff'
overall_mean_tom = tom_data / 24; % calculate the mean of all means of task type 'tom'
overall_mean_ctr = ctr_data / 24; % calculate the mean of all means of task type 'ctr'

x =  categorical({'Affect Recognition','Theory of Mind','Control'});
y = [overall_mean_aff overall_mean_tom overall_mean_ctr];
bar(x,y)

id = fopen('questions.txt','w');
fprintf(id,'Based on the reaction times, it seems that the control condition with an overall average reaction time of %i was the hardest task.\nTheory of mind with an overall average reaction time of %i was the second hardest task.\n Affect recognition with an overall average reaction time of %i was the easiest task.\nThese results are also visible in the bar graph.\nThe findings seem to make sense if one considers that people tend to make emotional inferences upon inspecting a face.\nFrom an evolutionary point of view it will also make sense to infer a likely cause of action of a person. It thus seems plausbile that random,\nnon-emotional inferences are harder and require more time.', overall_mean_ctr, overall_mean_tom, overall_mean_aff);
fclose(id);

%functions
function [task, protagonist] = parse_cond_to_string(cond_num)
%this function takes a condition number as input and outputs the task and
%protagonist that the number codes for. Example: if input: cond_num = 1,
%the function will output: task = "tom" and protagonist = "child"
    if cond_num == 1
        task = "tom";
        protagonist = "child";
    elseif cond_num == 2
        task = "aff";
        protagonist = "child";
    elseif cond_num == 3
        task = "ctr";
        protagonist = "child";
    elseif cond_num == 4
        task = "tom";
        protagonist = "adult";
    elseif cond_num == 5
        task = "aff";
        protagonist = "adult";
    elseif cond_num == 6
        task = "ctr";
        protagonist = "adult";
    end
    
end

function emotion = parse_emotion_to_string(emotion_num)
%this function takes a emotion number as input and outputs the emotion
%that the number codes for. Example: if input: emotion_num = 1,
%the function will output: emotion = "anger"
    if emotion_num == 1
        emotion = "anger";
    elseif emotion_num == 2
        emotion = "happiness";
    elseif emotion_num == 3
        emotion = "fear";
    end
end







