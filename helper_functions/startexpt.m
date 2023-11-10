function[w,cx,cy] = startexpt()

   %%% OPEN WINDOW
   Screen('Preference', 'SkipSyncTests', 1);
   [w,rect] = Screen( 'OpenWindow', 0 );
   cx = rect(3)/2; % screen center
   cy = rect(4)/2; % screen center
   
   %%% SET BACKGROUND TO MID-LEVEL GRAY
   Screen( 'FillRect', w, [128 128 128] ); % blank screen
   Screen( 'Flip', w ); 
   HideCursor;
   