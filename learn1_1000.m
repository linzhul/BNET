% Lawn sprinker example from Russell and Norvig p454
% See www.cs.berkeley.edu/~murphyk/Bayes/usage.html for details.

tic  %��ʼ��ʱ
%���屴Ҷ˹����ṹDAG
N = 4;  %����ͼ�����ĸ��ڵ�
dag = zeros(N,N);  %����һ��4X4����������ʾͼ����ͨ���
C = 1; S = 2; R = 3; W = 4;  %ָ���ڵ��˳��
dag(C,[R S]) = 1;  %1������ͨ,��ʾC�ڵ�ɵ���S��R�ڵ�
dag(R,W) = 1;  %��ʾR�ڵ�ɵ���W�ڵ�
dag(S,W) = 1;  %��ʾS�ڵ�ɵ���W�ڵ�

false = 1; true = 2;
ns = 2*ones(1,N);  % binary nodesÿ���ڵ���ɢֵ�ĸ���ns����

bnet = mk_bnet(dag, ns);  %����DAG��ns����һ����Ҷ˹����bnet
%���屴Ҷ˹����bnet���������ʱ�����Ҷ˹�������
bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5]);  %����C�ڵ�Ĳ���
bnet.CPD{R} = tabular_CPD(bnet, R, [0.8 0.2 0.2 0.8]);  %����R�ڵ�Ĳ���
bnet.CPD{S} = tabular_CPD(bnet, S, [0.5 0.9 0.5 0.1]);  %����S�ڵ�Ĳ���
bnet.CPD{W} = tabular_CPD(bnet, W, [1 0.1 0.1 0.01 0 0.9 0.9 0.99]);  
                                                        %����W�ڵ�Ĳ���
%bnet.CPD{W} = tabular_CPD(bnet, W, [0.99 0.1 0.1 0.01 0.01 0.9 0.9 0.99]);
bnet.CPD{W}  %�鿴��Ҷ˹�������
G = bnet.dag;
draw_graph(G);  %ͼ�񻯱�Ҷ˹����
%����Ҷ˹����bnet�Ĳ���ȡ������CPT���Ҫ�ǿ��������ͺ���ĺ���
%learn_params ѧ�õĲ���CPT4�ͺ���bayes_update_paramsѧ�õĲ���CPT5���Աȡ�
CPT = cell(1,N);
for i=1:N
  s=struct(bnet.CPD{i});  % violate object privacy
  CPT{i}=s.CPT;
end
%���ݱ�Ҷ˹����bnet����һЩ����samples��
%������learn_params�ͺ���bayes_update_paramsѧϰʹ�á�
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
bnet2 = mk_bnet(dag, ns);  %ͬ15�У�bnet2��bnet�������������ͬ
seed = 0;
%rand('state', seed); %��֤ÿ�����н����һ����rand��������α�������
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


% Find MLEs from fully observed data ������Ȼ����(maximum likelihood estimator, MLE)
bnet4 = learn_params(bnet2, samples); %���ú���learn_paramsѧϰ��Ҷ˹�������

% Bayesian updating with 0 prior is equivalent to ML estimation��û������ʱ�ȼ��ڼ�����Ȼ����
bnet5 = bayes_update_params(bnet2, samples);  %���ú���bayes_update_paramsѧϰ��Ҷ˹�������

CPT4 = cell(1,N);
for i=1:N
  s=struct(bnet4.CPD{i});  % violate object privacy
  CPT4{i}=s.CPT ;  %������learn_paramsѧ�õĲ����浽CPT4����
end
CPT4{4}
CPT5 = cell(1,N);
for i=1:N
  s=struct(bnet5.CPD{i});  % violate object privacy
  CPT5{i}=s.CPT ;  %������bayes_update_paramsѧ�õĲ����浽CPT5����
  assert(approxeq(CPT5{i}, CPT4{i}));  %assert�������Ժ���
  %approxeq(x, y, tolerance) Test for 'nearly equal'. 
  %Checks whether values are nearly equal, to within tolerance. 
  %Similar to "==", this returns either 1 for true or 0 for false, 
  %but here we report whether or not the values are nearly equal. 
end
CPT5{4}

mytimer = toc;
disp(['��������ʱ��Ϊ��', num2str(mytimer), 's'])