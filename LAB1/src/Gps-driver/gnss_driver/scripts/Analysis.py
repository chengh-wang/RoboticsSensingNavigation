#!/usr/bin/env python

import yaml
import matplotlib.pyplot as plt
import mplleaflet
import numpy as np
import seaborn as sns


def trans2Degree(DDmmm):
    mmData=str(DDmmm).split('.')
    ddData=0
    i=len(mmData[0])

    for i in range(i,i-2,-1):
        j=int(-(i-len(mmData[0])))
        if j:ddData = ddData + float(mmData[0][int(i)-1])*10
        else : ddData = ddData + float(mmData[0][int(i)-1])

    ddData=ddData+float(mmData[1])/pow(10,len(mmData[1]))
    ddData = ddData/60

    if len(mmData[0]) == 5: ddData=ddData + float(str(DDmmm)[:3])
    elif len(mmData[0]) == 4: ddData=ddData + float(str(DDmmm)[:2])
    else: print("invalid value")

    return ddData


def estimate_coef(x, y):
    
    # number of observations/points
    n = np.size(x)
    # mean of x and y vector
    m_x = np.mean(x)
    m_y = np.mean(y)
    # calculating cross-deviation and deviation about x
    SS_xy = np.sum(y*x) - n*m_y*m_x
    SS_xx = np.sum(x*x) - n*m_x*m_x
    # calculating regression coefficients
    b_1 = SS_xy / SS_xx
    b_0 = m_y - b_1*m_x
 
    return (b_0, b_1)

def plot_regression_line(x, y, b):
    # plotting the actual points as scatter plot
    plt.scatter(x, y, color = "m",
               marker = "o", s = 30)
    # predicted response vector
    y_pred = b[0] + b[1]*x
    # plotting the regression line
    plt.plot(x, y_pred, color = "g")
    # putting labels
    plt.xlabel('x')
    plt.ylabel('y')
    # function to show plot
    plt.show()
    return y_pred

def regression_calculate(x,b):
    y_pred = b[0] + b[1]*x
    return y_pred


if __name__ == '__main__':
    lat_=[]
    lon_=[]
    alt_=[]
    utm_e=[]
    utm_n=[]
    x=[]
    
    with open(r'scripts/gps_moving.yaml') as file:
        lines = file.readlines()

    for line in lines:
        data = line.split(':')
        if data[0]=='latitude':
            dataNum=data[1].split('\n')
            lat_.append(float(dataNum[0]))
            
        elif data[0]=='longitude':
            dataNum=data[1].split('\n')
            lon_.append(float(dataNum[0]))

        elif data[0]=='altitude':
            dataNum=data[1].split('\n')
            alt_.append(float(dataNum[0]))
        
        elif data[0]=='utm_easting':
            dataNum=data[1].split('\n')
            utm_e.append(float(dataNum[0]))
        
        elif data[0]=='utm_northing':
            dataNum=data[1].split('\n')
            utm_n.append(float(dataNum[0]))
            
    for i in range(len(lon_)): x.append(i)

    ## Analysis

    # x=utm_e
    y=utm_n
    x=np.array(x)
    y=np.array(y)
    b = estimate_coef(x, y)

    #use regression as gt
    gt=regression_calculate(x,b)

    gt_lon=regression_calculate(x,estimate_coef(x,lon_))
    gt_lat=regression_calculate(x,estimate_coef(x,lat_))
    
    #use mean as gt
    # gt=sum(y)/len(y)
    # for i in range(len(lon_)-1): gt=np.append(gt,sum(y)/len(y))
    # gt_lon = sum(lon_)/len(lon_)
    # gt_lat = sum(lat_)/len(lat_)

    error=y-gt
    print(error)
    # fig, utm= plt.subplots()
    fig, ax= plt.subplots()
    fig, bx= plt.subplots()
    fig, cx= plt.subplots()
    ax.scatter(x, error,s=0.01)
    bx.scatter(x, y,s=0.01)
    cx.scatter(x, gt,s=0.01)
    # utm.scatter(utm_e, utm_n,s=0.01)
    sns.displot(error)
    plt.show()
    print("Estimated coefficients:\nb_0 = {}  \
          \nb_1 = {}".format(b[0], b[1]))
 
    # plotting regression line
    # plot_regression_line(x, y, b)

    # plt.plot(gt_lon,gt_lat,"ro")
    # mplleaflet.show()
        
