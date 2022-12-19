function str = time2human(t)
% time2human(t)
% t = seconds
% str = output

if t >= 2
  strs = {'sec', 'min', 'hr', 'days', 'weeks', 'months', 'years'};
  divs = [1, 60, 60*60, 60*60*24, 60*60*24*7, 60*60*24*30, 60*60*24*365];

  n = t ./ divs;
  idx = find(n >= 1.5, 1, 'last');
  if isempty(idx)
    idx = 1;
  end
  str = [num2str(n(idx), '%0.3f'), ' ', strs{idx}];
else
  str = [num2str(t*1000, '%0.3f'), ' ms'];
end