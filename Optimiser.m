function varargout = Optimiser(varargin)
% OPTIMISER MATLAB code for Optimiser.fig
%      OPTIMISER, by itself, creates a new OPTIMISER or raises the existing
%      singleton*.
%
%      H = OPTIMISER returns the handle to a new OPTIMISER or the handle to
%      the existing singleton*.
%
%      OPTIMISER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTIMISER.M with the given input arguments.
%
%      OPTIMISER('Property','Value',...) creates a new OPTIMISER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Optimiser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Optimiser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Optimiser

% Last Modified by GUIDE v2.5 06-Jan-2017 13:45:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Optimiser_OpeningFcn, ...
                   'gui_OutputFcn',  @Optimiser_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Optimiser is made visible.
function Optimiser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Optimiser (see VARARGIN)


% Choose default command line output for Optimiser
handles.output = hObject;
axes(handles.axes1);
imshow('pl.bmp'); %Shows image in format jpg
set(handles.uitable4,'visible','off'); %Can't see table before button is pushed 
set(handles.Display,'visible','off'); % Can't see team name before button pushed
set(handles.Enter_Team_Name,'String','Please Enter Team Name');
[y,Fs] = audioread('song.wav');
sound(y,Fs);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes Optimiser wait for user response (see UIRESUME)
% uiwait(handles.Optimiser);


% --- Outputs from this function are returned to the command line.
function varargout = Optimiser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Clear_All.
function Clear_All_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_All (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uitable4,'visible','off');
set(handles.Display,'String',''); %Clear All Button by setting display to empty string 
set(handles.Enter_Team_Name,'String','Please Enter Team Name'); %Reset Name
% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear sound  % Turn off audio
clc; %Clears command Window 
set(handles.Optimiser,'visible','off'); %Closes down window 
% --- Executes on button press in Data16.
function Data16_Callback(hObject, eventdata, handles)
% hObject    handle to Data16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Hold on (approx 30 Seconds) while the machine crunches some BIG data - sit back and listen to the Premier League theme tune in the meantime... ','Please Wait','Help'); %Message as button will not display results immediately 

%% Scrape and Json
addpath('JSONlab_ a toolbox to encode_decode JSON files/code/jsonlab','-END'); % Automatically adds script to the json path to run the scraped data
scrapedata = urlread('https://fantasy.premierleague.com/drf/bootstrap-static'); %Scraping from source
extracteddata = loadjson(scrapedata); %Use Json Parser to translate into structure

%% Create loop to extract information
fieldnames_elements = fieldnames(extracteddata.elements{1}); %Extract the variable names
fieldnames_elements = (fieldnames_elements)'; %Invert to make the dimensions consistent
vars = {'first_name','second_name','chance_of_playing_next_round'...
        'total_points','team','element_type','now_cost'}; 

for i = 1:length(extracteddata.elements) 
    interimstructure = extracteddata.elements{i}; % For every input select the data point which is in a structure
    interimstructure = struct2cell(interimstructure); % Individual column of information for each player
    interimstructure = interimstructure'; %Transfers to row
    WorkingTable(i,:) = array2table(interimstructure,'VariableNames',fieldnames_elements); % Adds to table 
end
    WorkingTable = WorkingTable(:,vars); %Narrow table down to include required variables 

%% Turning cells into numbers
temporarystructure = zeros(size(WorkingTable,1),7); %Preset empty matrix
for i=1:size(WorkingTable,1)
    for j = 3:7 % For each data point that isn't first or second name       
        celltonumber = WorkingTable(i,j);
        celltonumber = table2array(celltonumber); %Turn it into array
        celltonumber = cell2mat(celltonumber); %Cell to number
        celltonumber = num2str(celltonumber); %Cannot read '[]' so must turn it into a string
            if isempty(celltonumber) %'[]' returns empty string - replace with 0
                celltonumber = '0';
            else 
            end
        celltonumber = str2num(celltonumber); %Turn it back into a number
        temporarystructure(i,j) = celltonumber; %Fill in preset matrix
    end
end            
 
% Join table back together
Vars = {'chance_of_playing_next_round','total_points','team',...
    'element_type','now_cost'};
temporarystructure = array2table(temporarystructure(:,3:7),'VariableNames',Vars); % Forms table with the usable data in the last four columns of C
WorkingTable = WorkingTable(:,1:2); % Removes the four columns to be replaced by D
WorkingTable = [WorkingTable temporarystructure]; %Joins table

%% Names Concetenated and replacing separate names
for i=1:size(WorkingTable,1) 
    separatenames = [table2array(WorkingTable(i,1)),table2array(WorkingTable(i,2))]; %Turn each name into array
    wholename = strjoin(separatenames); %First and second names concetenated
    Finalnames{i} = wholename; %Create string array
end  
Finalnames = Finalnames'; %Originally a row vector - turn it into a column
vars1={'Player'};
Finalnames = array2table(Finalnames,'VariableNames',vars1);
WorkingTable = WorkingTable(:,3:7); %Remove first and second names from original table and join table with player column
WorkingTable = [Finalnames WorkingTable];

%% Ensure Format Matches
% In order for the optimisation used in the case with data to work, the
% table must be in the same format - that means transferring the
% position numbers to actual positions, team numbers to team names,cost to 
% the same format and column headers to match

%Positions
for i = 1:size(WorkingTable,1)
    if WorkingTable.element_type(i) == 1; %element_type = 1 indicates a goalkeeper
        positions{i} = 'Goalkeeper';
    elseif WorkingTable.element_type(i) == 2; 
        positions{i} = 'Defender';
    elseif WorkingTable.element_type(i) == 3;
        positions{i} = 'Midfielder';
    else WorkingTable.element_type(i) == 4;
        positions{i} = 'Forward';
    end
end
positions = positions';
vars = {'Position'};
X = array2table(positions,'VariableNames',vars);
WorkingTable = [WorkingTable X];

WorkingTable.Value = WorkingTable.now_cost/10; %Turning cost into same format
WorkingTable.Points = WorkingTable.total_points; %Renaming points field

%% Turn team number into club name
%Extract team names from scrape data
fieldnames_teams = fieldnames(extracteddata.teams{1}); %Extract the variable names
fieldnames_teams = fieldnames_teams'; %Change orientation to fit
for i = 1:length(extracteddata.teams) % For every input select the data point
    teamnames = extracteddata.teams{i};
    teamnames = struct2cell(teamnames); % Individual column of information for each player
    teamnames = teamnames'; %Transfers to row
    Teamnames(i,:) = array2table(teamnames,'VariableNames',fieldnames_teams); % Adds to table 
end
Teamnames = Teamnames.name;

% For every input: if the team number is x, match it with the team in 'xth'
% position as just extracted in table 'Teamnames'
for i = 1:size(WorkingTable,1)
    if WorkingTable.team(i) == 1;
        TeamNameFinal{i} = Teamnames{1};
    elseif WorkingTable.team(i) == 2 ;
        TeamNameFinal{i} = Teamnames{2};
    elseif WorkingTable.team(i) == 3 ;
        TeamNameFinal{i} = Teamnames{3};
    elseif WorkingTable.team(i) == 4 ;
        TeamNameFinal{i} = Teamnames{4};
    elseif WorkingTable.team(i) == 5 ;
        TeamNameFinal{i} = Teamnames{5};
    elseif WorkingTable.team(i) == 6 ;
        TeamNameFinal{i} = Teamnames{6};
    elseif WorkingTable.team(i) == 7 ;
        TeamNameFinal{i} = Teamnames{7};
    elseif WorkingTable.team(i) == 8 ;
        TeamNameFinal{i} = Teamnames{8};
    elseif WorkingTable.team(i) == 9 ;
        TeamNameFinal{i} = Teamnames{9};
    elseif WorkingTable.team(i) == 10 ;
        TeamNameFinal{i} = Teamnames{10};
    elseif WorkingTable.team(i) == 11;
        TeamNameFinal{i} = Teamnames{11};
    elseif WorkingTable.team(i) == 12;
        TeamNameFinal{i} = Teamnames{12};
    elseif WorkingTable.team(i) == 13;
        TeamNameFinal{i} = Teamnames{13};
    elseif WorkingTable.team(i) == 14;
        TeamNameFinal{i} = Teamnames{14};
    elseif WorkingTable.team(i) == 15;
        TeamNameFinal{i} = Teamnames{15};
    elseif WorkingTable.team(i) == 16;
        TeamNameFinal{i} = Teamnames{16};
    elseif WorkingTable.team(i) == 17;
        TeamNameFinal{i} = Teamnames{17};
    elseif WorkingTable.team(i) == 18;
        TeamNameFinal{i} = Teamnames{18};
    elseif WorkingTable.team(i) == 19;
        TeamNameFinal{i} = Teamnames{19};
    else WorkingTable.team(i) == 20;
        TeamNameFinal{i} = Teamnames{20};
    end
end
vars = {'Club'};
TeamNameFinal = TeamNameFinal'; 
Teamnames = array2table(TeamNameFinal,'VariableNames',vars);
WorkingTable = [WorkingTable Teamnames]; %Turn it into a column vector and join with initial table

%% Chance of playing next round
WorkingTable(WorkingTable.chance_of_playing_next_round<25,:) = []; %If the chance of playing the following week is less than 25%, remove the player

%% Summarise into same form as original table
vars = {'Player','Club','Position','Value','Points'};
FinalTable = WorkingTable(:,vars); %Create the final table using the variables we require
FinalTable.avpoints = FinalTable.Points./FinalTable.Value;

%% Optimisation Method
% Preset for ease
GK = 'Goalkeeper';
DF = 'Defender';
MF = 'Midfielder';
FW = 'Forward';

% Sort into separate tables according to position
GkTable = FinalTable(strcmp(FinalTable.Position,GK),:); % Use index to extract all rows 
DfTable = FinalTable(strcmp(FinalTable.Position,DF),:); %The same applied to DF, MF and FW
MfTable = FinalTable(strcmp(FinalTable.Position,MF),:);
FwTable = FinalTable(strcmp(FinalTable.Position,FW),:);

GkTable = sortrows(GkTable,'Points','Descend');
DfTable = sortrows(DfTable,'Points','Descend');
MfTable = sortrows(MfTable,'Points','Descend');
FwTable = sortrows(FwTable,'Points','Descend');

for w = 1:2 % 2 Highest Scoring GKS
finalteam(w,:) = GkTable(w,:);
end
for x = 1:5 % 5 Highest Scoring DFs
finalteam(x+2,:) = DfTable(x,:);
end  
for y = 1:5 % 5 Highest Scoring MFs
finalteam(y+7,:) = MfTable(y,:);
end
for z = 1:3 % 3 Highest Scoring FWs
finalteam(z+12,:) = FwTable(z,:);
end

GkInitial = finalteam(strcmp(finalteam.Position,GK),:); % Use index to extract rows and save for future use/reference
DfInitial = finalteam(strcmp(finalteam.Position,DF),:); %The same applied to DF, MF and FW
MfInitial = finalteam(strcmp(finalteam.Position,MF),:);
FwInitial = finalteam(strcmp(finalteam.Position,FW),:);

%% Optimisation 

gk = 3;%Preset starting positions for alternative
df = 6;
mf = 6;
fw = 4;
for i=1
while sum(finalteam.Value)>100 
    finalteam = sortrows(finalteam,'avpoints','ascend');
        if strcmp(finalteam.Position(i),GK); %If player with lowest avpoints is a GK, replace with next in line in GKTABLE
            finalteam(i,:) = GkTable(gk,:);
            gk = gk+1;
        elseif strcmp(finalteam.Position(i),DF);
            finalteam(i,:) = DfTable(df,:);
            df = df+1;
        elseif strcmp(finalteam.Position(i),MF);
            finalteam(i,:) = MfTable(mf,:);
            mf = mf+1;
        elseif strcmp(finalteam.Position(i),FW);
            finalteam(i,:) = FwTable(fw,:);
            fw = fw+1;
        end
        if fw == size(FwTable,1)+1||mf == size(MfTable,1)+1||df == size(DfTable,1)+1||gk == size(GkTable,1)+1 %If we reach the point where the counter is greater than the size, break the loop
            break
        else
            continue
        end
end
end

%%
% The following clauses are to address the issue of one position being particularly
% poor. If this is the case then it will run through the above until the
% number reaches the limit and you will end up with the lowest avpoints
% making it into the team. This is not perfect but is a much better
% alternative - it chooses the best average players in the position of 
% question and then solves for the rest of the team.

if size(GkTable,1)<gk %If it has run through every possibility gk>height(gktable)   
    gk = 3;% Reset counters
    df = 6;
    mf = 6;
    fw = 4;
    GkTable = sortrows(GkTable,'avpoints','descend'); %Sort by average point
    Goalkeepers= GkTable(1:2,:); %Choose the top two goalkeepers by average points
    restofteam = [DfInitial;MfInitial;FwInitial]; %Choose the original starting players to optimise from
        while sum(restofteam.Value)>(100-sum(Goalkeepers.Value)) %Carry out the optimisation as above, but having preset one position (in this case goalkeepers)             
        restofteam = sortrows(restofteam,'avpoints','ascend');
                if strcmp(restofteam.Position(i),FW)
                restofteam(i,:) = FwTable(fw,:);
                fw = fw+1;
                elseif strcmp(restofteam.Position(i),DF)
                restofteam(i,:) = DfTable(df,:);
                df = df+1;
                elseif strcmp(restofteam.Position(i),MF);
                restofteam(i,:) = MfTable(mf,:);
                mf = mf+1;
                end
        end
finalteam= [restofteam;Goalkeepers];

elseif size(DfTable,1)<df
    gk = 3;% Reset counters
    df = 6;
    mf = 6;
    fw = 4;
    DfTable = sortrows(DfTable,'avpoints','descend');
    Defenders = DfTable(1:5,:);
    restofteam = [GkInitial;FwInitial;MfInitial];
        while sum(restofteam.Value)> (100-sum(Defenders.Value))            
        restofteam = sortrows(restofteam,'avpoints','ascend');
                if strcmp(restofteam.Position(i),GK)
                restofteam(i,:) = GkTable(gk,:);
                gk = gk+1;
                elseif strcmp(restofteam.Position(i),FW)
                restofteam(i,:) = FwTable(fw,:);
                fw = fw+1;
                elseif strcmp(restofteam.Position(i),MF);
                restofteam(i,:) = MfTable(mf,:);
                mf = mf+1;
                end
        end
finalteam= [restofteam;Defenders]

elseif size(MfTable,1)<mf
    gk = 3;% Reset counters
    df = 6;
    mf = 6;
    fw = 4;
    MfTable = sortrows(MfTable,'avpoints','descend');
    Midfielders = MfTable(1:5,:);
    restofteam = [GkInitial;DfInitial;FwInitial];
        while sum(restofteam.Value)> (100-sum(Midfielders.Value))            
        restofteam = sortrows(restofteam,'avpoints','ascend');
                if strcmp(restofteam.Position(i),GK)
                restofteam(i,:) = GkTable(gk,:);
                gk = gk+1;
                elseif strcmp(restofteam.Position(i),DF)
                restofteam(i,:) = DfTable(df,:);
                df = df+1;
                elseif strcmp(restofteam.Position(i),FW)
                restofteam(i,:) = FwTable(fw,:);
                fw = fw+1;
                end
        end
finalteam= [restofteam;Midfielders]

elseif size(FwTable,1)<fw
    gk = 3;% Reset counters
    df = 6;
    mf = 6;
    fw = 4;
    FwTable = sortrows(FwTable,'avpoints','descend');
    Forwards= FwTable(1:3,:);
    amount = sum(Forwards.Value);
    restofteam = [GkInitial;DfInitial;MfInitial];
        while sum(restofteam.Value)>(100-sum(Forwards.Value))            
        restofteam = sortrows(restofteam,'avpoints','ascend');
                if strcmp(restofteam.Position(i),GK)
                restofteam(i,:) = GkTable(gk,:);
                gk = gk+1;
                elseif strcmp(restofteam.Position(i),DF)
                restofteam(i,:) = DfTable(df,:);
                df = df+1;
                elseif strcmp(restofteam.Position(i),MF);
                restofteam(i,:) = MfTable(mf,:);
                mf = mf+1;
                end
        end
finalteam= [restofteam;Forwards];
end

%% Same club section
% This addresses the 'no more than three players per team' rule
while 1
originalteam = finalteam; 
clubnames = unique(finalteam.Club);
    for j = 1:size(clubnames,1) 
            if sum(strcmp(finalteam.Club,clubnames(j)))>3; % Count occurences of each team, if it's greater break and create a new team
                withdraw = strcmp(finalteam.Club,clubnames(j));
                newtable = finalteam(withdraw,:); %Withdraws the players of teams with more than three players
                newtable = sortrows(newtable,'avpoints','ascend');
                for t = 1:height(finalteam)
                    if finalteam.avpoints(t) == newtable.avpoints(1) && strcmp(newtable.Position(1),GK);
                        finalteam(t,:) = GkTable(gk,:); % Locate and replace the player with the lowest avpoints
                        gk = gk+1 ;
                    elseif finalteam.avpoints(t) == newtable.avpoints(1) && strcmp(newtable.Position(1),DF);
                        finalteam(t,:) = DfTable(df,:);
                        df = df+1;
                    elseif finalteam.avpoints(t) == newtable.avpoints(1) && strcmp(newtable.Position(1),MF);
                        finalteam(t,:) = MfTable(mf,:);
                        mf = mf+1;
                    elseif finalteam.avpoints(t) == newtable.avpoints(1) && strcmp(newtable.Position(1),FW);
                        finalteam(t,:) = FwTable(fw,:);
                        fw = fw+1;
                    end
                end
            else
                
            end
    end
if isequal(originalteam,finalteam); %If no change, break the cycle
break
end
end

%% Selecting captain 
finalteam=sortrows(finalteam,'Points','Descend'); %Sorts rows by point
NewName = strcat(finalteam.Player(1),' (C)');  %Adds 'C' to the highest scorer
finalteam.Player(1) = NewName; %Replaces original name
finalteam.Points(1) = finalteam.Points(1)*2; %Multiplies captain's points by two

%% Sorting and creating final array
finalteam=sortrows(finalteam,'Position','Ascend');
totalvalue = sum(finalteam.Value);
totalpoints = sum(finalteam.Points);
player = [finalteam.Player;'15'];%Create arrays - 15 players,clubs,position,points,values and totals 
club = [finalteam.Club; size(unique(finalteam.Club),1)];
positions = [finalteam.Position;'4'];
points=[finalteam.Points;totalpoints];
value=[finalteam.Value;totalvalue];
points=num2cell(points);
value=num2cell(value);

finalarray = [player,positions,club,points,value];


set(handles.Display,'visible', 'on');
set(handles.Display,'String',get(handles.Enter_Team_Name,'String')); %Gets Team Name entered displays above table
set(handles.uitable4,'visible','on'); % See Table when button is pressed
set(handles.uitable4,'Data',finalarray); % Display table in format above  



% --- Executes on button press in Data15.
function Data15_Callback(hObject, eventdata, handles)
% hObject    handle to Data15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Hold on while the machine crunches some BIG data (approx 30 Seconds)','Please Wait','Help'); %Message as button will not display results immediately
%% Import and sort data
warning('off','all');
% Import data into a table with variables as the column names
InitialTable = readtable('CompiledStatistics.xlsx');
GoalsPerClub = readtable('GoalsConcededPerClub.xlsx','ReadRowNames',true);

%% Calculating the amount of times each time conceded over 2 goals
GoalsPerClub.ConcededOver2 = GoalsPerClub.x3Conceded+GoalsPerClub.x4Conceded; %Calculate number of times conceded over 2 goals
GoalsPerClub.PercentOver2 = GoalsPerClub.ConcededOver2/38; %Calculate percentage of games conceded over 2
GoalsPerClub = GoalsPerClub.PercentOver2; %Disregard the rest of the table and keep the percentage figure

% For each row in the InitialTable, set the percentage over 2 for their
% individual team
for i = 1:size(InitialTable,1)  
    if strcmp(InitialTable.Club(i),'AFC Bournemouth');
        InitialTable.PercentageOver2(i) = GoalsPerClub(1);
    elseif strcmp(InitialTable.Club(i),'Arsenal');
        InitialTable.PercentageOver2(i) = GoalsPerClub(2);
    elseif strcmp(InitialTable.Club(i),'Aston Villa');
        InitialTable.PercentageOver2(i) = GoalsPerClub(3);
    elseif strcmp(InitialTable.Club(i),'Chelsea');
        InitialTable.PercentageOver2(i) = GoalsPerClub(4);
    elseif strcmp(InitialTable.Club(i),'Crystal Palace');
        InitialTable.PercentageOver2(i) = GoalsPerClub(5);
    elseif strcmp(InitialTable.Club(i),'Everton');
        InitialTable.PercentageOver2(i) = GoalsPerClub(6);
    elseif strcmp(InitialTable.Club(i),'Leicester City');
        InitialTable.PercentageOver2(i) = GoalsPerClub(7);
    elseif strcmp(InitialTable.Club(i),'Liverpool');
        InitialTable.PercentageOver2(i) = GoalsPerClub(8);
    elseif strcmp(InitialTable.Club(i),'Manchester City');
        InitialTable.PercentageOver2(i) = GoalsPerClub(9);
    elseif strcmp(InitialTable.Club(i),'Manchester United');
        InitialTable.PercentageOver2(i) = GoalsPerClub(10);
    elseif strcmp(InitialTable.Club(i),'Newcastle United');
        InitialTable.PercentageOver2(i) = GoalsPerClub(11);
    elseif strcmp(InitialTable.Club(i),'Norwich City');
        InitialTable.PercentageOver2(i) = GoalsPerClub(12);
    elseif strcmp(InitialTable.Club(i),'Southampton');
        InitialTable.PercentageOver2(i) = GoalsPerClub(13);
    elseif strcmp(InitialTable.Club(i),'Stoke City');
        InitialTable.PercentageOver2(i) = GoalsPerClub(14);
    elseif strcmp(InitialTable.Club(i),'Sunderland');
        InitialTable.PercentageOver2(i) = GoalsPerClub(15);
    elseif strcmp(InitialTable.Club(i),'Swanea City');
        InitialTable.PercentageOver2(i) = GoalsPerClub(16);
    elseif strcmp(InitialTable.Club(i),'Tottenham Hotspur');
        InitialTable.PercentageOver2(i) = GoalsPerClub(17);
    elseif strcmp(InitialTable.Club(i),'Watford');
        InitialTable.PercentageOver2(i) = GoalsPerClub(18);
    elseif strcmp(InitialTable.Club(i),'West Bromwich Albion');
        InitialTable.PercentageOver2(i) = GoalsPerClub(19);
    else strcmp(InitialTable.Club(i),'West Ham United');
        InitialTable.PercentageOver2(i) = GoalsPerClub(20);
    end
end

%% Points calculation
%Set for ease
GK = 'Goalkeeper';
DF = 'Defender';
MF = 'Midfielder';
FW = 'Forward';

InitialTable.YellowCardP = InitialTable.YellowCards*(-1); %Yellow Card = (-1)
InitialTable.AssistP = InitialTable.Assists*3; % Goal Assist = 3
InitialTable.PenaltyP = InitialTable.PenaltiesSaved*5; %Penalty save = 5
InitialTable.RedCardP = InitialTable.RedCards*(-3); %Red Card = (-3)
InitialTable.OwnGoalP = InitialTable.OwnGoals*(-2); %Own Goal = (-2)
InitialTable.PenaltiesMissedP = InitialTable.PenaltiesMissed*(-2); % Penalty Miss = (-2)

% Goalscored by GK or DF - 6 points, Midfielder - 5, Forward - 4
% Save points is 1 if gk, 0 if anything else
% 1 point scored for every three saves made.
% If GK or DF, -1 points for every 2 goals conceded, MF or FW 0 

InitialTable.averageshotsaves = InitialTable.Saves/3; % Roughly number of times three saves made
InitialTable.AvShotP = round(InitialTable.averageshotsaves);%Rounding the figure

for i=1:height(InitialTable)
    if strcmp(InitialTable.Position(i),GK);
        InitialTable.GoalP(i) = InitialTable.Goals(i)*6;
        InitialTable.CleanSheetP(i) = InitialTable.CleanSheet(i)*4;
        InitialTable.saveP(i) = InitialTable.AvShotP(i)*1;
        InitialTable.ConcededP(i) = round(InitialTable.Appearances(i)*InitialTable.PercentageOver2(i)*(-1));
    elseif strcmp(InitialTable.Position(i),DF);
        InitialTable.GoalP(i) = InitialTable.Goals(i)*6;    
        InitialTable.CleanSheetP(i) = InitialTable.CleanSheet(i)*4;
        InitialTable.saveP(i) = InitialTable.AvShotP(i)*0;
        InitialTable.ConcededP(i) = round(InitialTable.Appearances(i)*InitialTable.PercentageOver2(i)*(-1));
    elseif strcmp(InitialTable.Position(i),MF);
        InitialTable.GoalP(i) = InitialTable.Goals(i)*5;
        InitialTable.CleanSheetP(i) = InitialTable.CleanSheet(i)*1;
        InitialTable.saveP(i) = InitialTable.AvShotP(i)*0;
        InitialTable.ConcededP(i) = InitialTable.Appearances(i)*InitialTable.PercentageOver2(i)*0;
    else strcmp(InitialTable.Position(i),FW);
        InitialTable.GoalP(i) = InitialTable.Goals(i)*4;
        InitialTable.CleanSheetP(i) = InitialTable.CleanSheet(i)*0;
        InitialTable.saveP(i) = InitialTable.AvShotP(i)*0;
        InitialTable.ConcededP(i) = InitialTable.Appearances(i)*InitialTable.PercentageOver2(i)*0;
    end;
    %Minutes per game: Less than 60 - 1 point / More than 60 - 2 points
    if InitialTable.MinutesPerGame(i) > 60
        InitialTable.MinuteP(i) = InitialTable.Appearances(i)*2;
    else InitialTable.MinutesPerGame(i) < 60;
        InitialTable.MinuteP(i) = InitialTable.Appearances(i)*1;
    end
end
%% Sum and create new table with key variables

InitialTable.Points = InitialTable.MinuteP+InitialTable.ConcededP+InitialTable.saveP+InitialTable.CleanSheetP+InitialTable.GoalP+...
    InitialTable.AvShotP+InitialTable.YellowCardP+InitialTable.AssistP+InitialTable.PenaltyP+InitialTable.RedCardP...
    +InitialTable.OwnGoalP+InitialTable.PenaltiesMissedP; %Sum all created points

FinalTable = InitialTable(:,{'Player','Club','Position','Value','Points'}); %Creates sub-table with the important data types. 
FinalTable.avpoints = FinalTable.Points./FinalTable.Value; %Calculate the average points for use in optimisation

%% Optimisation 
%Sort into tables according to position
GkTable = FinalTable(strcmp(FinalTable.Position,GK),:); %Create and use index to extract all goalkeepers
DfTable = FinalTable(strcmp(FinalTable.Position,DF),:); %The same applied to DF, MF and FW
MfTable = FinalTable(strcmp(FinalTable.Position,MF),:);
FwTable = FinalTable(strcmp(FinalTable.Position,FW),:);

GkTable = sortrows(GkTable,'Points','Descend'); 
DfTable = sortrows(DfTable,'Points','Descend');
MfTable = sortrows(MfTable,'Points','Descend');
FwTable = sortrows(FwTable,'Points','Descend');

% Create unrestricted team
for x = 1:2 % 2 Highest Scoring GKS
finalteam(x,:) = GkTable(x,:);
end
for y = 1:5 % 5 Highest Scoring DFs
finalteam(y+2,:) = DfTable(y,:);
end  
for z = 1:5 % 5 Highest Scoring MFs
finalteam(z+7,:) = MfTable(z,:);
end
for w = 1:3 % 3 Highest Scoring FWs
finalteam(w+12,:) = FwTable(w,:);
end
% Preset starting positions for alternative choices (we chose the first two
% GKS, first 5 DFs and MFs and the first 3 FWs for the unconstrained team)
gk = 3;
df = 6;
mf = 6;
fw = 4;

% While the value of the team is above 100 remove the player with the
% lowest average points and replace it with the player with the highest
% points, using the preset alternatives as a starting point and then 
while sum(finalteam.Value)>100
    finalteam = sortrows(finalteam,'avpoints','ascend'); 
    if strcmp(finalteam.Position(1),GK);
        finalteam(1,:) = GkTable(gk,:);
        gk = gk+1;
    elseif strcmp(finalteam.Position(1),DF);
        finalteam(1,:) = DfTable(df,:);
        df = df+1;
    elseif strcmp(finalteam.Position(1),MF);
        finalteam(1,:) = MfTable(mf,:);
        mf = mf+1;
    else strcmp(finalteam.Position(1),FW);
        finalteam(1,:) = FwTable(fw,:);
        fw = fw+1;
    end
end

%% Addresses the constraint of more than 3 players from one team
while 1
originalteam = finalteam; %Presets originalteam = finalteam so we can compare at the end
clubnames = unique(finalteam.Club); %Finds which teams are used in the finalteam
    for j = 1:size(clubnames,1) ; %For each of those teams...
            if sum(strcmp(finalteam.Club,clubnames(j)))>3; % Count occurences of each team, if it's greater break and create a new team
                newtable = finalteam(strcmp(finalteam.Club,clubnames(j)),:); %Create a new table with all occurences of the team with the issue
                newtable = sortrows(newtable,'avpoints','ascend'); % Find the player with the least avpoints from the team
                for t = 1:height(finalteam);
                    if finalteam.avpoints(t) == newtable.avpoints(1) && strcmp(newtable.Position(1),GK); %If lowest player is a GK...
                        finalteam(t,:) = GkTable(gk,:);  % Select the next highest points scoring goalkeeper to replace them with
                        gk = gk+1 ;
                    elseif finalteam.avpoints(t) == newtable.avpoints(1) && strcmp(newtable.Position(1),DF);
                        finalteam(t,:) = DfTable(df,:);
                        df = df+1;
                    elseif finalteam.avpoints(t) == newtable.avpoints(1) && strcmp(newtable.Position(1),MF);
                        finalteam(t,:) = MfTable(mf,:);
                        mf = mf+1;
                    elseif finalteam.avpoints(t) == newtable.avpoints(1) && strcmp(newtable.Position(1),FW);
                        finalteam(t,:) = FwTable(fw,:);
                        fw = fw+1;
                    end
                end                
            end
    end
if isequal(originalteam,finalteam); %If no change, break the cycle
break
end
end

%% Selecting captain 
finalteam=sortrows(finalteam,'Points','Descend'); %Sorts the rows by descending points
newinput = strcat(finalteam.Player(1),' (C)');  %Adds 'C' to the highest scorer to indicate captain (double points)
finalteam.Player(1) = newinput; %Replaces original name
finalteam.Points(1) = finalteam.Points(1)*2; %Multiplies captain's points by two

%% Creating final array necessary for GUI
finalteam=sortrows(finalteam,'Position','Ascend');
totalpoints = sum(finalteam.Points);
totalvalue = sum(finalteam.Value);

player = [finalteam.Player;'15'];%Create arrays - 15 players,clubs,position,points,values and totals 
club = [finalteam.Club; size(unique(finalteam.Club),1)]; 
position = [finalteam.Position;'4'];
points=[finalteam.Points;totalpoints];
value=[finalteam.Value;totalvalue];
points=num2cell(points);
value=num2cell(value);

finalarray = [player,position,club,points,value];


set(handles.Display,'visible', 'on');
set(handles.Display,'String',get(handles.Enter_Team_Name,'String')); %Gets Team Name entered displays above table
set(handles.uitable4,'visible','on'); % See Table when button is pressed
set(handles.uitable4,'Data',finalarray); % Display table in format above  


function Enter_Team_Name_Callback(hObject, eventdata, handles)
% hObject    handle to Enter_Team_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Enter_Team_Name as text
%        str2double(get(hObject,'String')) returns contents of Enter_Team_Name as a double


% --- Executes during object creation, after setting all properties.
function Enter_Team_Name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Enter_Team_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Soundon.
function Soundon_Callback(hObject, eventdata, handles)
% hObject    handle to Soundon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[y,Fs] = audioread('song.wav');
sound(y,Fs);

% --- Executes on button press in soundoff.
function soundoff_Callback(hObject, eventdata, handles)
% hObject    handle to soundoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear sound %Stops Audio playing 
