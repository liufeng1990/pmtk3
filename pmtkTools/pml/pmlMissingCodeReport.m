function [missing, pg] = pmlMissingCodeReport(bookSource, includeCodeSol, destFile)
% Display an html table of files referenced in PML but not in PMTK

% This file is from pmtk3.googlecode.com


%% Input
%
% bookSource      - path to the PML latex source containing e.g. pml.tex
%                  (default = C:\kmurphy\dropbox\PML\Text)
%
% includeCodeSol  - if true (default) the codeSol directory is also
%                   searched. 
%% Output
%
% missing         - a cell array of the missing m-files not found in PML
% pg              - hard cover page or pages where the code is referenced. 
%
%  *** Also displays an html table ***
%%
% Don't include these functions in the report
ignoreList = {'polya-fit'  % In light-speed
              'lm'         % R function (ours is called linearRegressionFrequentist)
              'ReBEL'      % http://choosh.csee.ogi.edu/rebel/
              'demo-gpr'   % Carl Rasmussenís demo-gpr script
              'diana'      % R package
             };


SetDefaultValue(1, 'bookSource', getConfigValue('PMTKpmlBookSource'));
SetDefaultValue(2, 'includeCodeSol', false); 

if includeCodeSol
   codeSolDir = fullfile(bookSource, '..', 'CodeSol');
   codeSolFiles = mfiles(codeSolDir, 'removeExt', true);
else
    codeSolFiles = {};
end
[pmlCode, pg] = pmlCodeRefs(fullfile(bookSource, 'code.ind'));

missing = pmlCode;
[missing, idx] = setdiff(missing, codeSolFiles); 
pg = pg(idx); 
[missing, idx] = setdiff(missing, ignoreList);
pg = pg(idx); 
builtinMatlab = isbuiltin(missing); 
missing = missing(~builtinMatlab); 
pg = pg(~builtinMatlab); 
found = cellfun(@(c)exist(c, 'file'), missing); 
missing = missing(~found); 
pg = pg(~found); 

if isempty(missing)
  fprintf('no code is missing\n')
  return;
end

colNames = {'File Name' 'Pages(s)'};
pmtkRed = getConfigValue('PMTKred'); 
  header = [...
        sprintf('<font align="left" style="color:%s"><h2>PML Missing codename{} Files</h2></font>\n', pmtkRed),...
        sprintf('<br>Revision Date: %s<br>\n', date()),...
        sprintf('<br>PML version: %s<br>\n', pmlGetLastModDate()), ...
        sprintf('<br>Auto-generated by %s.m<br>\n', mfilename()),...
        sprintf('<br>Missing Files: %d<br>', numel(missing)), ...
        sprintf('<br>\n')...
        ];
    
if nargin < 3
    htmlTable('data', [missing, cellfuncell(@mat2str, pg)], ...
       'dataAlign', 'left', 'colNames', colNames, 'header', header, ...
         'colNameColors'   , {pmtkRed, pmtkRed});
else
    htmlTable('data', [missing, cellfuncell(@mat2str, pg)],...
        'dataAlign', 'left', 'colNames', colNames, ...
        'doShow', false', 'doSave', true, 'filename', destFile, ...
        'header', header,  'colNameColors'   , {pmtkRed, pmtkRed});
end



