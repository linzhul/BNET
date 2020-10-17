# BNET  
已知贝叶斯网络结构，进行参数训练。  

## 开发环境  
Using MATLAB

## 网络结构  
四个节点包括Cloudy、Sprinkler、Rain和WetGrass，分别记为C、S、R和W。    
N = 4;  代表图中有四个节点
dag = zeros(N,N);  创建一个4X4矩阵，用来表示图的连通情况  
C = 1; S = 2; R = 3; W = 4;  指定节点的顺序  
dag(C,[R S]) = 1;  1代表连通,表示C节点可到达S、R节点  
dag(R,W) = 1;  表示R节点可到达W节点  
dag(S,W) = 1;  表示S节点可到达W节点  
## 条件概率表  
贝叶斯网络参数  
bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5]);  设置C节点的参数  
bnet.CPD{R} = tabular_CPD(bnet, R, [0.8 0.2 0.2 0.8]);  设置R节点的参数  
bnet.CPD{S} = tabular_CPD(bnet, S, [0.5 0.9 0.5 0.1]);  设置S节点的参数  
bnet.CPD{W} = tabular_CPD(bnet, W, [1 0.1 0.1 0.01 0 0.9 0.9 0.99]);  设置W节点的参数  
## 运行
运行程序可以获得各个节点的所有参数，以及该程序运行所花费的时间。  
通过注释相关代码，可以选择1000，3000或5000个样本进行训练。  
