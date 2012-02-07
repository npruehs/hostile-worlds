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
    /// The window showing detailed information on a single match.
    /// </remarks>
    public partial class MatchForm : Form
    {
        #region Properties
        /// <summary>
        /// Gets the DataGridView showing detailed information on a single match.
        /// </summary>
        public DataGridView DataGridView
        {
            get { return dataGridView; }
        }
        #endregion

        #region Constructors
        /// <summary>
        /// Creates a new window for showing detailed information on a single match.
        /// </summary>
        public MatchForm()
        {
            InitializeComponent();

            // set title
            this.Text = "Match Information";
        }
        #endregion
    }
}
