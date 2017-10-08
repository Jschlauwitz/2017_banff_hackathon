classdef Input_to_state < handle
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
        function obj = init(obj, Usam, Lsam, Trace)
            %INIT Construct an instance of this class
            %   Sets object parameters
            obj.Uppersam = Usam;
            obj.Lwersam = Lsam;
            obj.Cpipe = zeros(Lsam,1);
            obj.FMean = zeros(Lsam-Usam,1);
            obj.FVal = zeros(Lsam-Usam,1);
            obj.FDev = zeros(Lsam-Usam,1);
            obj.FLogical = zeros(Lsam-Usam,1);
            obj.FLhist = zeros(Lsam-Usam,1);            
            obj.FTraceVal = ones(Lsam-Usam,1)*Trace;
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
            obj.FVal = temp((obj.Uppersam+1):end);
            for i= 1:length(obj.FVal)
                obj.FMean(i) = obj.FMean(i).*(1-obj.FTraceVal(i)) + obj.FVal(i).*obj.FTraceVal(i);
                obj.FDev(i) = obj.FDev(i).*(1-obj.FTraceVal(i)) + abs(obj.FVal(i)-obj.FMean(i)).*obj.FTraceVal(i);
            end
        end
        function obj = freqs_to_logic(obj)
            %FREQS Convert frequencies to a logical range
            %   Detailed explanation goes here
            for i= 1:length(obj.FVal)
            obj.FLogical(i) = Sig((obj.FVal(i)-obj.FMean(i))./obj.FDev(i));
            obj.FLhist(i) = obj.FLhist(i).*(1-obj.FTraceVal(i)) + obj.FLogical(i).*obj.FTraceVal(i);
            end
        end
        function output = Crun(obj, input)
            %FREQS Convert frequencies to a logical range
            %   Detailed explanation goes here
            obj.push(input);
            obj.freqs();
            obj.freqs_to_logic();
            output = obj.FLogical;
        end
        
        function val = get.FVal(obj)
            %METHOD2 sSummary of this method goes here
            %   Detailed explanation goes here
            val = obj.FVal;
        end
        function val = get.FMean(obj)
            %METHOD2 sSummary of this method goes here
            %   Detailed explanation goes here
            val = obj.FMean;
        end
        function val = get.FDev(obj)
            %METHOD2 sSummary of this method goes here
            %   Detailed explanation goes here
            val = obj.FDev;
        end
    end
end


        function output = Sig(input)
            %FREQS Convert frequencies to a logical range
            %   Detailed explanation goes here
            output = sign(input).*abs(input)./(abs(input)+1);
        end
        