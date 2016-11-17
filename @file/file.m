classdef file < handle
%% class file
%
% fileparts wrapper and error screening super class. 
%
% * class can be constructed on load w/ fullpath or using default temp loc
%
% KNOWN BUGS
% * when constructing path, name, and extension on initial load, file names
% with a . in them will have extension lost. TO AVOID THIS, create instance
% then assign name = fdir;
%
% author: jdv
% create date: 22-Jul-2016 08:57:19

%% object properties 
	properties
        path = 'C:\Temp' % root path  
        name = 'foo'     % class name
        ext = '.txt'     % text extension
        unique           % boolean. 1 = file name is unique in the path
    end
    
%% dependent properties
	properties (Dependent)
        fullname % full file path/name.ext generated 
    end

%% developer properties
	properties (Access = private)
    end
    
%% dynamic methods
	methods
        
    %% constructor
		function self = file(fullpath)
            if nargin > 0 && ~isempty(fullpath)
                [self.path,self.name,self.ext] = fileparts(fullpath);
            end
        end
        
    %% ordinary        
        function fid = open(self,perm)
        %% open() - open file with error screening capability.
        % this function is meant to be a catch-all for catching errors (for
        % lack of a better word) and aid in scalability
        %
        % perm = optional permissions, defaults to read only -> perm = 'r';
        %
            if nargin < 2 % error screen null perm entry
                perm = 'r'; % default to read only
            end
            
            % if the file doesn't exist choose write
            if ~exist(self.fullname)
                perm = 'w';
            end
            
            % open file with permissions
            [fid, errmsg] = fopen(self.fullname,perm);
            if ~isempty(errmsg)
                error(errmsg);
            end 
        end  

    %% dependent methods
        function set.name(self,value)
        %%
        % note 
        % * path inside of name will rewrite path
        % 
            if isempty(value)
                error('need a name, dawg');
            end
            
            chk=0; % check for name assignment
            
            % look for trailing '.'
            if strcmp(value(end),'.')
                % remove
                value = value(1:end-1);
            end
             
            % look for embedded path
            [pth,nm,xt] = fileparts(value);
            if ~isempty(pth)        % check for included path
                self.path = pth;    % over write current path
                value = [nm xt]; % re-set name w/o path
            end
            
            % look for '.' extension
            ind = regexp(value,'\.');
            if ~isempty(ind) % multiple extensions
                self.name = value(1:ind(end)-1); % save name
                self.ext  = value(ind(end):end);   % save last ext 
            else % no extensions
                self.name = value; % save plain ol' name
            end
        end
        
        function fullname = get.fullname(self)
        %% fullname
        % get full file name based on path, name, and ext.
        % error screen '.txt' 'txt' possibility
%             self.chk_name() % chk file name
            
            % create full path/file name
            fullname = fullfile(self.path,[self.name self.ext]);
        end
        
        function isuniquefile(self)
        %% Check if file is unique in path
            % list contents of directory
            dirnames = dir(self.path);
            % Loop through to see if the result file name already exists
            self.unique = 1; % Set default state (is a unique file)
            for ii = 1:length(dirnames)
                if strcmp([self.name self.ext], dirnames(ii).name) % When matched
                    self.unique = 0; % Set state not-unique
                    break % exit loop
                end
            end
            
        end
    end

%% static methods
	methods (Static)
        out = insidequotes(in);
    end

%% protected methods
	methods (Access = protected)
	end

end
