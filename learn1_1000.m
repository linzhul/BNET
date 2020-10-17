% Lawn sprinker example from Russell and Norvig p454
% See www.cs.berkeley.edu/~murphyk/Bayes/usage.html for details.

tic  %开始计时
%定义贝叶斯网络结构DAG
N = 4;  %代表图中有四个节点
dag = zeros(N,N);  %创建一个4X4矩阵，用来表示图的连通情况
C = 1; S = 2; R = 3; W = 4;  %指定节点的顺序
dag(C,[R S]) = 1;  %1代表连通,表示C节点可到达S、R节点
dag(R,W) = 1;  %表示R节点可到达W节点
dag(S,W) = 1;  %表示S节点可到达W节点

false = 1; true = 2;
ns = 2*ones(1,N);  % binary nodes每个节点离散值的个数ns向量

bnet = mk_bnet(dag, ns);  %根据DAG和ns生成一个贝叶斯网络bnet
%定义贝叶斯网络bnet的条件概率表，即贝叶斯网络参数
bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5]);  %设置C节点的参数
bnet.CPD{R} = tabular_CPD(bnet, R, [0.8 0.2 0.2 0.8]);  %设置R节点的参数
bnet.CPD{S} = tabular_CPD(bnet, S, [0.5 0.9 0.5 0.1]);  %设置S节点的参数
bnet.CPD{W} = tabular_CPD(bnet, W, [1 0.1 0.1 0.01 0 0.9 0.9 0.99]);  
                                                        %设置W节点的参数
%bnet.CPD{W} = tabular_CPD(bnet, W, [0.99 0.1 0.1 0.01 0.01 0.9 0.9 0.99]);
bnet.CPD{W}  %查看贝叶斯网络参数
G = bnet.dag;
draw_graph(G);  %图像化贝叶斯网络
%将贝叶斯网络bnet的参数取出存在CPT里，主要是可以用来和后面的函数
%learn_params 学得的参数CPT4和函数bayes_update_params学得的参数CPT5作对比。
CPT = cell(1,N);
for i=1:N
  s=struct(bnet.CPD{i});  % violate object privacy
  CPT{i}=s.CPT;
end
%根据贝叶斯网络bnet生成一些数据samples，
%供函数learn_params和函数bayes_update_params学习使用。
% Generate training data

% nsamples = 1000;
% samples = cell(N, nsamples);
% for i=1:nsamples
%   samples(:,i) = sample_bnet(bnet);
% end
% data = cell2num(samples);

% load data3000;
load data5000;

% Make a tabula rasa
bnet2 = mk_bnet(dag, ns);  %同15行，bnet2与bnet仅有网络参数不同
seed = 0;
%rand('state', seed); %保证每次运行结果都一样，rand函数产生伪随机数。
bnet2.CPD{C} = tabular_CPD(bnet2, C, 'clamped', 1, 'CPT', [0.5 0.5], ...
			   'prior_type', 'dirichlet', 'dirichlet_weight', 0);
bnet2.CPD{R} = tabular_CPD(bnet2, R, 'prior_type', 'dirichlet', 'dirichlet_weight', 0);
bnet2.CPD{S} = tabular_CPD(bnet2, S, 'prior_type', 'dirichlet', 'dirichlet_weight', 0);
bnet2.CPD{W} = tabular_CPD(bnet2, W, 'prior_type', 'dirichlet', 'dirichlet_weight', 0);

Parameter_MLE=bnet2;
CPT_MLE=cell(1,N);
for i=1:N
    s=struct(Parameter_MLE.CPD{i});
    CPT_MLE{i}=s.CPT;
end

Parameter_MLE_W = CPT_MLE{4};


% Find MLEs from fully observed data 极大似然估计(maximum likelihood estimator, MLE)
bnet4 = learn_params(bnet2, samples); %调用函数learn_params学习贝叶斯网络参数

% Bayesian updating with 0 prior is equivalent to ML estimation若没有先验时等价于极大似然估计
bnet5 = bayes_update_params(bnet2, samples);  %调用函数bayes_update_params学习贝叶斯网络参数

CPT4 = cell(1,N);
for i=1:N
  s=struct(bnet4.CPD{i});  % violate object privacy
  CPT4{i}=s.CPT ;  %将函数learn_params学得的参数存到CPT4当中
end
CPT4{4}
CPT5 = cell(1,N);
for i=1:N
  s=struct(bnet5.CPD{i});  % violate object privacy
  CPT5{i}=s.CPT ;  %将函数bayes_update_params学得的参数存到CPT5当中
  assert(approxeq(CPT5{i}, CPT4{i}));  %assert（）断言函数
  %approxeq(x, y, tolerance) Test for 'nearly equal'. 
  %Checks whether values are nearly equal, to within tolerance. 
  %Similar to "==", this returns either 1 for true or 0 for false, 
  %but here we report whether or not the values are nearly equal. 
end
CPT5{4}

mytimer = toc;
disp(['程序运行时间为：', num2str(mytimer), 's'])