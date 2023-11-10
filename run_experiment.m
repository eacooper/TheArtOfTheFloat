% Show a single image that has either consistent or inconsistent perspective between box and floor
% Observers determines if "box is laying flat on floor": yes = 'f'; no = 'j'

clear;

% add path to helper functions
addpath('./helper_functions')

%%% GET USER INITIALS FOR OUTPUT FILE NAME
initials = input( 'Initials: ', 's' );
time = clock;
outfile = sprintf( 'out.%s.%d.%d.%d.%d.%d.txt', initials, round(time(2:6)) );
fdout = fopen( outfile, 'w' );

Ntrials  = 50; % number of trials
duration = 2; % seconds

%%% CREATE WINDOW
[w,cx,cy] = startexpt;

%%% GENERATE STIMULI TO BE DISPLAYED
VX = [-10 0]; % range of possible viewpoints
VY = [-40 : 10 : 40]; % range of possible viewpoints
stim = [];
c = 1;
for k = 1 : Ntrials
    for cond = 1 : 4
        for th = 0 : 5 : 20
            if( th == 0 )
                vx = VX( randi( [1, length(VX)] ) ); vy = VY( randi( [1, length(VY)] ) );
                stim(c).im = sprintf( 'images/images%d/cube_%d_%d_%d.jpg',  cond, vx, vy, th );
                stim(c).correct = '0';
                c = c + 1;
            elseif( th == 5 )
                if( rand < 0.4 )
                    vx = VX( randi( [1, length(VX)] ) ); vy = VY( randi( [1, length(VY)] ) );
                    stim(c).im = sprintf( 'images/images%d/cube_%d_%d_%d.jpg', cond, vx, vy, th );
                    stim(c).correct = '5';
                    c = c + 1;
                end
            elseif( th == 10 )
                if( rand < 0.3 )
                    vx = VX( randi( [1, length(VX)] ) ); vy = VY( randi( [1, length(VY)] ) );
                    stim(c).im = sprintf( 'images/images%d/cube_%d_%d_%d.jpg', cond, vx, vy, th );
                    stim(c).correct = '10';
                    c = c + 1;
                end
            elseif( th == 15 )
                if( rand < 0.2 )
                    vx = VX( randi( [1, length(VX)] ) ); vy = VY( randi( [1, length(VY)] ) );
                    stim(c).im = sprintf( 'images/images%d/cube_%d_%d_%d.jpg' , cond, vx, vy, th );
                    stim(c).correct = '15';
                    c = c + 1;
                end
            elseif( th == 20 )
                if( rand < 0.1 )
                    vx = VX( randi( [1, length(VX)] ) ); vy = VY( randi( [1, length(VY)] ) );
                    stim(c).im = sprintf( 'images/images%d/cube_%d_%d_%d.jpg', cond, vx, vy, th );
                    stim(c).correct = '20';
                    c = c + 1;
                end
            end
        end
    end
end
Nstim = c - 1;

%%% DISPLAY
ind = randperm( Nstim );
stim = stim(ind); % random order of stim
ListenChar(2); % disable

for c = 1 : Nstim
    %%% LOAD AND COMBINE IMAGES
    im = imread( stim(c).im );
    
    %%% DISPLAY IMAGE
    [response,rt] = displayimage( im, duration, w, cx, cy );
    
    %%% CHECK IF USER IS ABORTING ('z')
    if( response == 'z' )
        fclose( fdout );
        stopexpt;
        ListenChar(); % re-enable
        return;
    end
    
    %%% PRINT RESULTS
    fprintf( fdout, '%40s %3s %3s %10.3f\n', stim(c).im, stim(c).correct, response, rt );
    WaitSecs(0.5); % short delay between trials
    
    %%% PAUSE EVERY 60^th IMAGE
    if( mod( c, 60 ) == 0 )
        pause = imread( 'images/pause.jpg' );
        displayimage( pause, -1, w, cx, cy );
    end
end
fclose( fdout );
stopexpt;
ListenChar(); % re-enable

