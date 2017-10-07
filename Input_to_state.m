classdef Input_to_state
    %UNTITLED Summary of this class goes here
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
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.UpperFreq = UFreq;
            obj.Cpipe = zeros(UFreq);
            obj.FMean = zeros(UFreq);
            obj.FVal = zeros(UFreq);
            obj.FDev = zeros(UFreq);
            obj.FTraceVal = ones(UFreq)*Trace;
        end
        
        function obj = push(obj, InValue)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.Cpipe(2:end) = obj.Cpipe(1:(end-1));
            obj.Cpipe(1) = InValue;
        end
        function obj = freqs(obj)
            %METHOD2 Summary of this method goes here
            %   Detailed explanation goes here
            obj.FVal = fft(obj.Cpipe);
            obj.FMean = obj.FMean.*(1-obj.FTraceVal) + obj.FVal.*obj.FTraceVal;
            obj.FDev = obj.FDev.*(1-obj.FTraceVal) + abs(obj.FVal-obj.FMean).*obj.FTraceVal;
        end
        function val = get.FVal(obj)
            %METHOD2 Summary of this method goes here
            %   Detailed explanation goes here
        end
    end
end

