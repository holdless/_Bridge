clean;
% H: terrorist plane attack
% T: plane crashes into a NYC skyscraper
% 
% alternative case2:
% H: girl likes this boy
% T: girl kisses this boy
% 
% alternative case3:
% H: girl likes this boy
% T: girl talks to this boy

% concept:
%   given a result T, want to know how possible this result is caused by
%   source H. we should have:
%       1. prob(H): prob. of this source happening. usually by guessing,
%       not so much data can help to do objectively guess
%       2. prob(T|H): prob. of if this source happened, how possible the
%       result happens. usually by intuition
%       3. prob(T|H'): usually by hitorical statistic data. not so much
%       data

% % case 1
% H = 0.005/100; % init guess for H
% T_given_H = 100/100; % prob. of T given H
% T_given_nH = 0.008/100; % prob. of T given H'
% % case 2
% H = 0.005/100; % init guess for H
% T_given_H = 50/100; % prob. of T given H
% T_given_nH = 0.008/100; % prob. of T given H'
% case 1
H = 0.05/100; % init guess for H
T_given_H = 60/100; % prob. of T given H
T_given_nH = 10/100; % prob. of T given H'

nH = 1-H; 

for epoch = 1:3
    T_and_H = T_given_H*H; % prob. of T&H
    T_and_nH = T_given_nH*nH; % prob. of T&H'
    H_given_T = 1/(1 + T_and_nH/T_and_H);
    H = H_given_T;
end
