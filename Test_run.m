load('test_07_10_2017_18_40_24_0000.mat')
% 255/s ==> L = 51, U = 8
Xfmr = Input_to_state;
Xfmr.init(8,51, 0.5);

result = zeros(length(y(14,1:5000)),43);
for i= 1: length(y(14,1:5000))
    result(i,:) = Xfmr.Crun(y(14,i));
end
surface(abs(result))

figure(2)
plot(abs(result(200)))