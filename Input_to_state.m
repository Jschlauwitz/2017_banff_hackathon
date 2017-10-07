classdef Input_to_state
    %Input_to_state Converts received frequency and trace to right/left
    %state
    %   Detailed explanation goes here
    
    properties (Access = private)
        Uppersam
        Lwersam
        Cpipe
        FVal
        FMean
        FLogical
        FLhist
        FDev
        FTraceVal
    end
    
    methods
        function obj = init(Usam,Lsam, Trace)
            %INIT Construct an instance of this class
            %   Sets object parameters
            obj.Uppersam = Usam;
            obj.Lwersam = Lsam;
            obj.Cpipe = zeros(Usam);
            obj.FMean = zeros(Usam-Lsam);
            obj.FVal = zeros(Usam-Lsam);
            obj.FDev = zeros(Usam-Lsam);
            obj.FLogical = zeros(Usam-Lsam);
            obj.FLhist = zeros(Usam-Lsam);            
            obj.FTraceVal = ones(Usam-Lsam)*Trace;
        end
        
        function obj = push(obj, InValue)
            %PUSH Add new value to front of pipeline
            %   move sample window along the pipeline
            obj.Cpipe(2:end) = obj.Cpipe(1:(end-1));
            obj.Cpipe(1) = InValue;
        end
        function obj = freqs(obj)
            %FREQS Convert to frequency domain and find mean and Std
            %deviation
            %   Detailed explanation goes here
            temp = fft(obj.Cpipe);
            obj.FVal = temp(obj.Lwersam:end);
            obj.FMean = obj.FMean.*(1-obj.FTraceVal) + obj.FVal.*obj.FTraceVal;
            obj.FDev = obj.FDev.*(1-obj.FTraceVal) + abs(obj.FVal-obj.FMean).*obj.FTraceVal;
        end
        function obj = freqs_to_logic(obj)
            %FREQS Convert frequencies to a logical range
            %   Detailed explanation goes here
            obj.FLogical = Sig((obj.FVal-obj.FMean)./obj.FDev);
            obj.FLhist = obj.FLhist.*(1-obj.FTraceVal) + obj.FLogical.*obj.FTraceVal;
        end
        function output = Sig(input)
            %FREQS Convert frequencies to a logical range
            %   Detailed explanation goes here
            output = sign(input).*abs(input)./(abs(input)+1);
        end
        
        
        function val = get.FVal(obj)
            %METHOD2 sSummary of this method goes here
            %   Detailed explanation goes here
        end
        function val = get.FMean(obj)
            %METHOD2 sSummary of this method goes here
            %   Detailed explanation goes here
        end
        function val = get.FDev(obj)
            %METHOD2 sSummary of this method goes here
            %   Detailed explanation goes here
        end
    end
end

