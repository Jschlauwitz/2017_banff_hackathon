classdef U_L_Thresholds < handle
    %Input_to_state Converts received frequency and trace to right/left
    %state
    %   Detailed explanation goes here
    
    properties (Access = private)
        FMean
        FDev
        FTraceVal
    end
    
    methods
        function obj = init(obj, Trace)
            %INIT Construct an instance of this class
            %   Sets object parameters
            obj.FMean = 0;
            obj.FDev = 0;          
            obj.FTraceVal = Trace;
        end
        
        function [thresLow, thresHigh] = Crun(obj, input)
            %FREQS Convert to frequency domain and find mean and Std
            %deviation
            %   Detailed explanation goes here
                obj.FMean = obj.FMean*(1-obj.FTraceVal) + obj.FVal*obj.FTraceVal;
                obj.FDev = obj.FDev*(1-obj.FTraceVal) + abs(input-obj.FMean)*obj.FTraceVal;
                
                thresLow = obj.FMean - obj.FDev;
                thresHigh = obj.FMean + obj.FDev;
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
