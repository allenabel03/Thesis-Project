clear;
clc;

% Clean up any existing serial connections
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

% Initialize a new serial connection
arduino = serial('COM5', 'BaudRate', 9600); % Change 'COM5' to your Arduino's COM port
fopen(arduino);

% Define the size of your data array
dataLength = 10000; % Set this to the number of data points you want to collect
data = zeros(1, dataLength);

% Plot setup for real-time data
figure;
h = plot(data);
title('Real-Time Sensor Data');
xlabel('Sample Number');
ylabel('Sensor Value');

% Read data from the serial port and update plot
for i = 1:dataLength
    data(i) = str2double(fgetl(arduino));
    set(h, 'YData', data);
    drawnow;
end

% Close the serial connection
fclose(arduino);
delete(arduino);
clear arduino;

% Remove the DC offset from the data
data = data - mean(data);

% FFT Analysis
Fs = 1000; % Adjust this to your actual sampling frequency
T = 1 / Fs; % Sampling period
L = dataLength; % Length of the signal

Y = fft(data);

P2 = abs(Y / L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs * (0:(L/2))/L;

% Plotting the FFT result on a logarithmic scale
figure;
semilogy(f, P1);
title('Single-Sided Amplitude Spectrum of X(t)');
xlabel('Frequency (Hz)');
ylabel('|P1(f)|');
