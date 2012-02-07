using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using HWBalanceAnalyzer.Control;

namespace HWBalanceAnalyzer.View
{
    /// <remarks>
    /// The main window of the application.
    /// </remarks>
    public partial class MainForm : Form
    {
        #region Fields
        /// <summary>
        /// The controller to be notified whenever the user interacts with
        /// this window.
        /// </summary>
        private Controller controller;
        #endregion

        #region Properties
        /// <summary>
        /// Gets the FolderBrowserDialog used for selecting a log folder to
        /// be recursively scanned.
        /// </summary>
        public FolderBrowserDialog FolderBrowserDialog
        {
            get { return folderBrowserDialog; }
        }

        /// <summary>
        /// Gets the SaveFileDialog used for selecting a file to save the
        /// analysis results to.
        /// </summary>
        public SaveFileDialog SaveFileDialog
        {
            get { return saveFileDialog; }
        }

        /// <summary>
        /// Gets the DataGridView showing the list of all successfully
        /// parsed logs.
        /// </summary>
        public DataGridView DataGridViewLogs
        {
            get { return dataGridViewLogs; }
        }

        /// <summary>
        /// Gets the TextBox showing the analysis results.
        /// </summary>
        public TextBox TextBoxResults
        {
            get { return textBoxResults; }
        }
        #endregion

        #region Constructors
        /// <summary>
        /// Constructs and initialized a new main window for the application.
        /// </summary>
        /// <param name="controller">
        /// the controller to be notified whenever the user interacts with
        /// the new window
        /// </param>
        public MainForm(Controller controller)
        {
            InitializeComponent();

            this.controller = controller;

            // set title
            this.Text = controller.GetApplicationTitle() + " " + controller.GetApplicationVersion();

            // prepare browse folder dialog
            FolderBrowserDialog.Description = "Select a folder to be recursively scanned for log files!";
            FolderBrowserDialog.ShowNewFolderButton = false;

            // prepare export results dialog
            SaveFileDialog.AddExtension = true;
            SaveFileDialog.FileName = "results.txt";
            SaveFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*";
            SaveFileDialog.OverwritePrompt = true;
            SaveFileDialog.ValidateNames = true;

            // prepare status strip
            ResetStatusStrip();
        }
        #endregion

        #region Methods
        /// <summary>
        /// Sets the value of the progress bar in the status bar of this window
        /// to the specified value.
        /// </summary>
        /// <param name="progressPercentage">
        /// the new value between 0 and 100 for the progress bar
        /// </param>
        public void SetProgress(int progressPercentage)
        {
            toolStripProgressBar.Value = progressPercentage;
        }

        /// <summary>
        /// Sets the text of the status label in the status bar of this window.
        /// </summary>
        /// <param name="status">
        /// the new text for the status label
        /// </param>
        public void SetStatus(string status)
        {
            toolStripStatusLabel.Text = status;
        }

        /// <summary>
        /// Resets the status bar of this window, clearing the progress bar and
        /// the status label.
        /// </summary>
        public void ResetStatusStrip()
        {
            toolStripProgressBar.Value = 0;
            toolStripStatusLabel.Text = "Ready.";
        }
        #endregion

        #region Methods: Events
        /// <summary>
        /// Called whenever the user selects a new log in the log list. Shows
        /// information on that match in the match info window.
        /// </summary>
        /// <param name="sender">
        /// the log list
        /// </param>
        /// <param name="e">
        /// information on the event that has been fired by the list
        /// </param>
        private void dataGridViewLogs_SelectionChanged(object sender, EventArgs e)
        {
            if (dataGridViewLogs.SelectedRows.Count > 0)
            {
                controller.ShowLogInfo(dataGridViewLogs.SelectedRows[0].Index);
            }
        }
        #endregion

        #region Methods: File Menu
        /// <summary>
        /// Called whenever the user selects the Open item in the File menu.
        /// Raises a new FolderBrowserDialog and makes the user choose a folder
        /// to be recursively scanned for log files
        /// </summary>
        /// <param name="sender">
        /// the Open item in the File menu
        /// </param>
        /// <param name="e">
        /// information on the event that has been fired by the menu item
        /// </param>
        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
            controller.MenuFileOpen();
        }

        /// <summary>
        /// Called whenever the user selects the Save item in the File menu.
        /// Raises a new SaveFileDialog and makes the user choose a file
        /// to write the analysis results to.
        /// </summary>
        /// <param name="sender">
        /// the Save item in the File menu
        /// </param>
        /// <param name="e">
        /// information on the event that has been fired by the menu item
        /// </param>
        private void exportResultsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            controller.MenuFileExportResults();
        }

        /// <summary>
        /// Called whenever the user selects the About item in the File menu.
        /// Shows a box with information about this application.
        /// </summary>
        /// <param name="sender">
        /// the About item in the File menu
        /// </param>
        /// <param name="e">
        /// information on the event that has been fired by the menu item
        /// </param>
        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            controller.MenuFileAbout();
        }

        /// <summary>
        /// Called whenever the user selects the Quit item in the File menu.
        /// Shuts down this application.
        /// </summary>
        /// <param name="sender">
        /// the Quit item in the File menu
        /// </param>
        /// <param name="e">
        /// information on the event that has been fired by the menu item
        /// </param>
        private void quitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            controller.MenuFileQuit();
        }
        #endregion
    }
}
