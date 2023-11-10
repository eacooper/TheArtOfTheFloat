%%%
%%%
%%%

function[response,rt] = displayimage( im, dur, w, cx, cy )

[ydim,xdim,zdim] = size(im);
t = Screen( 'MakeTexture', w, im ); % display image
Screen( 'DrawTexture', w, t, [], [cx-xdim/2,cy-ydim/2,cx+xdim/2,cy+ydim/2] );
Screen( 'Flip', w );

beep = MakeBeep(220,0.25);

start_time = GetSecs;
response = '';
rt = -1;

%%% DISPLAY IMAGE FOR FIXED AMOUNT OF TIME
if( dur > 0 )
    while( (GetSecs - start_time) < dur )
        WaitSecs(0.001); % delay to prevent CPU hogging
    end
    Screen( 'FillRect', w, [128 128 128] ); % blank screen
    Screen( 'Flip', w );
    Screen( 'Close', t );
end

%%% GET SUBJECT FEEDBACK
done = 0;
while( ~done )
    while ( KbCheck(-1) )
        ; % wait until all keys are released
    end
    
    keyisdown = 0;
    while( ~keyisdown )
        [keyisdown, secs, keycode] = KbCheck(-1); % key down
        WaitSecs(0.001); % delay to prevent CPU hogging
    end
    response = char( KbName(keycode) );
    rt = secs - start_time;
    if( response == 'a' | response == 'f' | response == 'j' | response == 'z' )
        done = 1;
    else
        Snd( 'Play', beep );
        Snd( 'Play', beep );
    end
end


%%% CLEAR SCREEN
if( dur < 0 )
    Screen( 'FillRect', w, [128 128 128] ); % blank screen
    Screen( 'Flip', w );
    Screen( 'Close', t );
end


