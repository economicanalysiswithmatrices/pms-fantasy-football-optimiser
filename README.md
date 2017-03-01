Fantasy Football Optimiser

This is a fantasy football optimiser with an interactive interface that allows you to choose your own team name before displaying your optimised team. This optimisation is based on the official Premier League Fantasy Football league and the rules we are adhering to can be found here: https://fantasy.premierleague.com/a/help

** File required for use **

The external library we used for the scrape was a Json Parser (JSONlab - available here: https://uk.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files). This is the only file required to run the 2016 optimisation.

To run the 2015 optimisation two separate files are necessary: 'GoalsConcededPerClub.xlsx' and 'CompiledStatistics.xlsx'. The compiled statistics is just a summary file of 'Goalkeeper.xlsx', 'Defender.xlsx' etc. and we have left the individual files used to make up the overall table in the repository. 

** Running the code ** 

To run the code you firstly need to clone or download the zip folder and extract the files. From there, in Matlab, navigate to the folder to which you extracted the code and associated documents.Open ‘Optimiser.m’ 

**NOTE: There are two files called 'Optimiser' - one of them is a figure used for the background and will not do anything. Be sure to choose the '.m' file** 

Once you've opened it up, click run - there should be no need to add the JSON file to the path as this should be done automatically upon selecting '2016 team' option in the GUI. 

The Graphical User Interface will appear, giving you the opportunity to create a team name and and to choose whether to create a team based on data from 2015 or 2016. You also have the option to turn the Premier League theme music off/on along the bottom. Once you have selected your option (2015/16) there will be a short pause after which your 15 man squad should appear along with other relevant information including total points, individual points and the number of teams. For the ultimate viewing experience ensure your volume is turned on.

Once you are done, please select the 'exit' button in the bottom right corner, this way the music will turn itself off!

** Issues **

If there is an issue with the 2016 optimisation it is likely to be an issue accessing the JSON parser. To add this manually, right click on the folder 'JSONlab_ a toolbox to encode_decode JSON files' in Matlab, choose 'add to path' and then 'selected folders and subfolders'. Then try again!