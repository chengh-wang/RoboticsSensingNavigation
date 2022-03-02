% clc, clear
format longG

vFontSize = 14
vLineWidth = 4
vFontWeight = 'bold'

%list all rosbag
% time10min_bag = rosbag("./Data/02_26_10min.bag")
% time10min_bag = rosbag("./Data/mydata.bag")

% mag_topic = select(time10min_bag,"Topic","/imu_data")
% mag_message = readMessages(mag_topic,"DataFormat","struct");

% MagneticField

% imu_topic = select(time10min_bag,"Topic","/VN100/Imu")
% imu_message = readMessages(imu_topic,"DataFormat","struct");

% Orientation

% yaw = cellfun(@(m) double(m.Ypr.X),mag_message);

% pitch = cellfun(@(m) double(m.Ypr.Y),mag_message);

% roll = cellfun(@(m) double(m.Ypr.Z),mag_message);

% 
% t_mag_start = time10min_bag.StartTime;
% t_mag_end = time10min_bag.EndTime;
% t = t_mag_end - t_mag_start;
% t_mag = [0:length(yaw)\t:(t_mag_end-t_mag_start)].';
% t_mag(length(t_mag))=[];

% [yaw, pitch, roll] = quat2angle([orientationX orientationY orientationZ orientationW])

% % AngularVelocity
% angularvelocityX = cellfun(@(m) double(m.Imu.AngularVelocity.X),mag_message);

% angularvelocityY = cellfun(@(m) double(m.Imu.AngularVelocity.Y),mag_message);

% angularvelocityZ = cellfun(@(m) double(m.Imu.AngularVelocity.Z),mag_message);

% % LinearAcceleration
% linearaccelerationX = cellfun(@(m) double(m.Imu.LinearAcceleration.X),mag_message);

% linearaccelerationY = cellfun(@(m) double(m.Imu.LinearAcceleration.Y),mag_message);

% linearaccelerationZ = cellfun(@(m) double(m.Imu.LinearAcceleration.Z),mag_message);
theta = cellfun(@(m) double(m.Imu.LinearAcceleration.Z),mag_message);


t0 = 1/40;

maxNumM = 100;
L = size(theta, 1);
maxM = 2.^floor(log2(L/2));
m = logspace(log10(1), log10(maxM), maxNumM).';
m = ceil(m); % m must be an integer.
m = unique(m); % Remove duplicates.

tau = m*t0;

avar = zeros(numel(m), 1);
for i = 1:numel(m)
    mi = m(i);
    avar(i,:) = sum( ...
        (theta(1+2*mi:L) - 2*theta(1+mi:L-mi) + theta(1:L-2*mi)).^2, 1);
end
avar = avar ./ (2*tau.^2 .* (L - 2*m));
adev = sqrt(avar);

slope = -0.5;
logtau = log10(tau);
logadev = log10(adev);
dlogadev = diff(logadev) ./ diff(logtau);
[~, i] = min(abs(dlogadev - slope));

% Find the y-intercept of the line.
b = logadev(i) - slope*logtau(i);

% Determine the angle random walk coefficient from the line.
logN = slope*log(1) + b;
N = 10^logN

% Plot the results.
tauN = 1;
lineN = N ./ sqrt(tau);

% Find the index where the slope of the log-scaled Allan deviation is equal
% to the slope specified.
slope = 0.5;
logtau = log10(tau);
logadev = log10(adev);
dlogadev = diff(logadev) ./ diff(logtau);
[~, i] = min(abs(dlogadev - slope));

% Find the y-intercept of the line.
b = logadev(i) - slope*logtau(i);

% Determine the rate random walk coefficient from the line.
logK = slope*log10(3) + b;
K = 10^logK

% Plot the results.
tauK = 3;
lineK = K .* sqrt(tau/3);


% to the slope specified.
slope = 0;
logtau = log10(tau);
logadev = log10(adev);
dlogadev = diff(logadev) ./ diff(logtau);
[~, i] = min(abs(dlogadev - slope));

% Find the y-intercept of the line.
b = logadev(i) - slope*logtau(i);

% Determine the bias instability coefficient from the line.
scfB = sqrt(2*log(2)/pi);
logB = b - log10(scfB);
B = 10^logB

% Plot the results.
tauB = tau(i);
lineB = B * scfB * ones(size(tau));

tauParams = [tauN, tauK, tauB];
params = [N, K, scfB*B];
figure
loglog(tau, adev, tau, [lineN, lineK, lineB], '--', ...
    tauParams, params, 'o')
title('Allan Deviation with Noise Parameters')
xlabel('\tau')
ylabel('\sigma(\tau)')
legend('$\sigma (rad/s)$', '$\sigma_N ((rad/s)/\sqrt{Hz})$', ...
    '$\sigma_K ((rad/s)\sqrt{Hz})$', '$\sigma_B (rad/s)$', 'Interpreter', 'latex')
text(tauParams, params, {'N', 'K', '0.664B'})
grid on
axis equal

% 
% %==========================================================================
% % Plot start
% 
% l_width = 0.1; % Solid line thickness
% p_width = 1600;
% p_height = 700;
% 
% %==========================================================================
% % magneticfield
% 
% fig_name = ['EECE5554LAB3'];
% fig_num = 1;
% fig1=figure(1)
% set(fig1,'position',[0,50,p_width,p_height]);
% 
% subplot(4,3,1)
% plot(t_mag, magneticfieldX,'LineWidth',l_width)
% ylabel('Magnetic (T)')
% xlabel('Time (s)')
% title('magneticfieldX')
% 
% subplot(4,3,2)
% plot(t_mag, magneticfieldY,'LineWidth',l_width)
% ylabel('Magnetic (T)')
% xlabel('Time (s)')
% title('magneticfieldY')
% 
% subplot(4,3,3)
% plot(t_mag, magneticfieldX,'LineWidth',l_width)
% ylabel('Magnetic (T)')
% xlabel('Time (s)')
% title('magneticfieldY')
% 
% %==========================================================================
% % Orientation
% 
% subplot(4,3,4)
% plot(t_mag, pitch,'LineWidth',l_width)
% ylabel('Pitch (deg)')
% xlabel('Time (s)')
% title('Pitch')
% 
% subplot(4,3,5)
% plot(t_mag, yaw,'LineWidth',l_width)
% ylabel('Yaw (deg)')
% xlabel('Time (s)')
% title('Yaw')
% 
% subplot(4,3,6)
% plot(t_mag, roll,'LineWidth',l_width)
% ylabel('Roll (deg)')
% xlabel('Time (s)')
% title('Roll')
% 
% %==========================================================================
% % angularvelocity
% 
% subplot(4,3,7)
% plot(t_mag, angularvelocityX,'LineWidth',l_width)
% ylabel('angularvelocityX (deg/s)')
% xlabel('Time (s)')
% title('angularvelocityX')
% 
% subplot(4,3,8)
% plot(t_mag, angularvelocityY,'LineWidth',l_width)
% ylabel('angularvelocityY (deg/s)')
% xlabel('Time (s)')
% title('angularvelocityY')
% 
% subplot(4,3,9)
% plot(t_mag, angularvelocityZ,'LineWidth',l_width)
% ylabel('angularvelocityZ (deg/s)')
% xlabel('Time (s)')
% title('angularvelocityZ')
% 
% %==========================================================================
% % LinearAcceleration
% 
% subplot(4,3,10)
% plot(t_mag, linearaccelerationX,'LineWidth',l_width)
% ylabel('linearaccelerationX (deg/s)')
% xlabel('Time (s)')
% title('LinearAccelerationX')
% 
% subplot(4,3,11)
% plot(t_mag, linearaccelerationY,'LineWidth',l_width)
% ylabel('linearaccelerationY (deg/s)')
% xlabel('Time (s)')
% title('LinearAccelerationY')
% 
% subplot(4,3,12)
% plot(t_mag, linearaccelerationZ,'LineWidth',l_width)
% ylabel('linearaccelerationZ (deg/s)')
% xlabel('Time (s)')
% title('LinearAccelerationZ')
