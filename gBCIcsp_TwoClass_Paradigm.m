 function gBCIcsp_TwoClass_Paradigm(block)

% gUSBampBCI with CSP: Matlab S-Function Level 2 Implementation

% Rene Sendlhofer, 30.10.2008
% last update: 2016, Rupert Ortner: changes for Matlab 2015a: changed
% figure handle. Changed beep for Windows 10
% g.tec 

  setup(block);
end

%% SETUP *****************************************************************
function setup(block)

  % Register Dialog Params (runnumber, paradigm)
  block.NumDialogPrms = 2;
  block.DialogPrmsTunable = {'NonTunable', 'NonTunable'};
  
  % Register number of ports (feedback decision)
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 2;
  
  % Setup port properties to be inherited or dynamic
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
  
  % Override port properties
  block.InputPort(1).DatatypeID  = 0;  
  block.InputPort(1).Complexity  = 'Real';
  block.InputPort(1).SamplingMode = 'Inherited';
  block.InputPort(1).DirectFeedthrough = false;
  
  % output for target
  block.OutputPort(1).Dimensions = 1;
  block.OutputPort(1).DatatypeID = 0;
  block.OutputPort(1).SamplingMode = 'sample';
  block.OutputPort(1).Complexity = 'Real';
  
  % output for feedback
  block.OutputPort(2).Dimensions = 1;
  block.OutputPort(2).DatatypeID = 0;
  block.OutputPort(2).SamplingMode = 'sample';
  block.OutputPort(2).Complexity = 'Real';

  % Register sample times
  block.SampleTimes = [-1 0];
  
  block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);
  block.RegBlockMethod('Update', @Update);
  block.RegBlockMethod('CheckParameters', @CheckPrms);
  block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
  block.RegBlockMethod('Terminate', @Terminate);
  block.RegBlockMethod('InitializeConditions', @InitializeConditions);
  block.RegBlockMethod('Outputs', @Output);
end

%% SETINPUTPORTSAMPLINGMODE ***********************************************
function SetInputPortSamplingMode(block, idx, fd)

    block.InputPort(idx).SamplingMode = fd;
    
end

%% DOPOSTPROPSETUP ********************************************************
function DoPostPropSetup(block)
  block.NumDworks = 14;
  
  % Control the time-points of the paradigm
  block.Dwork(1).Name            = 'State';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
  
  % Remember starttime of trial
  block.Dwork(2).Name            = 'Starttime';
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;     
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = false;

  % sine wave for beeptone
  block.Dwork(3).Name            = 'beeptone';
  block.Dwork(3).Dimensions      = 3205;                                    
  block.Dwork(3).DatatypeID      = 0;      
  block.Dwork(3).Complexity      = 'Real';
  block.Dwork(3).UsedAsDiscState = false;
  
  % Time you got ball
  block.Dwork(4).Name            = 'Good';
  block.Dwork(4).Dimensions      = 1;
  block.Dwork(4).DatatypeID      = 0;      
  block.Dwork(4).Complexity      = 'Real';
  block.Dwork(4).UsedAsDiscState = false;
  
  % Time you missed ball
  block.Dwork(5).Name            = 'Bad';
  block.Dwork(5).Dimensions      = 1;
  block.Dwork(5).DatatypeID      = 0;      
  block.Dwork(5).Complexity      = 'Real';
  block.Dwork(5).UsedAsDiscState = false;
  
  % Percentage of ball hits
  block.Dwork(6).Name            = 'Result';
  block.Dwork(6).Dimensions      = 50;
  block.Dwork(6).DatatypeID      = 0;      
  block.Dwork(6).Complexity      = 'Real';
  block.Dwork(6).UsedAsDiscState = false;
  
  % Feedback Gain
  block.Dwork(7).Name            = 'FBGain';
  block.Dwork(7).Dimensions      = 1;
  block.Dwork(7).DatatypeID      = 0;      
  block.Dwork(7).Complexity      = 'Real';
  block.Dwork(7).UsedAsDiscState = false;
  
  % Ranges for ball paradigm
  block.Dwork(8).Name            = 'InputRanges';
  block.Dwork(8).Dimensions      = 10;
  block.Dwork(8).DatatypeID      = 0;
  block.Dwork(8).Complexity      = 'Real';
  block.Dwork(8).UsedAsDiscState = false;
  
  % Deltas for ball paradigm
  block.Dwork(9).Name            = 'Deltas';
  block.Dwork(9).Dimensions      = 10;
  block.Dwork(9).DatatypeID      = 0;
  block.Dwork(9).Complexity      = 'Real';
  block.Dwork(9).UsedAsDiscState = false;
  
  % Ball direction
  block.Dwork(10).Name            = 'BallDir';
  block.Dwork(10).Dimensions      = 8;
  block.Dwork(10).DatatypeID      = 0;
  block.Dwork(10).Complexity      = 'Real';
  block.Dwork(10).UsedAsDiscState = false;
  
  % paradigm timing
  block.Dwork(11).Name            = 'ParadigmTimes';
  block.Dwork(11).Dimensions      = 7;
  block.Dwork(11).DatatypeID      = 0;
  block.Dwork(11).Complexity      = 'Real';
  block.Dwork(11).UsedAsDiscState = false;
  
  % paradigm timing
  block.Dwork(12).Name            = 'ITI';
  block.Dwork(12).Dimensions      = 41;
  block.Dwork(12).DatatypeID      = 0;
  block.Dwork(12).Complexity      = 'Real';
  block.Dwork(12).UsedAsDiscState = false;
  
  % outputs
  block.Dwork(13).Name = 'Output';
  block.Dwork(13).Dimensions = 2;
  block.Dwork(13).DatatypeID = 0;
  block.Dwork(13).Complexity = 'Real';
  block.Dwork(13).UsedAsDiscState = false;
  
    % bar feedback update counter
  block.Dwork(14).Name = 'PlottingCounter';
  block.Dwork(14).Dimensions = 1;
  block.Dwork(14).DatatypeID = 0;
  block.Dwork(14).Complexity = 'Real';
  block.Dwork(14).UsedAsDiscState = false;

end

%% INITIALIZE *************************************************************
function InitializeConditions(block)
  % Initialize e.g. figure, labels, etc.
    global CSPBI_2class_figureHandle;      % handle of feedback window
  %paradigm timing
  %------------------------------------------------------------------------
  block.Dwork(11).Data(1) = 2;                                              % beep on, trigger on
  block.Dwork(11).Data(2) = 2.5;                                            % trigger off
  block.Dwork(11).Data(3) = 3;                                              % show arrow
  block.Dwork(11).Data(4) = 4.25;                                           % hide arrow
  block.Dwork(11).Data(5) = 4.25;                                           % feedback recording on
  block.Dwork(11).Data(6) = 8-1/256;                                        % hide cross
  block.Dwork(11).Data(7) = 8;                                              % end trial
  RITImin                 = 1.5;                                            % random intertrial interval minimum
  RITImax                 = 2.5;                                            % random intertrial interval maximum
  
  block.Dwork(12).Data    = rand(41,1)*(RITImax-RITImin)+RITImin;           % random intertrial interval
  %------------------------------------------------------------------------

  block.Dwork(1).Data = 0; % State 0
  block.Dwork(2).Data = 0; % Starttime 0
  block.Dwork(7).Data = 0; % Feedback Gain
  
  % Linear ranges for input signal and update steps (ball paradigm)
  block.Dwork(8).Data = [-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1000]; 
  block.Dwork(9).Data = [-0.0045 -0.003 -0.0025 -0.0015 -0.0001 ...
                          0.0001 0.0015  0.0025  0.003  0.0045];
  
  % Ball directions
  block.Dwork(10).Data = [-1 1 1 -1 -1 -1 1 1];  
  
  % Assign classlabels according to runnumber
  class_labels = [0  0  0  1  0  0  1  1  1  0  1  1  1  0  0  1  0  0  1  0 ...
                1  0  0  0  1  1  0  1  1  0  1  1  1  0  0  1  0  0  1  1 ...
                0  0  1  0  0  1  0  1  0  0  0  1  1  0  1  1  0  1  1  1 ...
                0  0  1  0  0  1  1  0  0  0  1  0  0  1  1  1  0  1  1  1 ...
                1  0  0  1  0  0  1  0  1  0  0  0  0  0  1  0  0  1  1  1 ...
                0  1  1  0  1  1  0  1  1  0  1  1  1  0  0  1  0  0  1  1 ...
                0  1  0  0  1  0  1  0  0  0  1  0  0  1  0  0  1  1  1  0 ...
                1  1  1  0  0  1  0  1  1  0  1  1  1  0  0  1  0  0  1  1];
              
  run = block.DialogPrm(2).Data;
  handles.classes = class_labels((run-1)*40+1:run*40);
      
  % Initialize the figure for use with this simulation
  CSPBI_2class_figureHandle = figure('Name', 'BCI Paradigm');
  initFigure(block);
  
  % Lines and arrows -----------------------------------------------------
  handles.line1 = line([0 0],[0.5 -0.5],'Visible','off','EraseMode','Background');
  handles.line2 = line([-0.5 0.5],[0 0],'Visible','off','EraseMode','Background');
  handles.line3 = line([-0.5 -0.45],[0 0.025],'EraseMode','Background','Visible','off','LineWidth',3,'Color','r');
  handles.line4 = line([-0.5 -0.45],[0 -0.025],'EraseMode','Background','Visible','off','LineWidth',3,'Color','r');
  handles.line5 = line([0.5 0.45],[0 0.025],'EraseMode','Background','Visible','off','LineWidth',3,'Color','r');
  handles.line6 = line([0.5 0.45],[0 -0.025],'EraseMode','Background','Visible','off','LineWidth',3,'Color','r');
  handles.line7 = line([-0.5 0],[0 0],'EraseMode','Background','Visible','off','LineWidth',3,'Color','r');
  handles.line8 = line([0 0.5],[0 0],'EraseMode','Background','Visible','off','LineWidth',3,'Color','r');

  % Feedback: bar --------------------------------------------------------
  handles.bargraph = plot([0 0],[0 0], ...
                          'LineWidth',5, ...
                          'EraseMode','Background', ...
                          'Visible','off', ...
                          'Color','b');

  % Feedback: ball -------------------------------------------------------
  handles.ballFreq  = 0;      % Startfrequency (= freqInc for 1st trial)
  handles.stopFreq  = 0.4;    % Don't try with freqs higher than this
  handles.freqInc   = 0.05;   % Frequency increment for each speed-trial
  handles.trialTime = 50;     % Duration of one speed-trial
  handles.ballDir   = 0;      % Direction of ball
  handles.ball      = plot(0,0.1,'squarey', ...
                      'LineWidth',2, ...
                      'EraseMode','background', ...
                      'Visible','off', ...
                      'MarkerSize',20, ...
                      'Color','k');
  
  block.Dwork(6).Data = zeros(1, 50);
  
  block.Dwork(13).Data = zeros(1, 2);
                      
  handles.paddle = plot([-0.15 0.15],[0 0], ...
                        'LineWidth',7, ...
                        'Visible','off', ...
                        'EraseMode','background', ...
                        'Color','g');

  % Countdown Text -------------------------------------------------------
  handles.DelayBegin = 10; % Set to -1 for no delay
  handles.countdown = text('HorizontalAlignment','center', ... 
                           'VerticalAlignment','middle', ...
                           'String', int2str(handles.DelayBegin), ... 
                           'FontSize', 40, ...
                           'Visible', 'off');
  
  handles.newtrial = 1;
  handles.trials = 0;
    
  % Store user data
  set(gca, 'UserData', handles);

  set(CSPBI_2class_figureHandle, 'Visible', 'on');
  
% write runnumber into triggerchannel
runNumber = block.DialogPrm(2).Data;
switch runNumber
    case 1
        set_param([get_param(gcs,'Name'),'/Gain'],'Gain','-0.1');
    case 2
        set_param([get_param(gcs,'Name'),'/Gain'],'Gain','-0.2');
    case 3
        set_param([get_param(gcs,'Name'),'/Gain'],'Gain','-0.3');
    case 4
        set_param([get_param(gcs,'Name'),'/Gain'],'Gain','-0.4');
    otherwise
        error('Runnumber must be between 1 and 4');
end


%% set windowlength of variance
SampleRate = 1/block.SampleTimes(1);
VarianceWindow = 1.5;
set_param( [get_param(gcs,'Name'),'/Variance'],'WindowLength',num2str(round(SampleRate*VarianceWindow)));
set_param( [get_param(gcs,'Name'),'/Variance1'],'WindowLength',num2str(round(SampleRate*VarianceWindow)));
set_param( [get_param(gcs,'Name'),'/Variance2'],'WindowLength',num2str(round(SampleRate*VarianceWindow)));
set_param( [get_param(gcs,'Name'),'/Variance3'],'WindowLength',num2str(round(SampleRate*VarianceWindow)));

%% load beepTone
try
     load('beepTone.mat');
    block.Dwork(3).Data = beepTone.y;
catch
    disp('beep could not be loaded. The paradigm will run without beeps');
    block.Dwork(3).Data(1) = 999;
end

block.Dwork(14).Data = inf;                                                 % set feedback plotting counter

end

%% CHECKPARAMS ************************************************************
function CheckPrms(block)
  % See if "paradigm" and "runnumber" have correct values
  if (block.DialogPrm(2).Data < 1 || block.DialogPrm(2).Data > 4)
    error('Runnumber must be between 1 and 4');
  end
  if (block.DialogPrm(1).Data < 1 || block.DialogPrm(1).Data > 3)
    error('Paradigm must either be "Feedback", "No Feedback" or "Ball"');
  end
end
  
%% UPDATE *****************************************************************
function Update(block)
global CSPBI_2class_figureHandle; 
  if any(get(0, 'Children') == CSPBI_2class_figureHandle),
      set(0, 'currentfigure', CSPBI_2class_figureHandle);
      handles = get(gca, 'UserData'); 
      
      % Delay before Paradigm starts - Show Countdown
      if (block.CurrentTime < handles.DelayBegin) 
        number = mod(block.CurrentTime, handles.DelayBegin);
        set(handles.countdown, 'String', int2str(handles.DelayBegin-number), 'Visible', 'on');
      else
        set(handles.countdown, 'Visible', 'off');

        % Do 40 trials for "Feedback" and "No Feedback"
        if (handles.trials <= 40)
%%-------------------------------------------------------------------------
%--------------------------------------------------------------------------
%------------------------Start of ball paradigm----------------------------
%--------------------------------------------------------------------------
%-------------------------------------------------------------------------- 
          if (block.DialogPrm(1).Data == 3)
%             % Activate feedback gain for debugging

            % Stop if frequency reaches stop frequ
            if (handles.ballFreq > handles.stopFreq)
              set_param(gcs, 'SimulationCommand', 'stop');
            else
              if (handles.newtrial == 1)
                handles.newtrial = 0;
                block.Dwork(1).Data = 0;
                block.Dwork(2).Data = block.CurrentTime;
                block.Dwork(4).Data = 0; % "green" time
                block.Dwork(5).Data = 0; % "red" time
                handles.ballDir  = block.Dwork(10).Data(1); % Random direction of ball
                block.Dwork(10).Data = circshift(block.Dwork(10).Data, [0 -1]);
                
                handles.ballFreq = handles.ballFreq + handles.freqInc;
              end

              if (block.Dwork(1).Data <= 1)
                % Update every xx sample
                if (mod(block.CurrentTime*256, 1) == 0)

                  % Calculate new positions
                  x_ball = handles.ballDir*0.8*sin(2*pi*handles.ballFreq*(block.CurrentTime-block.Dwork(2).Data));
                  % Get old paddle position
                  x_paddle = get(handles.paddle, 'XData');
                  % Calculate discrete step of paddle and update pos
                  delta = calcDelta(block);
                  x_paddle = x_paddle + delta;
            
                  % Check range of screen (-1, +1)
                  if (x_paddle(1) <= -1)
                    x_paddle(1) = -1;
                    x_paddle(2) = -0.7;
                  end
                  if (x_paddle(2) >= 1)
                    x_paddle(2) = 1;
                    x_paddle(1) = 0.7;
                  end
                  
                  % Change paddle-color to red if ball is missed
                  if ((x_paddle(1) > x_ball) || (x_paddle(2) < x_ball))
                    set(handles.paddle,'Color','r');
                    block.Dwork(5).Data = block.Dwork(5).Data + 1;
                  else
                    set(handles.paddle,'Color','g');
                    block.Dwork(4).Data = block.Dwork(4).Data + 1;
                  end

                  set(handles.ball,'Xdata',x_ball,'Ydata', 0.1,'Visible','on');
                  set(handles.paddle,'Xdata',x_paddle,'Ydata',[0 0],'Visible','on');
%                   drawnow;
                end
              end
              
              % After xx sec end trial and show "Now faster"
              if ((block.CurrentTime > block.Dwork(2).Data + (handles.trialTime - 2)))
                block.Dwork(1).Data = 2;
                set(handles.countdown, 'String', 'Now faster', 'Visible', 'on');
                set(handles.ball, 'Visible', 'off');
                set(handles.paddle, 'Visible', 'off', 'XData', [-0.15 0.15]);
%                 drawnow;
                
                % Calculate result (percentage of ball hits,
                % 100*GREEN/(GREEN+RED)
                block.Dwork(6).Data(round(handles.ballFreq/handles.freqInc)) = ...
                  100*(block.Dwork(4).Data)/(block.Dwork(5).Data+block.Dwork(4).Data);
              end
              
              if ((block.CurrentTime > block.Dwork(2).Data + handles.trialTime) && (block.Dwork(1).Data == 2))
                handles.newtrial = 1;
                set(handles.countdown, 'Visible', 'off'); % Hide "Now faster" text
%                 drawnow;
              end
            end
          else
%%-------------------------------------------------------------------------
%--------------------------------------------------------------------------
%-----------------Start of feedback and no-feedback paradigm---------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------                           
            %% Set cross visible on  
            if (handles.newtrial == 1)
                handles.trials = handles.trials + 1;
                block.Dwork(2).Data = block.CurrentTime;
                block.Dwork(1).Data = 0;
                handles.newtrial = 0;
                set(handles.line1,'Visible','on');
                set(handles.line2,'Visible','on');
                
                % write actual trialnumber into the title
                f_name = ['BCI Paradigm          trial # ',num2str(handles.trials)];
                set(CSPBI_2class_figureHandle,'Name',f_name);
                %                 drawnow;
            end
            %% Beep and trigger on
            if ((block.CurrentTime > block.Dwork(2).Data + block.Dwork(11).Data(1)) && (block.Dwork(1).Data == 0))             
              if block.Dwork(3).Data ~=999;         %999 is error code for being unable to load the beep
                sound(block.Dwork(3).Data,44100);
              end
              set_param( [get_param(gcs,'Name'),'/Gain'],'Gain','1');
              block.Dwork(1).Data = 1;
              

            end
            %% trigger off    
            if ((block.CurrentTime > block.Dwork(2).Data + block.Dwork(11).Data(2)) && (block.Dwork(1).Data == 1))
              set_param([get_param(gcs,'Name'),'/Gain'],'Gain','0');
              block.Dwork(1).Data = 2;
            end
            %% Show arrow
            if ((block.CurrentTime > block.Dwork(2).Data + block.Dwork(11).Data(3)) && (block.Dwork(1).Data == 2))              
              i = handles.trials;
              set(handles.line2,'Visible','off');
              if (handles.classes(i) == 1)
                set(handles.line8,'Visible','on');
                set(handles.line5,'Visible','on');
                set(handles.line6,'Visible','on');
              else
                set(handles.line7,'Visible','on');
                set(handles.line3,'Visible','on');
                set(handles.line4,'Visible','on');
              end
%               drawnow;
              block.Dwork(1).Data = 3;
              
              % set vibrotactile stimulator on, either left or right
              if handles.classes(i) == 1
                  block.Dwork(13).Data(2) = 0.1;
              else
                  block.Dwork(13).Data(2) = -0.1;
              end
            end
            
            if ((block.CurrentTime < block.Dwork(2).Data + block.Dwork(11).Data(4)) && (block.Dwork(1).Data == 3))
                %set output target
                if handles.classes(handles.trials) == 1
                    block.Dwork(13).Data(1) = 1;
                else
                    block.Dwork(13).Data(1) = -1;
                end
            end
            %% Hide arrows again
            if ((block.CurrentTime > block.Dwork(2).Data + block.Dwork(11).Data(4)) && (block.Dwork(1).Data == 3))              
              set(handles.line7,'Visible','off');
              set(handles.line8,'Visible','off');
              set(handles.line3,'Visible','off');
              set(handles.line4,'Visible','off');
              set(handles.line5,'Visible','off');
              set(handles.line6,'Visible','off');              
              % For feedback runs, hide the horizontal bars
              if (block.DialogPrm(1).Data >= 2)
                set(handles.line2,'Visible','off');
              else
                set(handles.line2,'Visible','on');
                set(handles.line1,'Visible','on');
              end
%               drawnow;
              block.Dwork(1).Data = 4;              
              block.Dwork(14).Data = block.CurrentTime;                     % drawing update counter
            end
            %% Control Gain for feedback recording
            if ((block.CurrentTime > block.Dwork(2).Data + block.Dwork(11).Data(5)) && (block.Dwork(1).Data == 4))                           
              if (block.Dwork(7).Data == 0)
                block.Dwork(7).Data = 1;
              end              
              % Imaginations
              if (block.DialogPrm(1).Data == 2)
                  if block.CurrentTime >= block.Dwork(14).Data 
                    set(handles.bargraph,'Xdata',[0 block.InputPort(1).Data(1)],'Ydata',[0 0],'Visible','on','Color','blue');
                    block.Dwork(14).Data = block.CurrentTime+0.05;            % update counter to set the next time the bar is updated
                  end
                %set result output
                block.Dwork(13).Data(2) = block.InputPort(1).Data(1);
              end
%               drawnow;
            end
            %% Hide Fixation Cross
            if ((block.CurrentTime > (block.Dwork(2).Data + block.Dwork(11).Data(6))) && (block.Dwork(1).Data == 4)) 
              set(handles.line2,'Visible','off');
              set(handles.line1,'Visible','off');
              set(handles.bargraph,'Xdata',[0 0],'Ydata',[0 0],'Visible','off');
              % Control Gain for feedback recording
              if (block.Dwork(7).Data == 1)
                block.Dwork(7).Data = 0;
              end
              drawnow;
              block.Dwork(1).Data = 5;              
              %turn feedback off
              block.Dwork(13).Data(2) = 0;
            end
            %% End of trial            
            if ((block.CurrentTime > block.Dwork(2).Data + block.Dwork(11).Data(7) + block.Dwork(12).Data(handles.trials)) && (block.Dwork(1).Data == 5))
              handles.newtrial = 1;
            end
          end
          set(gca, 'UserData', handles);
        else
          set_param(gcs, 'SimulationCommand', 'stop');
        end
      end
%     end
  end
end

%% OUTPT ******************************************************************
function Output(block)

    block.OutputPort(1).Data = block.Dwork(13).Data(1);
    block.OutputPort(2).Data = block.Dwork(13).Data(2);
    block.Dwork(13).Data(1) = 0;
end

%% TERMINATE **************************************************************
function Terminate(block)
global CSPBI_2class_figureHandle;
if ishandle(CSPBI_2class_figureHandle)                                      % check if figure exists
    handles = get(gca, 'UserData');
    close(CSPBI_2class_figureHandle);
    
    if block.DialogPrm(1).Data == 2 && (handles.trials == length(handles.classes));
        SampleRate = 1/block.SampleTimes(1);
        plot_ErrorRates(SampleRate);
    end
end
if (block.DialogPrm(1).Data == 3);
    plotPerformance(block);
end

if exist('ApplyClsfOutput.mat','file')
    delete ApplyClsfOutput.mat;
end

end

%% CALCDELTA **************************************************************
function delta = calcDelta(block)
  in = block.InputPort(1).Data*0.1;
  % Calc delta, defined at "InitializeCond"
  if ((in ~= 0) && (~isnan(in)))
    delta = block.Dwork(9).Data(find(in < block.Dwork(8).Data, 1));
  else
    delta = 0;
  end
end

%% PLOT PERFORMANCE *******************************************************
function plotPerformance(block)
  global CSPBI_2class_figureHandle;
  
  set(0, 'CurrentFigure', CSPBI_2class_figureHandle);
  set(CSPBI_2class_figureHandle, 'Visible', 'off');
  handles = get(gca, 'UserData'); 

  % Plot ball performance
  figure('Name', 'Ball performance');
  stem((1:length(block.Dwork(6).Data)).*handles.freqInc, ... 
       block.Dwork(6).Data(:), 'o', 'r');
  hold on; grid on;
  axis([0 handles.stopFreq 0 105]);
  xlabel('Frequency [Hz]'); ylabel('Got ball [%]');

  set_param(gcs, 'SimulationCommand', 'stop');
end

%% SCREEN OPTIONS *********************************************************
function initFigure(~)

  global CSPBI_2class_figureHandle;
  src = CSPBI_2class_figureHandle;
  set(src, 'Visible', 'off');
  pos = get(0, 'ScreenSize');
  pos = [100, 100, pos(3)-200, pos(4)-200];
  set(src, 'Position', pos, 'MenuBar', 'none');
  movegui(src, 'center');
  axis([-1 1 -1 1]); axis off; hold on;
  set(gca, 'SortMethod','childorder');
  
  %% Frame options --------------------------------------------------------
  framePosB = [0.01 0.01 0.98 0.09];
  uicontrol(src,  ...
      'Style','frame', ...
      'Units','normalized', ...
      'Position',framePosB, ...
      'BackgroundColor',[0.5 0.5 0.5]);
       
  %% Button options -------------------------------------------------------
  buttonPos = [0.78 0.027 0.2 0.05];
  callback = 'set_param(gcs, ''SimulationCommand'', ''stop'');';
  uicontrol(src, ...
      'Style','pushbutton', ...
      'Units','normalized', ...
      'FontSize',16, ...
      'Position',buttonPos, ...
      'String','Stop Simulation', ...
      'Callback',callback, ...
      'BackgroundColor',[0.8 0.8 0.8]);
end
%% PLOT ERROR RATE *********************************************************
function plot_ErrorRates(SampleRate)
try
P_C_S = data;
P_C_S.SamplingFrequency = SampleRate;
File='ApplyClsfOutput.mat';
P_C_S=load(P_C_S,File);


[~,~,NumChannels] = size(P_C_S.Data);
triggerTime = [2 6];
% try to read the Class Information out of the triggerChannel
Markers = P_C_S.Marker;
BeginMarkerSamples = Markers(Markers(:,3)==1,1);

data_temp = P_C_S.Data;
triggerData = data_temp(1,:,NumChannels);

ClassInfo = triggerData(BeginMarkerSamples+1);
if (length(ClassInfo) == 4 && ~isempty(find(ClassInfo ~= [-0.1 -0.2 -0.3 -0.4], 1 )))
    disp(['the runnumbers of the merged runs seem not to be "1,2,3,4". ','please check the data']);
end
clear data_temp;
%
%Trigger
New_tm{1}={NumChannels 1 'v' 0.9 0};
SamplesBefore=triggerTime(1)*SampleRate;
SamplesAfter=triggerTime(2)*SampleRate;
Uncomplete=0;
ChannelExclude=[];
P_C_S=gBStrigger(P_C_S,New_tm,SamplesBefore,SamplesAfter,Uncomplete,ChannelExclude);
% Load Class Information

load classrun1.mat;
load classrun2.mat;
load classrun3.mat;
load classrun4.mat;

nTrialsPerRun = size(z1,2);
nRuns = length(ClassInfo);
class_info = zeros(size(z1,1),nRuns*nTrialsPerRun);
for Nr = 1:length(ClassInfo)
    if ClassInfo(Nr) == -0.1
        zact = z1;
    elseif ClassInfo(Nr) == -0.2
        zact = z2;
    elseif ClassInfo(Nr) == -0.3
        zact = z3;
    elseif ClassInfo(Nr) == -0.4
        zact = z4;
    end
    class_info(:,(Nr-1)*nTrialsPerRun+1:Nr*nTrialsPerRun) = zact;
end

name_classes={
    'Right'
    'Left'
    };

use_rows=[1  2];
P_C_S=gBSloadclass(P_C_S,class_info,name_classes,use_rows);

% Cut triggerchannnel and timechannel
ChannelExclude=[1  NumChannels];
TrialExclude=[];
P_C_S=gBScuttrialschannels(P_C_S,TrialExclude,ChannelExclude);
ch_attr_name = {'BAD';'CUT';'VAR';'LDA1';'LDA2'; 'p-val1'; 'p-val2'; 'class'};
P_C_S.ChannelAttributeName = ch_attr_name;
ch_attribute = [0 0 0 0 0; 0 0 0 0 0; 1 1 1 1 1; 1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1;];
P_C_S.ChannelAttribute = ch_attribute;
ch_name = {' 2'; ' 2'; ' 2'; ' 2'; ' 2';};
P_C_S.ChannelName = ch_name;
P_C_S.PreTrigger = 3 * SampleRate;
P_C_S.CompanyLogo = 'C:\Program Files\gtec\gBSanalyze\view\gteclogo.gif';


ClassIndex=[3  4];
ChannelExclude=[3  4  5];
TrialExclude=[];
FileName='';
SignificanceLevel=5;
ProgressBarFlag=0;
V_O = gBSclassificationoutputmapping(P_C_S,ClassIndex,ChannelExclude,TrialExclude,FileName,SignificanceLevel,ProgressBarFlag);
result2d =CreateResult2D(V_O);
gResult2d(result2d);
catch
%     clc;
end


end