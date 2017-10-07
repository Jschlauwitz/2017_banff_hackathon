classdef Input_to_state
    %Input_to_state Converts received frequency and trace to right/left
    %state
    %   Detailed explanation goes here
    
    properties (Access = private)
        UpperFreq
        LwerFreq
        Cpipe
        FVal
        FMean
        FDev
        FTraceVal
    end
    
    methods
        function obj = init(UFreq,LFreq, Trace)
            %INIT Construct an instance of this class
            %   Sets object parameters
            obj.UpperFreq = UFreq;
            obj.LwerFreq = LFreq;
            obj.Cpipe = zeros(UFreq);
            obj.FMean = zeros(UFreq-LFreq);
            obj.FVal = zeros(UFreq-LwerFreq);
            obj.FDev = zeros(UFreq-LwerFreq);
            obj.FTraceVal = ones(UFreq-LwerFreq)*Trace;
        end
        
        function obj = push(obj, InValue)
            %PUSH Add new value to front of pipeline
            %   move sample window along the pipeline
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

