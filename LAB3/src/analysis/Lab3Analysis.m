clc, clear
format long

vFontSize = 14
vLineWidth = 4
vFontWeight = 'bold'
Std = []
Mean = []

%list all rosbag
time10min_bag = rosbag("./Data/02_26_10min.bag")

mag_topic = select(time10min_bag,"Topic","/VN100/Mag")
mag_message = readMessages(mag_topic,"DataFormat","struct");

% MagneticField
magneticfieldX = cellfun(@(m) double(m.MagneticField_.X),mag_message);
Std(1) = std(magneticfieldX)

magneticfieldXmean = mean(magneticfieldX)
Mean(1) = magneticfieldXmean
magneticfieldXmean = ones(length(magneticfieldX),1)*magneticfieldXmean

magneticfieldY = cellfun(@(m) double(m.MagneticField_.Y),mag_message);
Std(2) = std(magneticfieldY)
magneticfieldYmean = mean(magneticfieldY)
Mean(2) = magneticfieldYmean
magneticfieldYmean = ones(length(magneticfieldY),1)*magneticfieldYmean

magneticfieldZ = cellfun(@(m) double(m.MagneticField_.Z),mag_message);
Std(3) = std(magneticfieldZ)
magneticfieldZmean = mean(magneticfieldZ)
Mean(3) = magneticfieldZmean
magneticfieldZmean = ones(length(magneticfieldZ),1)*magneticfieldZmean

t_mag_start = time10min_bag.StartTime
t_mag_end = time10min_bag.EndTime
t = t_mag_end - t_mag_start
t_mag = [0:length(magneticfieldX)\t:(t_mag_end-t_mag_start)].'
t_mag(length(t_mag))=[]


 
imu_topic = select(time10min_bag,"Topic","/VN100/Imu")
imu_message = readMessages(imu_topic,"DataFormat","struct");

% Orientation
orientationX = cellfun(@(m) double(m.Orientation.X),imu_message);
orientationY = cellfun(@(m) double(m.Orientation.Y),imu_message);
orientationZ = cellfun(@(m) double(m.Orientation.Z),imu_message);
orientationW = cellfun(@(m) double(m.Orientation.W),imu_message);
[yaw, pitch, roll] = quat2angle([orientationX orientationY orientationZ orientationW])
Std(4) = std(yaw)
Std(5) = std(pitch)
Std(6) = std(roll)

yawMean = mean(yaw)
Mean(4) = yawMean
yawMean = ones(length(yaw),1)*yawMean
pitchMean = mean(pitch)
Mean(5) = pitchMean
pitchMean = ones(length(pitch),1)*pitchMean
rollMean = mean(roll)
Mean(6) = rollMean
rollMean = ones(length(roll),1)*rollMean

% AngularVelocity
% angularvelocityX = cellfun(@(m) double(m.AngularVelocity.X),imu_message);
% angularvelocityY = cellfun(@(m) double(m.AngularVelocity.Y),imu_message);
% angularvelocityZ = cellfun(@(m) double(m.AngularVelocity.Z),imu_message);


angularvelocityX = cellfun(@(m) double(m.LinearAcceleration.X),imu_message);
Std(7) = std(angularvelocityX)
angularvelocityXmean = mean(angularvelocityX)
Mean(7) =  angularvelocityXmean
angularvelocityXmean = ones(length(angularvelocityX),1)*angularvelocityXmean

angularvelocityY = cellfun(@(m) double(m.LinearAcceleration.Y),imu_message);
Std(8) = std(angularvelocityY)
angularvelocityYmean = mean(angularvelocityY)
Mean(8) = angularvelocityYmean
angularvelocityYmean = ones(length(angularvelocityY),1)*angularvelocityYmean

angularvelocityZ = cellfun(@(m) double(m.LinearAcceleration.Z),imu_message);
Std(9) = std(angularvelocityZ)
angularvelocityZmean = mean(angularvelocityZ)
Mean(9) = angularvelocityZmean
angularvelocityZmean = ones(length(magneticfieldZ),1)*angularvelocityZmean

% LinearAcceleration
linearaccelerationX = cellfun(@(m) double(m.AngularVelocity.X),imu_message);
Std(10) = std(linearaccelerationX)
linearaccelerationXmean = mean(linearaccelerationX)
Mean(10) = linearaccelerationXmean
linearaccelerationXmean = ones(length(linearaccelerationX),1)*linearaccelerationXmean

linearaccelerationY = cellfun(@(m) double(m.AngularVelocity.Y),imu_message);
Std(11) = std(linearaccelerationY)
linearaccelerationYmean = mean(linearaccelerationY)
Mean(11) = linearaccelerationYmean
linearaccelerationYmean = ones(length(linearaccelerationY),1)*linearaccelerationYmean

linearaccelerationZ = cellfun(@(m) double(m.AngularVelocity.Z),imu_message);
Std(12) = std(linearaccelerationZ)
linearaccelerationZmean = mean(linearaccelerationZ)
Mean(12) = linearaccelerationZmean
linearaccelerationZmean = ones(length(linearaccelerationZ),1)*linearaccelerationZmean


%==========================================================================
% Plot start

l_width = 0.1; % Solid line thickness
p_width = 1800;
p_height = 700;

%==========================================================================
% magneticfield

fig_name = ['EECE5554LAB3'];
fig_num = 1;
fig1=figure(1)
set(fig1,'position',[0,100,p_width,p_height]);


subplot(4,3,1)
plot(t_mag, magneticfieldX,'LineWidth',l_width)
hold on
plot(t_mag, magneticfieldXmean,'r','LineWidth',l_width+1)
hold off

ylabel('Magnetic (T)')
xlabel('Time (s)')
title('magneticfieldX')

subplot(4,3,2)
plot(t_mag, magneticfieldY,'LineWidth',l_width)
hold on
plot(t_mag, magneticfieldYmean,'r','LineWidth',l_width+1)
hold off
ylabel('Magnetic (T)')
xlabel('Time (s)')
title('magneticfieldY')

subplot(4,3,3)
plot(t_mag, magneticfieldZ,'LineWidth',l_width)
hold on
plot(t_mag, magneticfieldZmean,'r','LineWidth',l_width+1)
hold off
ylabel('Magnetic (T)')
xlabel('Time (s)')
title('magneticfieldZ')

%==========================================================================
% Orientation

subplot(4,3,4)
plot(t_mag, pitch,'LineWidth',l_width)
hold on
plot(t_mag, pitchMean,'r','LineWidth',l_width+1)
hold off
ylabel('Pitch (deg)')
xlabel('Time (s)')
title('Pitch')

subplot(4,3,5)
plot(t_mag, yaw,'LineWidth',l_width)
hold on
plot(t_mag, yawMean,'r','LineWidth',l_width+1)
hold off
ylabel('Yaw (deg)')
xlabel('Time (s)')
title('Yaw')

subplot(4,3,6)
plot(t_mag, roll,'LineWidth',l_width)
hold on
plot(t_mag, rollMean,'r','LineWidth',l_width+1)
hold off
ylabel('Roll (deg)')
xlabel('Time (s)')
title('Roll')

%==========================================================================
% angularvelocity

subplot(4,3,7)
plot(t_mag, angularvelocityX,'LineWidth',l_width)
hold on
plot(t_mag, angularvelocityXmean,'r','LineWidth',l_width+1)
hold off
ylabel('angularvelocityX (deg/s)')
xlabel('Time (s)')
title('angularvelocityX')

subplot(4,3,8)
plot(t_mag, angularvelocityY,'LineWidth',l_width)
hold on
plot(t_mag, angularvelocityYmean,'r','LineWidth',l_width+1)
hold off
ylabel('angularvelocityY (deg/s)')
xlabel('Time (s)')
title('angularvelocityY')

subplot(4,3,9)
plot(t_mag, angularvelocityZ,'LineWidth',l_width)
hold on
plot(t_mag, angularvelocityZmean,'r','LineWidth',l_width+1)
hold off
ylabel('angularvelocityZ (deg/s)')
xlabel('Time (s)')
title('angularvelocityZ')

%==========================================================================
% LinearAcceleration

subplot(4,3,10)
plot(t_mag, linearaccelerationX,'LineWidth',l_width)
hold on
plot(t_mag, linearaccelerationXmean,'r','LineWidth',l_width+1)
hold off
ylabel('linearaccelerationX (deg/s)')
xlabel('Time (s)')
title('LinearAccelerationX')

subplot(4,3,11)
plot(t_mag, linearaccelerationY,'LineWidth',l_width)
hold on
plot(t_mag, linearaccelerationYmean,'r','LineWidth',l_width+1)
hold off
ylabel('linearaccelerationY (deg/s)')
xlabel('Time (s)')
title('LinearAccelerationY')

subplot(4,3,12)
plot(t_mag, linearaccelerationZ,'LineWidth',l_width)
hold on
plot(t_mag, linearaccelerationZmean,'r','LineWidth',l_width+1)
hold off
ylabel('linearaccelerationZ (deg/s)')
xlabel('Time (s)')
title('LinearAccelerationZ')
