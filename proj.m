clc;                        % clear command window
clear all;                  % clear workspace
close all;                  % close figure window
X_source = input('Enter the x-location of source'); % x-axis of source location, I took '8'
Y_source = input('Enter the y-location of source'); % y-axis of source location, I took '7'
r = input('Enter number of mics');     % Number of total microphones, I took '6'
d = input('Enter distance between mics');   % seperation between any two microphones, I took '1'
x_axis = 0:d:r-1;           % setting up x-axis location of source
y_axis = [0 0 0 0 0 0];     % setting up y-axis location of source
soundsiga = randn(1,5000);  % input sound signal generation
c = 343;                    % speed of sound in air
sam_freq =  input('Enter the sampling frequency');  % sampling frequency, I took '2000'
ref_mic_dis = sqrt((X_source-x_axis(1))^2+(Y_source-y_axis(1))^2)/c; % distance from source to reference microphone
mic1 = sqrt((X_source-x_axis(2))^2+(Y_source-y_axis(2))^2)/c;  % distance from source to microphone 1
mic2 = sqrt((X_source-x_axis(3))^2+(Y_source-y_axis(3))^2)/c;  % distance from source to microphone 2
mic3 = sqrt((X_source-x_axis(4))^2+(Y_source-y_axis(4))^2)/c;  % distance from source to microphone 3
mic4 = sqrt((X_source-x_axis(5))^2+(Y_source-y_axis(5))^2)/c;  % distance from source to microphone 4
mic5 = sqrt((X_source-x_axis(6))^2+(Y_source-y_axis(6))^2)/c;  % distance from source to microphone 5

del_ref_mic = [mic1-ref_mic_dis mic2-ref_mic_dis mic3-ref_mic_dis mic4-ref_mic_dis mic5-ref_mic_dis]*sam_freq % time difference between reference microphone other microphones

ord =  input('Enter order of the filter');   % order of the filter, I took '151'
t = -200:200;                                % to generate sinc signal
sinc1 = sinc(t+200-del_ref_mic(1)-ord/2);    % delayed signal for microphone 1
sinc2 = sinc(t+200-del_ref_mic(2)-ord/2);    % delayed signal for microphone 2
sinc3 = sinc(t+200-del_ref_mic(3)-ord/2);    % delayed signal for microphone 3
sinc4 = sinc(t+200-del_ref_mic(4)-ord/2);    % delayed signal for microphone 4
sinc5 = sinc(t+200-del_ref_mic(5)-ord/2);    % delayed signal for microphone 5

fds1 = filter(sinc1,1,soundsiga);            % delaying sound signal for 1st microphone
fds2 = filter(sinc2,1,soundsiga);            % delaying sound signal for 2nd microphone
fds3 = filter(sinc3,1,soundsiga);            % delaying sound signal for 3rd microphone
fds4 = filter(sinc4,1,soundsiga);            % delaying sound signal for 4th microphone
fds5 = filter(sinc5,1,soundsiga);            % delaying sound signal for 5th microphone


%%

[A1, E1] = lms(soundsiga,fds1,.01,ord);      % passing signal of microphone 1 through adaptive filter
[A2, E2] = lms(soundsiga,fds2,.01,ord);      % passing signal of microphone 2 through adaptive filter
[A3, E3] = lms(soundsiga,fds3,.01,ord);      % passing signal of microphone 3 through adaptive filter
[A4, E4] = lms(soundsiga,fds4,.01,ord);      % passing signal of microphone 4 through adaptive filter
[A5, E5] = lms(soundsiga,fds5,.01,ord);      % passing signal of microphone 5 through adaptive filter
figure;                                      % opening a new figure window
hold on;                                     % holding the plot of required figure in figure window
plot(A1,'r');                                % to plot output of adaptive filter for microphone 1
plot(A2,'c');                                % to plot output of adaptive filter for microphone 2
plot(A3,'y');                                % to plot output of adaptive filter for microphone 3
plot(A4,'m');                                % to plot output of adaptive filter for microphone 4
plot(A5,'m');                                % to plot output of adaptive filter for microphone 5
title('output of Adaptive filter');          % giving title for the figure
xlabel('No.of samples---->');                % giving title for x-label
ylabel('Amplitude---->');                    % giving title for y-label
[Phi1,ome1] = phasez(A1,1);                  % phi and omega values of output matrix (microphone 1)
[phi2,ome2] = phasez(A2,1);                  % phi and omega values of output matrix (microphone 2)
[phi3,ome3] = phasez(A3,1);                  % phi and omega values of output matrix (microphone 3)
[phi4,ome4] = phasez(A4,1);                  % phi and omega values of output matrix (microphone 4)
[phi5,ome5] = phasez(A5,1);                  % phi and omega values of output matrix (microphone 5)

figure                                       % opening a new figure window
hold on;                                     % holding the plot of required figure in figure window
plot(ome1/pi,Phi1,'r');                      % plotting phase of output signal from filter (microphone 1)
plot(ome2/pi,phi2,'c');                      % plotting phase of output signal from filter (microphone 2)
plot(ome3/pi,phi3,'y');                      % plotting phase of output signal from filter (microphone 3)
plot(ome4/pi,phi4,'m');                      % plotting phase of output signal from filter (microphone 4)
plot(ome5/pi,phi5,'m');                      % plotting phase of output signal from filter (microphone 5)
title('Phase of output signal from filter'); % giving title for the figure
xlabel('Frequency---->');                    % giving title for x-label
ylabel('Phase(/omega)---->');                        % giving title for y-label

la1 = ome1\Phi1;                             % delayes estimated from slope of signal (microphone 1)
la2 = ome2\phi2;                             % delayes estimated from slope of signal (microphone 2)
la3 = ome3\phi3;                             % delayes estimated from slope of signal (microphone 3)
la4 = ome4\phi4;                             % delayes estimated from slope of signal (microphone 4)
la5 = ome4\phi5;                             % delayes estimated from slope of signal (microphone 5)

delay_slope = [la1 la2 la3 la4 la5];         % delay from obtained slope
final_delay = -(delay_slope+ord/2)           % removing the extra added length of filter


%%
syms xn yn;                                  % Taking xn and yn as symbols
z1 = (sqrt((xn-x_axis(2))^2+yn^2)-sqrt(xn^2+yn^2))*sam_freq/c; % equation of delay between reference microphone to other microphone
z2 = (sqrt((xn-x_axis(3))^2+yn^2)-sqrt(xn^2+yn^2))*sam_freq/c; 
z3 = (sqrt((xn-x_axis(4))^2+yn^2)-sqrt(xn^2+yn^2))*sam_freq/c; 
z4 = (sqrt((xn-x_axis(5))^2+yn^2)-sqrt(xn^2+yn^2))*sam_freq/c; 
z5 = (sqrt((xn-x_axis(6))^2+yn^2)-sqrt(xn^2+yn^2))*sam_freq/c; 
zd1 = (z1-final_delay(1))^2;                 % difference between estimated and ideal delays (microphone 1)
zd2 = (z2-final_delay(2))^2;                 % difference between estimated and ideal delays (microphone 2)
zd3 = (z3-final_delay(3))^2;                 % difference between estimated and ideal delays (microphone 3)
zd4 = (z4-final_delay(4))^2;                 % difference between estimated and ideal delays (microphone 4)
zd5 = (z5-final_delay(5))^2;                 % difference between estimated and ideal delays (microphone 5)
zd = zd1+zd2+zd3+zd4;
%%

x = diff(zd,xn);            % Partial difference of sum of total difference in delays with respect to xn
y = diff(zd,yn);            % Partial difference of sum of total difference in delays with respect to yn
X = matlabFunction(x);      % generating function from symbol xn
Y = matlabFunction(y);      % generating function from symbol yn
mue = .015;                  % initiating step size
loc_x = 1;                  % initial estimated x-axis location of sound source
loc_y = 1;                  % initial estimated y-axis location of sound source
for n = 1:50000    
    loc_x = loc_x-mue*X(loc_x,loc_y);  % steepest descent algorithm of x-axis
    loc_y = loc_y-mue*Y(loc_x,loc_y);  % steepest descent algorithm of y-axis
end
display(loc_x);
display(loc_y);