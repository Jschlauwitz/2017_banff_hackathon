b = HPF;

%%filtering
for h = 2:17
    y(h,:) = filter(b,1,y(h,:));
end
    
subplot(3,1,1)
for i = 2:17
    plot(y(1,:),y(i,:)); hold all
end
title('EEG Signals')
xlabel('t (ms)')
ylabel('V (uV)')

subplot(3,1,2)
plot(y(1,:),y(18,:))
title('Events')
xlabel('t (ms)')
ylabel('Event Membership')

Fs = 256;             % Sampling frequency                    
T = 1/Fs;             % Sampling period
L = length(y);        % Length of signal
t = y(1,:);

for j = 2:17
    Y = fft(y(j,:));

    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    subplot(3,1,3)
    plot(f,P1); hold all
    title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
end