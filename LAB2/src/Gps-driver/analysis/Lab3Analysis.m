clc, clear

vFontSize = 14
vLineWidth = 4
vFontWeight = 'bold'

%ground truth
isec_moving_gt = [42.337310791015625,42.337219238281250,42.337314605712890,42.337398529052734,42.337310791015625;
   -71.086853027343750,-71.086769104003900,-71.086578369140620,-71.086654663085940,-71.086853027343750]
isec_static_gt = []
tennis_moving_gt = [42.339603424072266,42.339450836181640,42.339366912841800,42.339519500732420,42.339603424072266;
    -71.084121704101560,-71.084312438964840,-71.084197998046880,-71.083984375000000,-71.084121704101560]
tennis_static_gt = []

%list all rosbag
isec_moving_bag = rosbag("./Data/isec_moving.bag")
isec_static_bag = rosbag("./Data/isec_static.bag")
tennis_moving_bag = rosbag("./Data/tennis_moving_final.bag")
tennis_static_bag = rosbag("./Data/tennis_static.bag")

data = {isec_moving_bag,tennis_moving_bag,isec_static_bag,tennis_static_bag}
name = {'ISEC Moving','Tennis Moving','ISEC Static','Tennis Static'}
gt = [isec_moving_gt;tennis_moving_gt]
Q = []

for i = 1:2
    utmZone = ("19T")
    utmZone = utmZone(1)
    [ellipsoid,estr] = utmgeoid(utmZone)
    utmstruct = defaultm('utm');
    utmstruct.zone = utmZone;
    utmstruct.geoid = ellipsoid;
    utmstruct = defaultm(utmstruct)
    [utmE,utmN] = mfwdtran(utmstruct,gt(2*i-1,:),gt(2*i,:))
    gt(2*i-1,:)=utmE
    gt(2*i,:)=utmN
end


s = size(data)

for i = 1:s(2)
    %get topic
    gps_topic = select(data{i},"Topic","/gps_data")
    
    %get message
    gps_message = readMessages(gps_topic,"DataFormat","struct");
    
    Latitude = cellfun(@(m) double(m.Latitude),gps_message);
    Longitude = cellfun(@(m) double(m.Longitude),gps_message);
    Altitude = cellfun(@(m) double(m.Altitude),gps_message);
    quality = cellfun(@(m) double(m.Quality),gps_message);
    zone = cellfun(@(m) string(m.Zone),gps_message);
    letter = cellfun(@(m) string(m.Letter),gps_message);
    q1 = size(find(quality==1))
    q2 = size(find(quality==2))
    q3 = size(find(quality==3))
    q4 = size(find(quality==4))
    q5 = size(find(quality==5))

    Q(i,1)=q1(:,1)
    Q(i,2)=q2(:,1)
    Q(i,3)=q3(:,1)
    Q(i,4)=q4(:,1)
    Q(i,5)=q5(:,1)
    
   

    %remove low quality data
    badData=find(quality<4)
    Latitude(badData)=[]
    Longitude(badData)=[]
    Altitude(badData)=[]
    zone(badData)=[]
    letter(badData)=[]

    %deg2utm
    utmZone = (zone+letter)
    utmZone = utmZone(1)
    [ellipsoid,estr] = utmgeoid(utmZone)
    utmstruct = defaultm('utm');
    utmstruct.zone = utmZone;
    utmstruct.geoid = ellipsoid;
    utmstruct = defaultm(utmstruct)
    [utmE,utmN] = mfwdtran(utmstruct,Latitude,Longitude)

    %ground truth OR average value
    meanAltitude = zeros(length(Altitude),1) + mean(Altitude)
    meanAltitude5 = zeros(5,1) + mean(Altitude)

    if i>2
        gt(2*i-1,:) = zeros(5,1) + mean(utmE)
        gt(2*i,:) = zeros(5,1) + mean(utmN)
    end

    
    figure
    geoplot(Latitude,Longitude,'LineWidth',8)
    geobasemap streets
    title(name{i},'Geo Map','FontSize',vFontSize,'FontWeight', vFontWeight)
    
    figure
    plot3(utmE,utmN,Altitude,'LineWidth',4)
    hold on
    plot3(gt(2*i-1,:),gt(2*i,:),meanAltitude5,'-o','Color','r','MarkerSize',20,...
    'MarkerFaceColor','#EDB120')
    hold off
   
    xlabel('utmE','FontSize',vFontSize,'FontWeight', vFontWeight)
    ylabel('utmN','FontSize',vFontSize,'FontWeight', vFontWeight)
    zlabel('Altitude','FontSize',vFontSize,'FontWeight', vFontWeight)
    legend({'rawData','grounTruth'},'Location','southwest','FontSize',vFontSize)
    title(name{i},'2D trajectory','FontSize',vFontSize,'FontWeight', vFontWeight)
    grid on
 
end
