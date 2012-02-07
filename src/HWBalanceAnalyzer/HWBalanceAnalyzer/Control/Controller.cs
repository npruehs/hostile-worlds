using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows.Forms;
using HWBalanceAnalyzer.Model;
using HWBalanceAnalyzer.View;
using System.ComponentModel;

namespace HWBalanceAnalyzer.Control
{
    /// <remarks>
    /// Controls the application, setting up and updating all windows, scanning
    /// directories for Hostile Worlds logs and parsing them using an
    /// additional thread.
    /// </remarks>
    public class Controller
    {
        #region Structs
        /// <summary>
        /// The description of an error that has occured parsing a Hostile
        /// Worlds log file.
        /// </summary>
        struct LogParserError
        {
            /// <summary>
            /// The name of the log file that caused the parser error.
            /// </summary>
            public string logFileName;

            /// <summary>
            /// The description of the error that has occured.
            /// </summary>
            public string errorDescription;
        }
        #endregion

        #region Fields
        /// <summary>
        /// The main window of the application.
        /// </summary>
        private MainForm mainForm;

        /// <summary>
        /// The window showing detailed information on a single match.
        /// </summary>
        private MatchForm matchForm;

        /// <summary>
        /// The parser used for extracting detailed information from Hostile
        /// Worlds log files.
        /// </summary>
        private HostileWorldsLogParser logParser;

        /// <summary>
        /// The names of all Hostile Worlds log files found.
        /// </summary>
        private List<string> logFiles;

        /// <summary>
        /// All Hostile Worlds match logs parsed.
        /// </summary>
        private List<HostileWorldsLog> matchLogs;

        /// <summary>
        /// All Hostile Worlds match logs shown in the log list.
        /// </summary>
        private List<HostileWorldsLog> boundLogs;

        /// <summary>
        /// The time the log processing started.
        /// </summary>
        private DateTime processingStartTime;

        /// <summary>
        /// The time the log processing finished.
        /// </summary>
        private DateTime processingEndTime;

        /// <summary>
        /// The number of Hostile Worlds log files already processed.
        /// </summary>
        private int logFilesProcessed;

        /// <summary>
        /// The number of server-side match logs processed.
        /// </summary>
        private int serverMatches;

        /// <summary>
        /// The number of match logs of unfinished matches processed.
        /// </summary>
        private int unfinishedMatches;

        /// <summary>
        /// The errors that have occured parsing all discovered log files.
        /// </summary>
        private List<LogParserError> parseErrors;

        /// <summary>
        /// Whether to show logs of unfinished matches, or not.
        /// </summary>
        private bool showUnfinishedMatches;
        #endregion

        #region Properties
        /// <summary>
        /// Gets the main window of the application.
        /// </summary>
        public MainForm MainForm
        {
            get { return mainForm; }
        }
        #endregion

        #region Constructors
        /// <summary>
        /// Constructs a new application controller, initializing the log
        /// parser and preparing all windows.
        /// </summary>
        public Controller()
        {
            logParser = new HostileWorldsLogParser(this);

            SetupForms();
        }

        /// <summary>
        /// Sets up all windows of the application, showing the match
        /// information window on the secondary screen, if possible.
        /// </summary>
        private void SetupForms()
        {
            // maximize main form
            mainForm = new MainForm(this);
            mainForm.WindowState = FormWindowState.Maximized;

            // create new match form
            matchForm = new MatchForm();

            // move match form to secondary screen, if possible
            if (Screen.AllScreens.Length > 1)
            {
                foreach (Screen screen in Screen.AllScreens)
                {
                    if (!screen.Primary)
                    {
                        matchForm.StartPosition = FormStartPosition.Manual;
                        matchForm.Location = screen.WorkingArea.Location;
                        break;
                    }
                }
            }

            // maximize and show match form
            matchForm.WindowState = FormWindowState.Maximized;
            matchForm.Show();
        }
        #endregion

        #region Methods
        /// <summary>
        /// Appends the specified string and a line feed to the results of the
        /// main application window.
        /// </summary>
        /// <param name="s">
        /// the string to append
        /// </param>
        public void AppendResult(string s)
        {
            mainForm.TextBoxResults.AppendText(s + "\n");
        }

        /// <summary>
        /// Clears the results of the main application window.
        /// </summary>
        public void ClearResults()
        {
            mainForm.TextBoxResults.Text = "";
        }

        /// <summary>
        /// Shows detailed information on the Hostile Worlds match with the
        /// specified index within the log list.
        /// </summary>
        /// <param name="index">
        /// the index of the match to show detailed information on
        /// </param>
        public void ShowLogInfo(int index)
        {
            // fetch the log to show information on
            HostileWorldsLog hwlog = boundLogs[index];
            DataGridView table = matchForm.DataGridView;

            // create a column for the description and one for each player
            table.ColumnCount = hwlog.Players.Count + 1;
            table.Rows.Clear();

            // initialize columns
            table.Columns[0].SortMode = DataGridViewColumnSortMode.NotSortable;

            for (int i = 0; i < hwlog.Players.Count; i++)
            {
                table.Columns[i + 1].Name = hwlog.Players[i];
                table.Columns[i + 1].HeaderText = hwlog.Players[i];
                table.Columns[i + 1].SortMode = DataGridViewColumnSortMode.NotSortable;
            }
            
            // add squad composition of all players
            string[] tableRow;

            AddEmptyTableRow(table, hwlog.Players.Count + 1, "Squad Compositition");
            AddEmptyTableRow(table, hwlog.Players.Count + 1);

            foreach (string squadMemberClass in hwlog.SquadComposition[hwlog.Players[0]].Keys.ToArray())
            {
                // add one row for each squad member class
                tableRow = new string[hwlog.Players.Count + 1];

                tableRow[0] = squadMemberClass;

                // fill columns with squad composition
                for (int i = 0; i < hwlog.Players.Count; i++)
                {
                    tableRow[i + 1] = hwlog.SquadComposition[hwlog.Players[i]][squadMemberClass].ToString();
                }

                table.Rows.Add(tableRow);
            }

            AddEmptyTableRow(table, hwlog.Players.Count + 1);

            // add ability distribution of all players
            AddEmptyTableRow(table, hwlog.Players.Count + 1, "Ability Distribution");
            AddEmptyTableRow(table, hwlog.Players.Count + 1);

            foreach (string abilityName in hwlog.AbilityDistribution[hwlog.Players[0]].Keys.ToArray())
            {
                // add one row for each ability
                tableRow = new string[hwlog.Players.Count + 1];

                tableRow[0] = abilityName;

                // fill columns with ability distribution
                for (int i = 0; i < hwlog.Players.Count; i++)
                {
                    tableRow[i + 1] = hwlog.AbilityDistribution[hwlog.Players[i]][abilityName].ToString();
                }

                table.Rows.Add(tableRow);
            }

            AddEmptyTableRow(table, hwlog.Players.Count + 1);

            // add other player data
            AddEmptyTableRow(table, hwlog.Players.Count + 1, "Other Player Data");
            AddEmptyTableRow(table, hwlog.Players.Count + 1);

            // add player APM
            tableRow = new string[hwlog.Players.Count + 1];
            tableRow[0] = "APM";

            for (int i = 0; i < hwlog.Players.Count; i++)
            {
                tableRow[i + 1] = (hwlog.Actions[hwlog.Players[i]] * 60 / hwlog.MatchTime).ToString();
            }

            table.Rows.Add(tableRow);

            // add winner
            tableRow = new string[hwlog.Players.Count + 1];
            tableRow[0] = "Winner";

            for (int i = 0; i < hwlog.Players.Count; i++)
            {
                tableRow[i + 1] = hwlog.Players[i].Equals(hwlog.Winner) ? "yes" : "no";
            }

            table.Rows.Add(tableRow);

            // resize columns
            table.AutoResizeColumns();
        }

        /// <summary>
        /// Shows an error dialog with the passed error message.
        /// </summary>
        /// <param name="message">
        /// the error message to show
        /// </param>
        public void ShowErrorDialog(string message)
        {
            MessageBox.Show(message, "An error has occured!", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        /// <summary>
        /// Gets the title of the application.
        /// </summary>
        /// <returns>
        /// the title of the application
        /// </returns>
        public string GetApplicationTitle()
        {
            Assembly a = Assembly.GetExecutingAssembly();

            object[] titles = a.GetCustomAttributes(typeof(AssemblyTitleAttribute), false);
            AssemblyTitleAttribute title = (AssemblyTitleAttribute)titles[0];

            return title.Title;
        }

        /// <summary>
        /// Gets the major and minor version of the application.
        /// </summary>
        /// <returns>
        /// the major and minor version of the application
        /// </returns>
        public string GetApplicationVersion()
        {
            Assembly a = Assembly.GetExecutingAssembly();
            AssemblyName aName = a.GetName();

            return aName.Version.Major + "." + aName.Version.Minor;
        }

        /// <summary>
        /// Gets the copyright information of the application.
        /// </summary>
        /// <returns>
        /// the copyright information of the application
        /// </returns>
        public string GetApplicationCopyright()
        {
            Assembly a = Assembly.GetExecutingAssembly();

            object[] copyrights = a.GetCustomAttributes(typeof(AssemblyCopyrightAttribute), false);
            AssemblyCopyrightAttribute copyright = (AssemblyCopyrightAttribute)copyrights[0];

            return copyright.Copyright;
        }

        /// <summary>
        /// Recursively scans the passed directory and all sub-directories
        /// for Hostile Worlds log files, adding them to the list of names of
        /// all Hostile Worlds log files found.
        /// </summary>
        /// <param name="directory">
        /// the name of the directory to scan
        /// </param>
        private void RecursivelyScanDirectory(string directory)
        {
            try
            {
                if (Directory.Exists(directory))
                {
                    // get the list of log files
                    string[] logFileNames = Directory.GetFiles(directory);

                    foreach (string logFileName in logFileNames)
                    {
                        if (logFileName.Contains(".log"))
                        {
                            logFiles.Add(logFileName);
                        }
                    }

                    // get the list of subdirectories
                    string[] subdirectories = Directory.GetDirectories(directory);

                    foreach (string directoryName in subdirectories)
                    {
                        // recursively scan all subdirectories
                        RecursivelyScanDirectory(directoryName);
                    }
                }
            }
            catch (Exception e)
            {
                ShowErrorDialog(e.Message);
            }
        }

        /// <summary>
        /// Shows passed list of Hostile Worlds matches in the main application
        /// window.
        /// </summary>
        /// <param name="hwlogs">
        /// the list of Hostile Worlds matches to show
        /// </param>
        private void ShowLogList(List<HostileWorldsLog> hwlogs)
        {
            foreach (HostileWorldsLog hwlog in hwlogs)
            {
                if (hwlog.MatchFinished || showUnfinishedMatches)
                {
                    string[] logRow = new string[6];

                    logRow[0] = hwlog.DateTime;
                    logRow[1] = hwlog.Version;
                    logRow[2] = hwlog.Map;
                    logRow[3] = hwlog.Format;
                    logRow[4] = hwlog.MatchTime.ToString();
                    logRow[5] = hwlog.Winner;

                    // bind current match log to the same index as the table row
                    boundLogs.Add(hwlog);

                    // add table row
                    mainForm.DataGridViewLogs.Rows.Add(logRow);
                }
            }
        }

        /// <summary>
        /// Clears the list of Hostile Worlds matches in the main application
        /// window.
        /// </summary>
        private void ClearLogList()
        {
            mainForm.DataGridViewLogs.Rows.Clear();
        }

        /// <summary>
        /// Adds an empty row to the passed table with the specified number
        /// of columns.
        /// </summary>
        /// <param name="table">
        /// the table to add an empty row to
        /// </param>
        /// <param name="columnCount">
        /// the number of columns of the table
        /// </param>
        private void AddEmptyTableRow(DataGridView table, int columnCount)
        {
            AddEmptyTableRow(table, columnCount, "");
        }

        /// <summary>
        /// Adds an empty row with the specified text in the first cell to the
        /// passed table with the specified number of columns.
        /// </summary>
        /// <param name="table">
        /// the table to add an empty row to
        /// </param>
        /// <param name="columnCount">
        /// the number of columns of the table
        /// </param>
        /// <param name="description">
        /// the text to add to the first cell of the empty row
        /// </param>
        private void AddEmptyTableRow(DataGridView table, int columnCount, string description)
        {
            string[] tableRow = new string[columnCount];
            tableRow[0] = description;

            for (int i = 0; i < columnCount - 1; i++)
            {
                tableRow[i + 1] = "";
            }

            table.Rows.Add(tableRow);
        }
        #endregion

        #region Methods: File Menu
        /// <summary>
        /// Raises a new FolderBrowserDialog and makes the user choose a folder
        /// to be recursively scanned for log files, and starts a new thread
        /// for parsing these files.
        /// </summary>
        public void MenuFileOpen()
        {
            FolderBrowserDialog folderBrowserDialog = mainForm.FolderBrowserDialog;

            if (folderBrowserDialog.ShowDialog() == DialogResult.OK)
            {
                // clear data grid
                ClearLogList();

                // recursively scan the picked folder
                logFiles = new List<string>();
                matchLogs = new List<HostileWorldsLog>();
                boundLogs = new List<HostileWorldsLog>();
                parseErrors = new List<LogParserError>();

                logFilesProcessed = 0;
                serverMatches = 0;
                unfinishedMatches = 0;

                RecursivelyScanDirectory(folderBrowserDialog.SelectedPath);

                // clear results window
                ClearResults();
                AppendResult("Found " + logFiles.Count + " log files.");

                // create new thread
                BackgroundWorker worker = new BackgroundWorker();
                worker.WorkerReportsProgress = true;

                worker.DoWork += new DoWorkEventHandler(BackgroundProcessLogs);
                worker.ProgressChanged += new ProgressChangedEventHandler(BackgroundProgressChanged);
                worker.RunWorkerCompleted += new RunWorkerCompletedEventHandler(BackgroundProcessLogsCompleted);

                // start the new thread for processing the logs
                processingStartTime = DateTime.Now;
                worker.RunWorkerAsync();
            }
        }

        /// <summary>
        /// Raises a new SaveFileDialog and makes the user choose a file
        /// to write the analysis results to.
        /// </summary>
        public void MenuFileExportResults()
        {
            SaveFileDialog saveFileDialog = mainForm.SaveFileDialog;
            Stream stream;

            if (saveFileDialog.ShowDialog() == DialogResult.OK)
            {
                if ((stream = saveFileDialog.OpenFile()) != null)
                {
                    // prepare new stream writer
                    StreamWriter sw = new StreamWriter(stream);

                    // write results
                    sw.Write(mainForm.TextBoxResults.Text);

                    // close stream
                    sw.Flush();
                    sw.Close();
                }
            }
        }

        /// <summary>
        /// Shows a box with information about this application.
        /// </summary>
        public void MenuFileAbout()
        {
            string title;
            string text;

            title = "About " + GetApplicationTitle();

            text = GetApplicationTitle() + "\n";
            text += "Version " + GetApplicationVersion() + "\n";
            text += GetApplicationCopyright() + "\n";
            text += "All rights reserved.";

            MessageBox.Show(text, title, MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        /// <summary>
        /// Shuts this application down.
        /// </summary>
        public void MenuFileQuit()
        {
            Application.Exit();
        }
        #endregion

        #region Methods: Multi-threaded Log Processing
        /// <summary>
        /// Parses all log files found, reporting progress to the user.
        /// </summary>
        /// <param name="sender">
        /// the thread used for parsing the logs
        /// </param>
        /// <param name="e">
        /// information on the thread used for parsing the logs
        /// </param>
        private void BackgroundProcessLogs(object sender, DoWorkEventArgs e)
        {
            BackgroundWorker worker = (BackgroundWorker)sender;
            Stream stream;

            try
            {
                foreach (string logFileName in logFiles)
                {
                    // open file stream
                    stream = new FileStream(logFileName, FileMode.Open, FileAccess.Read);

                    if (stream != null)
                    {
                        // parse log
                        List<HostileWorldsLog> hwlogs; 

                        try
                        {
                            hwlogs = logParser.ParseLogFromStream(stream);
                        }
                        catch (ArgumentException)
                        {
                            // adding a key (e.g. a player name) to a dictionary twice throws an ArgumentException
                            LogParserError parseError = new LogParserError();

                            parseError.logFileName = logFileName;
                            parseError.errorDescription = "This tool does not support matches with two or more players having the same player name.";

                            // remember the log containing the error...
                            parseErrors.Add(parseError);

                            // ... and parse the next log
                            continue;
                        }

                        matchLogs.AddRange(hwlogs);

                        // count matches
                        foreach (HostileWorldsLog log in hwlogs)
                        {
                            serverMatches++;

                            if (!log.MatchFinished)
                            {
                                unfinishedMatches++;
                            }
                        }

                        // update status progress bar
                        logFilesProcessed++;

                        worker.ReportProgress(logFilesProcessed * 100 / logFiles.Count, logFileName);
                    }
                    else
                    {
                        AppendResult("Unable to open log file " + logFileName + ".");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorDialog(ex.Message);
            }
        }

        /// <summary>
        /// Called whenever the thread parsing all log files reports progress.
        /// Updates the progress bar and the status label in the status bar
        /// of the main application window.
        /// </summary>
        /// <param name="sender">
        /// the thread used for parsing the logs
        /// </param>
        /// <param name="e">
        /// information on the progress parsing the logs
        /// </param>
        private void BackgroundProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            mainForm.SetProgress(e.ProgressPercentage);
            mainForm.SetStatus("(" + e.ProgressPercentage + " %) Processing " + (string)e.UserState  + "...");
        }

        /// <summary>
        /// Called as soon as the thread parsing all log files has finished.
        /// Shows a list of all parsed logs in the main application window.
        /// </summary>
        /// <param name="sender">
        /// the thread used for parsing the logs
        /// </param>
        /// <param name="e">
        /// information on the outcome parsing the logs
        /// </param>
        private void BackgroundProcessLogsCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            // show log information
            ShowLogList(matchLogs);

            // remember parse time
            processingEndTime = DateTime.Now;

            // show parse errors
            AppendResult("Ignored " + parseErrors.Count + " log files due to errors:");

            AppendResult("");
            foreach (LogParserError parseError in parseErrors)
            {
                AppendResult("[" + parseError.logFileName + "] " + parseError.errorDescription);
            }
            AppendResult("");

            // show results
            AppendResult("Processed server-side logs of " + serverMatches + " matches, " + unfinishedMatches + " of which have not been finished: Showing " + boundLogs.Count + " logs.");
            AppendResult("Finished in " + processingEndTime.TimeOfDay.Subtract(processingStartTime.TimeOfDay).ToString() + ".");

            mainForm.ResetStatusStrip();
        }
        #endregion
    }
}
