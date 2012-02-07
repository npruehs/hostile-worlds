using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace HWBalanceAnalyzer.Model
{
    /// <remarks>
    /// Holds detailed information on a single Hostile Worlds match.
    /// </remarks>
    public class HostileWorldsLog
    {
        #region Fields
        /// <summary>
        /// The date and time of the log file describing the match.
        /// </summary>
        private string dateTime;

        /// <summary>
        /// The Hostile Worlds version the match has been played with.
        /// </summary>
        private string version;

        /// <summary>
        /// The map the match has been played on.
        /// </summary>
        private string map;

        /// <summary>
        /// The player lineup of the match (e.g. 1v1).
        /// </summary>
        private string format;

        /// <summary>
        /// The list of players that have participated in the match.
        /// </summary>
        private List<string> players;

        /// <summary>
        /// The length of the match, in seconds.
        /// </summary>
        private int matchTime;

        /// <summary>
        /// The name of the player that has won the match.
        /// </summary>
        private string winner;

        /// <summary>
        /// Whether the match has been properly finished, or not.
        /// </summary>
        private bool matchFinished;

        /// <summary>
        /// The number of squad members that have been called in the match,
        /// per player and class.
        /// </summary>
        private Dictionary<string, Dictionary<string, int>> squadComposition;

        /// <summary>
        /// The number of abilities that have been used in the match,
        /// per player and ability.
        /// </summary>
        private Dictionary<string, Dictionary<string, int>> abilityDistribution;

        /// <summary>
        /// The number of actions each player has performed in the match.
        /// </summary>
        private Dictionary<string, int> actions;
        #endregion

        #region Properties
        /// <summary>
        /// Gets or sets the date and time of the log file describing the match.
        /// </summary>
        public string DateTime
        {
            get { return dateTime; }
            set { dateTime = value; }
        }

        /// <summary>
        /// Gets or sets the Hostile Worlds version the match has been played with.
        /// </summary>
        public string Version
        {
            get { return version; }
            set { version = value; }
        }

        /// <summary>
        /// Gets or sets the map the match has been played on.
        /// </summary>
        public string Map
        {
            get { return map; }
            set { map = value; }
        }

        /// <summary>
        /// Gets or sets the player lineup of the match (e.g. 1v1).
        /// </summary>
        public string Format
        {
            get { return format; }
            set { format = value; }
        }

        /// <summary>
        /// Gets the list of players that have participated in the match.
        /// </summary>
        public List<string> Players
        {
            get { return players; }
        }

        /// <summary>
        /// Gets or sets the length of the match, in seconds.
        /// </summary>
        public int MatchTime
        {
            get { return matchTime; }
            set { matchTime = value; }
        }

        /// <summary>
        /// Gets or sets the name of the player that has won the match.
        /// </summary>
        public string Winner
        {
            get { return winner; }
            set { winner = value; }
        }

        /// <summary>
        /// Gets or sets whether the match has been properly finished, or not.
        /// </summary>
        public bool MatchFinished
        {
            get { return matchFinished; }
            set { matchFinished = value; }
        }

        /// <summary>
        /// Gets the number of squad members that have been called in the
        /// match, per player and class.
        /// </summary>
        public Dictionary<string, Dictionary<string, int>> SquadComposition
        {
            get { return squadComposition; }
        }

        /// <summary>
        /// Gets the number of abilities that have been used in the match,
        /// per player and ability.
        /// </summary>
        public Dictionary<string, Dictionary<string, int>> AbilityDistribution
        {
            get { return abilityDistribution; }
        }

        /// <summary>
        /// Gets the number of actions each player has performed in the match.
        /// </summary>
        public Dictionary<string, int> Actions
        {
            get { return actions; }
        }
        #endregion

        #region Constructors
        /// <summary>
        /// Constructs a new log object for storing detailed information on a
        /// single Hostile Worlds match.
        /// </summary>
        public HostileWorldsLog()
        {
            players = new List<string>();

            squadComposition = new Dictionary<string, Dictionary<string, int>>();
            abilityDistribution = new Dictionary<string, Dictionary<string, int>>();
            actions = new Dictionary<string, int>();
        }
        #endregion
    }
}
