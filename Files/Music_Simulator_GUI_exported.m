classdef Music_Simulator_GUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        DownloadSongButton             matlab.ui.control.Button
        ClearSongButton                matlab.ui.control.Button
        AmplitudeofnoteLoudness01to1EditField  matlab.ui.control.NumericEditField
        AmplitudeofnoteLoudness01to1EditFieldLabel  matlab.ui.control.Label
        PlaySongDButton                matlab.ui.control.Button
        Durationofnote05to2secondEditField  matlab.ui.control.NumericEditField
        Durationofnote05to2secondEditFieldLabel  matlab.ui.control.Label
        AddselectednoteButton          matlab.ui.control.Button
        PleaseselectanoteListBox       matlab.ui.control.ListBox
        PleaseselectanoteListBoxLabel  matlab.ui.control.Label
        AlisMusicDesignerandProducer9000Label  matlab.ui.control.Label
        UIAxes2                        matlab.ui.control.UIAxes
        UIAxes                         matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
    end
    
    properties (Access = public)
        % The arrays which will be used to store user variables are
        % intialized here, to allow them to be used across multiple
        % different components in the app.

        % Frequency_value_array is used to store the notes the user has
        % selected to be played.

        % Note_duration_array is used to store the duration a note user entered will be
        % played.

        % Loudness_value_array is used to store how loud each individual
        % note user entered will be.

        % Finally, Song_List_Array_Orignal is simply an array which copies
        % the final contents of the notes created in the Musical_Notes_Producer function, 
        % so that it can be passed as an input to the other components of the app.

        Frequency_value_array = [];
        Note_duration_array = [];
        Loudness_value_array = [];
        Song_List_Array_Orignal = [];

    end
    
    methods (Access = private)
        
        function [] = Plot_Music(app,f1,fs,seconds,Loudness)
        
        %This determines how many frequency components the sound will have
        len = length(f1);
             
        % This code checks if the Note_duration_array passed to this
        % function as seconds is empty, if it does not even contain a single element,
        % then the program returns an error, stating this fact,
        TF = isempty(seconds);
        if TF == 1
            uialert(app.UIFigure,'No notes have been selected!','ERROR')
        else
            % If the the input parameter seconds is not empty, then it is
            % guaranteed that the remaining input parameters are not empty
            % as well

            % First we create an array Song_list_orignal which will store
            % the Music data we will create from each analogue frequency
            % passed to the functions
            Song_list_orignal = [];

            % Then in a for loop, we will first define the sampling time
            % (n) for each individual note, which will start from 0 seconds to
            % the duration the user specificed for the note currently in the loop, and the
            % intervel from 0 to the duration, will be 1 divided by the
            % sampling frequency, as when the analogue frequency is
            % converted to its digital counterpart, it will be represented
            % in terms of its 'samples'.         

            for i = 1:len
              n = (0:1/fs:seconds(i));
               % Then, in order to make the digital frequencies sound more
               % pleasent and be represented more cleanly, we will do something
               % called Amplitude Modification. Where the note's ampltiude
               % starts at 0, then slowly increases to its maximum ampltiude
               % given by loudness value, then decreases back to 0, forming a
               % diamond shape in the waveform graph.
               % To do this, we first make the mid section of each note, then
               % make the triangular portion, which is then multiplied by the
               % variable y, which contains the Audio data we received from converting 
               % each individual notes into its digital counterpart, this is then again saved
               % to another variable, y2.
              mid = (0 + n(end))/2;
              tri = -(abs(n - mid) - mid);
              tri = tri./max(tri);
              y = Loudness(i) * (sin(2*pi*f1(i)*n));  
              y2 = y .*tri;
              % This process is then repeated for the remaining notes present
              % in the Frequency_value_array. At each iteration, the data
              %p resent in y2 is added to the Song_list_orignal array.
              Song_list_copy = (y2);
              Song_list_orignal = [Song_list_orignal  Song_list_copy];            
            end
            % To be able to plot each individual note's waveform and
            % frequency following each other over the total time of the
            % 'song' which is essentially the combination of the music data
            % of every note which was converted from analogue to digital,
            % then stored in the Song_list_orignal array ,we first 
            % defined the Starting and Ending Point variables
            % These variables are responsible for storing when a note
            % starts and ends within the entire song, so as to be able to
            % plot them correctly in chronlogical order.
            Starting_point = 0;
            End_point = 0;
            % We then extract the total length of the entire song by taking
            % the length of the Song_list_orignal array previously, and
            % dividing it by the sampling frequency 44100Hz, which is the
            % maximum limit of human hearing range. The reason we divide is
            % because the Audio data we obtained from converting analogue
            % frequency of the notes into digital is represented in
            % samples instead of seconds, a 1 second 440Hz note would be equal to a 44100
            % samples 440Hz digital note.

            % X variable is essentially the length of the entire song in
            % seconds
            x = (length(Song_list_orignal))/44100;
            % length_of_song_notes is the length of the entire song in
            % samples
            length_of_song_notes = length(Song_list_orignal);
            % We then make another array called x_axis, whose starting
            % point is 0, and ending point is equal to the total length of
            % the song, or the x variable, where eachh interval from 0 to x
            % is equal to 1/fs (sampling frequnecy)

            % The reason we do this is two-fold, one , we want to represent
            % waveform of the notes in terms of amplitude agaisnt time (in
            % seconds) instead of samples.
            % Second, in order to plot the x_axis as seconds
            % agaisnt the music data present in Song_list_orignal, they
            % need to be of the same size vectors.
            % Both of this is accomplished by using linspace
            x_axis = linspace(0,x,length_of_song_notes);  

            % Finally, we then plot the X axis and Y axis using 
            % the Song_list_orignal music data, where X axis is in terms of
            % seconds (given by x_axis), while Y is in terms of Amplitude (given my Song_list_orignal).
            % We set the colour of the line to red, its width to 0.1
            % And we plot this in our first UIAxes component in the App
            plot (app.UIAxes,x_axis,Song_list_orignal,'Color','r','LineWidth',0.1); 

            % In order to plot our music data in terms of frequency agaisnt
            % time, we need to make a for loop, which will re-iterate until
            % i is > than len (The length of the Frequency_value_array)
            for i = 1:len
                % At each iteration, the endpoint is set to a value which
                % is a culmination of all notes which have been currently
                % played. For example, after the first note is played for 1
                % second, and the second note is 2 seconds long, the
                % variable End_point will be equal to 3 seconds.
                End_point = End_point + seconds(i);

                % Similar to the reasons explained previously, we want to
                % represnt time in terms of seconds, so we make another
                % array called x_axis2, but this time, its starting and
                % ending value will be dynamically updated depending on the
                % iteration.
                x_axis2 = [Starting_point:1/fs:End_point]; 

                % In order to plot a single note agaisnt a length of time,
                % we need to make an array of the note's frequency which is
                % equal to the time it is being played, so we make an array
                % containing duplicate values of the note's frequency,
                % equal to the size of the total time that specific note is
                % being played. This new array is then saved to
                % Frequency_Array (Not to be confused with
                % Frequency_value_array, which holds the frequency of all notes entered by user)
                Frequency_Array = repmat(f1(i),length(x_axis2),1);

                % We set the hold status of our second UIAxes2 component to
                % on
                hold(app.UIAxes2,"on");

                % We then plot onto UIAxes2,, where the X axis is in
                % terms of seconds (given by x_axis2 array) and Y is in
                % terms of Frequency (given by Frequency_Array)
                plot (app.UIAxes2,x_axis2,Frequency_Array,'Color','b','LineWidth',10);

                %Finally, we then update the Starting_point variable to be
                %equal to the duration value of the note which was just
                %played. If the first note was played for 3 seconds, then
                %the starting point of the second note on the graph would
                %be equal to 3 seconds, as it is immediately played
                %following it
                Starting_point = Starting_point + seconds(i);   
            end

        end
        end
        
        function [Song_list_orignal] = Musical_Notes_Producer(app,f1,fs,seconds,Loudness)

        %This determines how many frequency components the sound will have
        len = length(f1);
        
        % First we create an array Song_list_orignal which will store
        % the Music data we will create from each analogue frequency
        % passed to the functions

        Song_list_orignal = [];

        % Then in a for loop, we will first define the sampling time
        % for each individual note, which will start from 0 seconds to
        % the duration the user specificed for the note currently in the loop, and the
        % intervel from 0 to the duration, will be 1 divided by the
        % sampling frequency, as when the analogue frequency is
        % converted to its digital counterpart, it will be represented
        % in terms of its 'samples'.      
        for i = 1:len
          n = (0:1/fs:seconds(i));

         % Then, in order to make the digital frequencies sound more
         % pleasent and be represented more cleanly, we will do something
         % called Amplitude Modification. Where the note's ampltiude
         % starts at 0, then slowly increases to its maximum ampltiude
         % given by loudness value, then decreases back to 0, forming a
         % diamond shape in the waveform graph.
         % To do this, we first make the mid section of each note, then
         % make the triangular portion, which is then multiplied by the
         % variable y, which contains the Audio data we received from converting 
         % each individual notes into its digital counterpart, this is then again saved
          mid = (0 + n(end))/2;
          tri = -(abs(n - mid) - mid);
          tri = tri./max(tri);
          y = Loudness(i) * (sin(2*pi*f1(i)*n));  
          y2 = y .*tri;

         % This process is then repeated for the remaining notes present
         % in the Frequency_value_array. At each iteration, the data
         % present in y2 is added to the Song_list_orignal array.
          Song_list_copy = (y2);
          Song_list_orignal = [Song_list_orignal  Song_list_copy]; 
        end

          % After combining the music data of all analogue frequencies having been converted to digital
          % Into the Song_list_orignal array It is then passed to the public 
          % Song_List_Array_Orignal Array, which can then be accessed 
          % in other areas of the App.
          app.Song_List_Array_Orignal = Song_list_orignal;

          % The Song_list_orignal array and the sampling frequency fs which
          % was used to convert each note's frequency to its digital
          % counterpart is then passed to the sound function, which then
          % physically outputs the music data through the user's speakers
          sound(Song_list_orignal,fs);
         
     
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: AddselectednoteButton
        function AddselectednoteButtonPushed(app, event)
            % When the Add selected note Button is pressed by the user, the
            % system then takes the frequency value of the note selected in
            % the list by the user as well as the duration/loudness also
            % entered by the user for that note and assigns it to the
            % variables frequency_value, note_duration and loudness_value
            % respectively.
           
            frequency_value = app.PleaseselectanoteListBox.Value;
            note_duration = app.Durationofnote05to2secondEditField.Value;
            loudness_value = app.AmplitudeofnoteLoudness01to1EditField.Value;

            % The system then checks to see if the duration/loudness value
            % entered by the user is within the acceptable limits, if it is
            % not, then an error message dialog box pops up to user,
            % stating the problem, and until the dialog box is closed, user
            % cannot interact with the system.            
            if note_duration > 2 || note_duration < 0.5              
                uialert(app.UIFigure,'incorrect duration value','ERROR')
            elseif  loudness_value > 1 || loudness_value < 0.1
                uialert(app.UIFigure,'incorrect loudness value','ERROR')                 
            else

                % If all is good, then the variables declared earlier are
                % added to the public arrays, Frequency_value_array,
                % Note_duration_array and Loudness_value_array respectively
                % in order to be used by other components of the app.
                app.Frequency_value_array(end+1) = frequency_value;
                app.Note_duration_array(end+1) = note_duration;
                app.Loudness_value_array(end+1) = loudness_value;
                pause(note_duration);
            end
            
        end

        % Button pushed function: PlaySongDButton
        function PlaySongDButtonPushed(app, event)
            % When user pressed the Play Song Button, the system then calls
            % 2 functions present in the system.
            % First it calls the Plot_Music function, which passes the
            % Public Arrays declared in the App and the sampling frequency
            % 44100.
            % Second it calls the Musical_Notes_Producer function, with the
            % same parameters as Plot_Music.
            % The object 'app' is passed to both functions as well in order
            % to access the public arrays declared in the system.
            Plot_Music(app,app.Frequency_value_array,44100,app.Note_duration_array,app.Loudness_value_array) 
            Musical_Notes_Producer(app,app.Frequency_value_array,44100,app.Note_duration_array,app.Loudness_value_array)
             
        end

        % Button pushed function: ClearSongButton
        function ClearSongButtonPushed(app, event)
            % When user clicks the Clear Song Button, the system asks user
            % for explicit confirmation, if the user presses yes, all
            % public arrays and graphs are cleared/ set to null.           
            answer = questdlg('Are you sure you want to clear all data entered and displayed?','Question','Yes','No','No');
            switch answer
                case 'Yes'
                    app.Frequency_value_array = [];
                    app.Note_duration_array = [];
                    app.Loudness_value_array = [];
                    app.Song_List_Array_Orignal = [];
                    cla(app.UIAxes);  
                    cla(app.UIAxes2);
             % If the User presses no, then the system opens a dialog box
             % where it states the current operation has been cancelled.
                case 'No'
                    uialert(app.UIFigure,'Operation Cancelled!','Action')
            end
            
        end

        % Button pushed function: DownloadSongButton
        function DownloadSongButtonPushed(app, event)
            % When the user presses the Download Song Button, the system
            % asks user for explicit confirmation on the operation. If the
            % user presses yes, then the system checks to see if the public
            % Song_List_Array_Orignal array is empty, if it is, then the
            % System creates an error dialog box stating that no musical
            % notes have been ever selected.

            % If the array is not empty however, than the array is
            % outputted from the system as a .wav file with its bits per
            % sample being equal to 8, and its sampling frequency being
            % equal to 44100Hz.
            
            answer = questdlg('Are you sure you want to download the current note list as an MP3 file?','Question','Yes','No','No');
            switch answer
                case 'Yes'
                    TF = isempty(app.Song_List_Array_Orignal);
                    if TF == 1
                        uialert(app.UIFigure,'No notes have been selected!','ERROR')
                    else
                        audiowrite('My Custom Song!.wav',app.Song_List_Array_Orignal,44100,'BitsPerSample',8)  
                    end

             % If the User presses no, then the system opens a dialog box
             % where it states the current operation has been cancelled.
                case 'No'
                    uialert(app.UIFigure,'Operation Cancelled!','Action')
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 665 588];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, {'Waveform of notes'; ''})
            xlabel(app.UIAxes, 'Time (s)')
            ylabel(app.UIAxes, 'Amplitude')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.ColorOrder = [1 1 1];
            app.UIAxes.Position = [127 283 525 253];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Frequency of notes')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Frequency (Hz)')
            app.UIAxes2.Position = [128 36 524 239];

            % Create AlisMusicDesignerandProducer9000Label
            app.AlisMusicDesignerandProducer9000Label = uilabel(app.UIFigure);
            app.AlisMusicDesignerandProducer9000Label.BackgroundColor = [0.1333 0.1059 0.349];
            app.AlisMusicDesignerandProducer9000Label.HorizontalAlignment = 'center';
            app.AlisMusicDesignerandProducer9000Label.FontName = 'Bookman Old Style';
            app.AlisMusicDesignerandProducer9000Label.FontSize = 24;
            app.AlisMusicDesignerandProducer9000Label.FontWeight = 'bold';
            app.AlisMusicDesignerandProducer9000Label.FontColor = [1 1 1];
            app.AlisMusicDesignerandProducer9000Label.Position = [1 535 665 54];
            app.AlisMusicDesignerandProducer9000Label.Text = 'Ali''s Music Designer and Producer 9000';

            % Create PleaseselectanoteListBoxLabel
            app.PleaseselectanoteListBoxLabel = uilabel(app.UIFigure);
            app.PleaseselectanoteListBoxLabel.BackgroundColor = [0 0 0];
            app.PleaseselectanoteListBoxLabel.HorizontalAlignment = 'center';
            app.PleaseselectanoteListBoxLabel.FontColor = [1 1 1];
            app.PleaseselectanoteListBoxLabel.Position = [2 482 112 42];
            app.PleaseselectanoteListBoxLabel.Text = 'Please select a note';

            % Create PleaseselectanoteListBox
            app.PleaseselectanoteListBox = uilistbox(app.UIFigure);
            app.PleaseselectanoteListBox.Items = {'A (440hz)', 'B flat (466hz)', 'B (494hz)', 'C (523hz)', 'C sharp (554hz)', 'D (587hz)', 'D sharp (622hz)', 'E (659hz)', 'F (698hz)', 'F sharp (740hz)', 'G (784hz)', 'A flat (831hz)'};
            app.PleaseselectanoteListBox.ItemsData = [440 466 494 523 554 587 622 659 698 740 784 831];
            app.PleaseselectanoteListBox.Position = [3 231 112 236];
            app.PleaseselectanoteListBox.Value = 440;

            % Create AddselectednoteButton
            app.AddselectednoteButton = uibutton(app.UIFigure, 'push');
            app.AddselectednoteButton.ButtonPushedFcn = createCallbackFcn(app, @AddselectednoteButtonPushed, true);
            app.AddselectednoteButton.Position = [4 1 112 22];
            app.AddselectednoteButton.Text = 'Add selected note';

            % Create Durationofnote05to2secondEditFieldLabel
            app.Durationofnote05to2secondEditFieldLabel = uilabel(app.UIFigure);
            app.Durationofnote05to2secondEditFieldLabel.BackgroundColor = [0 0 0];
            app.Durationofnote05to2secondEditFieldLabel.HorizontalAlignment = 'center';
            app.Durationofnote05to2secondEditFieldLabel.FontColor = [1 1 1];
            app.Durationofnote05to2secondEditFieldLabel.Position = [6 86 109 42];
            app.Durationofnote05to2secondEditFieldLabel.Text = {'Duration of note'; '(0.5 to 2 second)'};

            % Create Durationofnote05to2secondEditField
            app.Durationofnote05to2secondEditField = uieditfield(app.UIFigure, 'numeric');
            app.Durationofnote05to2secondEditField.HorizontalAlignment = 'center';
            app.Durationofnote05to2secondEditField.Position = [5 49 109 22];

            % Create PlaySongDButton
            app.PlaySongDButton = uibutton(app.UIFigure, 'push');
            app.PlaySongDButton.ButtonPushedFcn = createCallbackFcn(app, @PlaySongDButtonPushed, true);
            app.PlaySongDButton.Position = [187 1 113 22];
            app.PlaySongDButton.Text = 'Play Song :D';

            % Create AmplitudeofnoteLoudness01to1EditFieldLabel
            app.AmplitudeofnoteLoudness01to1EditFieldLabel = uilabel(app.UIFigure);
            app.AmplitudeofnoteLoudness01to1EditFieldLabel.BackgroundColor = [0 0 0];
            app.AmplitudeofnoteLoudness01to1EditFieldLabel.HorizontalAlignment = 'center';
            app.AmplitudeofnoteLoudness01to1EditFieldLabel.FontColor = [1 1 1];
            app.AmplitudeofnoteLoudness01to1EditFieldLabel.Position = [10 176 99 42];
            app.AmplitudeofnoteLoudness01to1EditFieldLabel.Text = {'Amplitude of note'; '(Loudness)'; '(0.1 to 1)'};

            % Create AmplitudeofnoteLoudness01to1EditField
            app.AmplitudeofnoteLoudness01to1EditField = uieditfield(app.UIFigure, 'numeric');
            app.AmplitudeofnoteLoudness01to1EditField.HorizontalAlignment = 'center';
            app.AmplitudeofnoteLoudness01to1EditField.Position = [6 139 109 22];

            % Create ClearSongButton
            app.ClearSongButton = uibutton(app.UIFigure, 'push');
            app.ClearSongButton.ButtonPushedFcn = createCallbackFcn(app, @ClearSongButtonPushed, true);
            app.ClearSongButton.Position = [555 1 112 22];
            app.ClearSongButton.Text = 'Clear Song';

            % Create DownloadSongButton
            app.DownloadSongButton = uibutton(app.UIFigure, 'push');
            app.DownloadSongButton.ButtonPushedFcn = createCallbackFcn(app, @DownloadSongButtonPushed, true);
            app.DownloadSongButton.Position = [385 1 100 22];
            app.DownloadSongButton.Text = 'Download Song';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Music_Simulator_GUI_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end