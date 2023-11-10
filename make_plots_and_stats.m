clear all; close all;

% listing of data files
d = dir( sprintf('data/out.*') );
fprintf( 'found %d files\n\n',  length(d) );

% box tilt angles
tilts = [0 5 10 15 20];

% initialize data structure
dat = [];
c = 1;

% for each file
for k = 1 : length(d)

    % open the file
    fd = fopen( ['data/' d(k).name], 'r' );

    % and read it out
    while( 1 )

        % get a line
        myline = fgetl( fd );
        if( myline == -1 )
            break;
        end

        % Parse myline
        [name,r]        = strtok( myline, ' ' );    % file name
        [correct,r]     = strtok( r, ' ' );         % actual tilt angle
        [response,r]    = strtok( r, ' ' );         % button press
        [rt,r]          = strtok( r, ' ' );         % response time
        rt              = str2num(rt);              % convert response time to number

        % Parse filenames
        [filename,tail] = strtok( name, '_' );
        [Xf,tail]   = strtok( tail, '_' );
        [Yf,tail]   = strtok( tail, '_' );
        [th,tail]   = strtok( tail, '_' );
        [th,tail]   = strtok( th, '.' );
        th          = str2num( th );

        % get condition number
        if( strfind(name, '/images1/') )
            condition = 1;
            shadow = 'yes';
            tile = 'yes';
        elseif( strfind(name, '/images2/') )
            condition = 2;
            shadow = 'no';
            tile = 'yes';
        elseif(strfind(name, '/images3/') )
            condition = 3;
            shadow = 'yes';
            tile = 'no';
        elseif(strfind(name, '/images4/') )
            condition = 4;
            shadow = 'no';
            tile = 'no';
        else
            fprintf( 'unknown condition... aborting.\n' );
        end

        % parse response
        if( response == 'a' )
            flat = 2;
        elseif( response == 'f' )
            flat = 1;
        else
            flat = 0;
        end

        % add to data structure
        % subject, condition, angle, response
        dat(c,:) = [k condition th flat];

        % store as separate vectors for glme
        subjs(c)        = k;
        conditions(c)   = condition;
        shadows{c}      = shadow;
        tiles{c}        = tile;
        angles(c)       = th;
        resps(c)        = flat;

        c = c + 1;

    end
end

% total trials analyzed
fprintf( '%d trials\n', length(dat) );

% create vectors with binary outcomes for each response, used for model fitting
float           = resps == 0;
just_one_edge   = resps == 1;
no_float        = resps == 2;

% put variables into a table
T = table(subjs', conditions',categorical(shadows)', categorical(tiles)',angles',float',just_one_edge',no_float',...
    'VariableNames',{'subj','condition','shadow','tile','angle','float','just_one_edge','no_float'});

% fit logistic regression model for float response
model_float = fitglme(T,'float ~ 1 + shadow + tile + angle + (1|subj)',...
    'Distribution','Binomial','Link','logit','FitMethod','Laplace', ...
    'DummyVarCoding','reference');

% fit logistic regression model for one edge response
model_just_one_edge = fitglme(T,'just_one_edge ~ 1 + shadow + tile + angle + (1|subj)',...
    'Distribution','Binomial','Link','logit','FitMethod','Laplace', ...
    'DummyVarCoding','reference');

% fit logistic regression model for NO float response
model_no_float = fitglme(T,'no_float ~ 1 + shadow + tile + angle + (1|subj)',...
    'Distribution','Binomial','Link','logit','FitMethod','Laplace', ...
    'DummyVarCoding','reference');


% plot distribution of model responses for each actual response
figure; hold on;
subplot(3,3,1); hold on; title('float model fit')
swarmchart(categorical(T.float),fitted(model_float),'filled');
subplot(3,3,2); hold on;
plotResiduals(model_float,'histogram');
subplot(3,3,3); hold on;
plotResiduals(model_float,'fitted');

subplot(3,3,4); hold on; title('no float model fit')
swarmchart(categorical(T.no_float),fitted(model_no_float),'filled');
subplot(3,3,5); hold on;
plotResiduals(model_no_float,'histogram');
subplot(3,3,6); hold on;
plotResiduals(model_no_float,'fitted');

subplot(3,3,7); hold on; title('just one edge model fit')
swarmchart(categorical(T.just_one_edge),fitted(model_just_one_edge),'filled');
subplot(3,3,8); hold on;
plotResiduals(model_just_one_edge,'histogram');
subplot(3,3,9); hold on;
plotResiduals(model_just_one_edge,'fitted');


% plot accuracy as a function of delta difference in orientation of cube relative to floor

% for each possible response
for r = [0 1 2]

    % get response column
    if r == 0

        resp = T.float;
        name = 'float';
        ylab = 'Probability floating';

    elseif r == 1

        resp = T.just_one_edge;
        name = 'just_one_edge';
        ylab = 'Probability tilted';

    elseif r == 2

        resp = T.no_float;
        name = 'no_float';
        ylab = 'Probability flat on the ground';

    end

    % figure with just average/CI and figure with raw responses
    figave = figure();
    setupfig(3.5,3,10);

    figraw = figure();
    setupfig(3.5,3,10);

    % for each condition, tilt, and subjecy
    for c = 1:4
        for t = 1:5
            for s = 1:7

                these_resps = resp(T.subj == s & T.condition == c & T.angle == tilts(t));
                percentage_resp(c,t,s) = 100*(sum(these_resps)/numel(these_resps));

            end

        end
    end

    percentage_resp_ave = mean(percentage_resp,3);
    percentage_resp_ci = 1.96*(std(percentage_resp,[],3)/sqrt(7));

    for c = [4 3 2 1]

        % plot raw responses
        figure(figraw); hold on;
        for s = 1:7
            scatter(tilts+randn(1,5)*0.25,squeeze(percentage_resp(c,:,s)),20,ColorIt(c),'filled','MarkerFaceAlpha',.4);
        end

        % average over subjects
        if c == 1 || c == 3

            figure(figave); hold on;
            errorbar(tilts,squeeze(percentage_resp_ave(c,:)),squeeze(percentage_resp_ci(c,:)),'-','color',ColorIt(c));
            scatter(tilts,squeeze(percentage_resp_ave(c,:)),60,'k','filled','markerfacecolor',ColorIt(c),'MarkerFaceAlpha',.7,'markeredgecolor','k');

            figure(figraw); hold on;
            scatter(tilts,squeeze(percentage_resp_ave(c,:)),60,'k','filled','markerfacecolor',ColorIt(c),'MarkerFaceAlpha',.7,'markeredgecolor','k');

        else
            figure(figave); hold on;
            errorbar(tilts,squeeze(percentage_resp_ave(c,:)),squeeze(percentage_resp_ci(c,:)),'--','color',ColorIt(c));
            scatter(tilts,squeeze(percentage_resp_ave(c,:)),60,'k','filled','markerfacecolor',ColorIt(c),'MarkerFaceAlpha',.7,'markeredgecolor','k');

            figure(figraw); hold on;
            scatter(tilts,squeeze(percentage_resp_ave(c,:)),60,'k','filled','markerfacecolor',ColorIt(c),'MarkerFaceAlpha',.7,'markeredgecolor','k');

        end

    end

    figure(figraw); hold on;
    xlim([-2 22])
    ylim([-10 110])
    box on;
    set(gca,'xtick',[0 5 10 15 20],'ytick',[0 20 40 60 80 100]);
    xlabel('Box tilt angle (deg)')
    ylabel(ylab)

    exportgraphics(gcf,['plots/plot_raw_' name '.pdf'])

    figure(figave); hold on;
    xlim([-2 22])
    ylim([-10 110])
    box on;
    set(gca,'xtick',[0 5 10 15 20],'ytick',[0 20 40 60 80 100]);
    xlabel('Box tilt angle (deg)')
    ylabel(ylab)

    exportgraphics(gcf,['plots/plot_aveCI_' name '.pdf'])

end
