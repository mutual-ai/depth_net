function model = ufomkl_test(Ktrain, Ytrain, model, options)
% Auxiliary function for the demo for the multiclass UFO-MKL algorithm.
%
%   References:
%     - Orabona, F., Jie, L. (2011).
%       Ultra-Fast Optimization Algorithm for Sparse Multi Kernel Learning.
%       Proceedings of the 28th International Conference on Machine Learning.

%    This file is part of the DOGMA library for MATLAB.
%    Copyright (C) 2009-2011, Francesco Orabona
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    Contact the author: francesco [at] orabona.com
%                        jluo      [at] idiap.ch

if ~isfield(model, 'loss'),  model.loss = [];  end
if ~isfield(model, 'norms'), model.norms = []; end
if ~isfield(model, 'obj'),   model.obj  = [];  end

out = full(model.beta)*kbeta(Ktrain, model.weights');

loss = 0;
for i = 1:numel(Ytrain)
    margin_true = out(Ytrain(i),i);
    out(Ytrain(i),i) = -Inf;
    margin_pred = max(out(:,i));
    loss = loss+max(1-margin_true+margin_pred,0);
end

model.loss(end+1) = loss/numel(Ytrain);
model.norms(end+1) = norm(sqrt(model.sqnorms).*model.weights,model.p)^2;
model.obj(end+1) = model.lambda*model.norms(end)/2+model.loss(end);

fprintf('Training Loss:%d\tNorm of w:%d\tObj:%d\n',model.loss(end),model.norms(end),model.obj(end));

if isfield(options, 'Ktest')
    if ~isfield(model, 'acc1'), model.acc1 = []; end
    if ~isfield(model, 'acc2'), model.acc2 = []; end  

    out = full(model.beta)*kbeta(options.Ktest, model.weights');

    [mx,pred]=max(out,[],1);
    model.acc1(end+1)=numel(find(pred==options.Ytest))/numel(pred)*100;

    % average accurarcy over all categories
    correct = zeros(1,model.n_cla);
    for c = 1:model.n_cla
        idx = find(options.Ytest==c);
        correct(c) = numel(find(pred(idx)==options.Ytest(idx)))/numel(idx)*100;
    end
    model.acc2(end+1)= mean(correct); 

    fprintf('Accuracy:%.2f\t Avergage Accuracy per Class:%.2f\n\n',model.acc1(end), model.acc2(end));
end
