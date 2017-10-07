classdef Input_to_state
    %Input_to_state Converts received frequency and trace to right/left
    %state
    %   Detailed explanation goes here
    
    properties (Access = private)
        UpperFreq
        Cpipe
        FVal
        FMean
        FDev
        FTraceVal
    end
    
    methods
        function obj = init(UFreq, Trace)
            %INIT Construct an instance of this class
            %   Sets object parameters - currently null.
            obj.UpperFreq = UFreq;
            obj.Cpipe = zeros(UFreq);
            obj.FMean = zeros(UFreq);
            obj.FVal = zeros(UFreq);
            obj.FDev = zeros(UFreq);
            obj.FTraceVal = ones(UFreq)*Trace;
        end
        
        function obj = push(obj, InValue)
            %PUSH Add new value to front of pipeline
            %   Detailed explanation goes here
            obj.Cpipe(2:end) = obj.Cpipe(1:(end-1));
            obj.Cpipe(1) = InValue;
        end
        function obj = freqs(obj)
            %FREQS Convert to frequency domain and find mean and avg
            %frequencies
            %   Detailed explanation goes here
            obj.FVal = fft(obj.Cpipe);
            obj.FMean = obj.FMean.*(1-obj.FTraceVal) + obj.FVal.*obj.FTraceVal;
            obj.FDev = obj.FDev.*(1-obj.FTraceVal) + abs(obj.FVal-obj.FMean).*obj.FTraceVal;
        end
        function val = get.FVal(obj)
            %METHOD2 sSummary of this method goes here
            %   Detailed explanation goes here
        end
    end
end

