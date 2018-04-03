function [indx, quantv, distor] = Quantiz(sig, partition, varargin)
%QUANTIZ Produce a quantization index and a quantized output value.
%   INDX = QUANTIZ(SIG, PARTITION) produces a quantization index INDX of the
%   input signal SIG based on the decision points PARTITION. Each element in
%   INDX is one of the N integers in range [0 : N-1]. PARTITION is a strict
%   ascending ordered N-1 vector that specifies the boundaries. Elements of INDX
%   = 0, 1, 2, ..., N-1 represent SIG in the range of (-Inf, PARTITION(1)],
%   (PARTITION(1), PARTITION(2)], (PARTITION(2), PARTITION(3)], ...,
%   (PARTITION(N-1), Inf).
%
%   [INDX, QUANTV] = QUANTIZ(SIG, PARTITION, CODEBOOK) produces the output value
%   of the quantizer in QUANTV. CODEBOOK is a length N vector that contains the
%   output set.
%
%   [INDX, QUANTV, DISTOR] = QUANTIZ(SIG, PARTITION, CODEBOOK) outputs DISTOR,
%   the estimated distortion value of the quantization.
%
%   There is no decode quantizer function in this toolbox. The decode
%   computation can be done using the command Y = CODEBOOK(INDX+1).
%
%   See also LLOYDS, DPCMENCO, DPCMDECO.

%   Copyright 1996-2011 The MathWorks, Inc.


% Initial error checks ------------------------------------

error(nargchk(2,3,nargin,'struct'));

if ( isempty(sig) || ~isreal(sig) || ~isvector(sig) )
    error(message('comm:quantiz:invalidSig'));
end

if ( isempty(partition) || ~isreal(partition) || ~isvector(partition) || ...
     any(sort(partition) ~= partition) )
    error(message('comm:quantiz:invalidPartition'));
end


% Compute INDX
[nRows, nCols] = size(sig);   % to ensure proper output orientation
indx = zeros(nRows, nCols);
for i = 1 : length(partition)
    indx = indx + (sig > partition(i));
end;

if nargout < 2  % Don't output quantized values
    return
end;

% Compute QUANTV
if nargin < 3
    error(message('comm:quantiz:fewInputs'));
end;

codebook = varargin{1};
if ( isempty(codebook) || ~isvector(codebook) || ~isreal(codebook) || ...
     length(codebook) ~= length(partition)+1 )
    error(message('comm:quantiz:invalidCodebook'));
end
quantv = codebook(indx+1);

if nargout > 2
    % Compute distortion
    distor = 0;
    for i = 0 : length(codebook)-1
        distor = distor + sum((sig(find(indx==i)) - codebook(i+1)).^2);
    end;
    distor = distor / length(sig);
end

% [EOF] - quantiz.m