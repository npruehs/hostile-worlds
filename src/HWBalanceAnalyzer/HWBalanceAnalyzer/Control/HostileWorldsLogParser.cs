using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using HWBalanceAnalyzer.Model;

namespace HWBalanceAnalyzer.Control
{
    /// <remarks>
    /// Extracts detailed information from Hostile Worlds log files.
    /// </remarks>
    class HostileWorldsLogParser
    {
        #region Constants
        /// <summary>
        /// String that is contained by date/time log lines, only.
        /// </summary>
        private const string LOGLINE_DATETIME = "Log file open, ";

        /// <summary>
        /// String that is contained by version log lines, only.
        /// </summary>
        private const string LOGLINE_VERSION = "This is Hostile Worlds version ";

        /// <summary>
        /// String that is contained by log lines indicating a starting match,
        /// only.
        /// </summary>
        private const string LOGLINE_NEWMATCH = "SERVER: New match started.";

        /// <summary>
        /// String that is contained by map log lines, only.
        /// </summary>
        private const string LOGLINE_MAP = "SERVER: Map ";

        /// <summary>
        /// String that is contained by format log lines, only.
        /// </summary>
        private const string LOGLINE_FORMAT = "SERVER: Format ";

        /// <summary>
        /// String that is contained by player name log lines, only.
        /// </summary>
        private const string LOGLINE_PLAYER = "SERVER: Player ";

        /// <summary>
        /// String that is contained by match length log lines, only.
        /// </summary>
        private const string LOGLINE_MATCHTIME = "SERVER: Match time ";

        /// <summary>
        /// String that is contained by log lines indicating the winning player
        /// of a match, only.
        /// </summary>
        private const string LOGLINE_WINNER = "SERVER: Winner ";

        /// <summary>
        /// String that is contained by log lines indicating a finishing match,
        /// only.
        /// </summary>
        private const string LOGLINE_MATCHENDED = "SERVER: Match ended.";

        /// <summary>
        /// String that is immediately followed by the class of a squad member
        /// called by a player.
        /// </summary>
        private const string LOGLINE_SQUADMEMBERCALLED_PREFIX = "SERVER: Squad Member ";

        /// <summary>
        /// String that is immediately followed by the name of a player who has
        /// called a squad member.
        /// </summary>
        private const string LOGLINE_SQUADMEMBERCALLED_INFIX = "called by ";

        /// <summary>
        /// String that is immediately followed by the name of an ability used
        /// by a player.
        /// </summary>
        private const string LOGLINE_ABILITYUSED_PREFIX = "SERVER: Ability ";

        /// <summary>
        /// String that is immediately followed by the name of a player who has
        /// used an ability.
        /// </summary>
        private const string LOGLINE_ABILITYUSED_INFIX = "used by ";

        /// <summary>
        /// String that is contained by log lines indicating the total number of
        /// actions of a player, only.
        /// </summary>
        private const string LOGLINE_ACTIONS = "SERVER: Actions ";
        #endregion

        #region Fields
        /// <summary>
        /// The controller to be notified whenever any parse errors occur.
        /// </summary>
        private Controller controller;

        /// <summary>
        /// The list of valid squad member class names.
        /// </summary>
        private List<string> squadMemberClasses;

        /// <summary>
        /// The list of valid ability names.
        /// </summary>
        private List<string> abilities;
        #endregion

        #region Constructors
        /// <summary>
        /// Constructs a new parser for extracting detailed information from
        /// Hostile Worlds log files, loading the list of valid squad member
        /// class names and valid ability names.
        /// </summary>
        /// <param name="controller">
        /// the controller to be notified whenever any parse errors occur
        /// </param>
        public HostileWorldsLogParser(Controller controller)
        {
            this.controller = controller;

            AddSquadMemberNames();
            AddAbilityNames();
        }

        /// <summary>
        /// Fills the list of valid squad member class names.
        /// </summary>
        private void AddSquadMemberNames()
        {
            squadMemberClasses = new List<string>();

            squadMemberClasses.Add("Rusher");
            squadMemberClasses.Add("Engineer");
            squadMemberClasses.Add("Hunter");
        }

        /// <summary>
        /// Fills the list of valid ability names.
        /// </summary>
        private void AddAbilityNames()
        {
            abilities = new List<string>();

            // tactical abiltities
            abilities.Add("Cloak");
            abilities.Add("Air Strike");
            abilities.Add("Scan");

            // Rusher abilites
            abilities.Add("Charge");
            abilities.Add("Concussion Grenade");
            abilities.Add("Target Engines");
            abilities.Add("Focus Fire");

            // Engineer abilities
            abilities.Add("Recharge");
            abilities.Add("Call Artillery");
            abilities.Add("EMP Mine");

            // Hunter abilities
            abilities.Add("Aimed Shot");
            abilities.Add("EMP Grenade");
            abilities.Add("Expose Weakness");
            abilities.Add("Call Scoutdrone");
        }
        #endregion

        #region Methods
        /// <summary>
        /// Parses all Hostile Worlds match logs from the passed stream.
        /// </summary>
        /// <param name="stream">
        /// to stream to parse the match logs from
        /// </param>
        /// <returns>
        /// a list of all valid Hostile Worlds match logs found
        /// </returns>
        public List<HostileWorldsLog> ParseLogFromStream(Stream stream)
        {
            // prepare new list of logs for all matches in the passed log file
            List<HostileWorldsLog> hwlogs = new List<HostileWorldsLog>();
            HostileWorldsLog hwlog = null;

            // initialize stream reader
            StreamReader sr = new StreamReader(stream);

            string logLine;
            int index;

            string dateTime = "";
            string version = "";

            // read entire log file
            while ((logLine = sr.ReadLine()) != null)
            {
                if ((index = logLine.LastIndexOf(LOGLINE_DATETIME)) > 0)
                {
                    // parse date and time
                    dateTime = logLine.Substring(index + LOGLINE_DATETIME.Length);
                }
                else if ((index = logLine.LastIndexOf(LOGLINE_VERSION)) > 0)
                {
                    // parse Hostile Worlds version
                    version = logLine.Substring(index + LOGLINE_VERSION.Length);
                }
                else if (logLine.Contains(LOGLINE_NEWMATCH))
                {
                    // prepare new match log
                    hwlog = new HostileWorldsLog();
                    hwlog.DateTime = dateTime;
                    hwlog.Version = version;

                    hwlogs.Add(hwlog);
                }
                else if ((index = logLine.LastIndexOf(LOGLINE_MAP)) > 0)
                {
                    // parse map name
                    hwlog.Map = logLine.Substring(index + LOGLINE_MAP.Length);
                }
                else if ((index = logLine.LastIndexOf(LOGLINE_FORMAT)) > 0)
                {
                    // parse matchup
                    hwlog.Format = logLine.Substring(index + LOGLINE_FORMAT.Length);
                }
                else if ((index = logLine.LastIndexOf(LOGLINE_PLAYER)) > 0)
                {
                    // parse player name
                    string playerName = logLine.Substring(index + LOGLINE_PLAYER.Length);
                    hwlog.Players.Add(playerName);

                    // create new table column for the ability distribution of that player
                    hwlog.AbilityDistribution.Add(playerName, new Dictionary<string, int>());

                    foreach (string abilityName in abilities)
                    {
                        hwlog.AbilityDistribution[playerName].Add(abilityName, 0);
                    }

                    // create new table column for the squad composition of that player
                    hwlog.SquadComposition.Add(playerName, new Dictionary<string, int>());

                    foreach (string squadMemberClass in squadMemberClasses)
                    {
                        hwlog.SquadComposition[playerName].Add(squadMemberClass, 0);
                    }
                }
                else if ((index = logLine.LastIndexOf(LOGLINE_MATCHTIME)) > 0)
                {
                    // parse match length
                    hwlog.MatchTime = Int32.Parse(logLine.Substring(index + LOGLINE_MATCHTIME.Length));
                }
                else if ((index = logLine.LastIndexOf(LOGLINE_WINNER)) > 0)
                {
                    // parse winner
                    hwlog.Winner = logLine.Substring(index + LOGLINE_WINNER.Length);
                }
                else if (logLine.Contains(LOGLINE_MATCHENDED))
                {
                    // remember that this match has properly finished
                    hwlog.MatchFinished = true;
                }
                else if ((index = logLine.LastIndexOf(LOGLINE_SQUADMEMBERCALLED_PREFIX)) > 0)
                {
                    // parse squad member class name
                    string squadMemberClass = logLine.Substring(index + LOGLINE_SQUADMEMBERCALLED_PREFIX.Length + 1);
                    squadMemberClass = squadMemberClass.Split(new char[] { '\"' })[0];

                    // parse player name
                    index = logLine.LastIndexOf(LOGLINE_SQUADMEMBERCALLED_INFIX);
                    string playerName = logLine.Substring(index + LOGLINE_SQUADMEMBERCALLED_INFIX.Length);

                    try
                    {
                        // update player squad member composition
                        hwlog.SquadComposition[playerName][squadMemberClass]++;
                    }
                    catch (Exception)
                    {
                        controller.ShowErrorDialog(playerName + " has called unknown squad member class " + squadMemberClass + ".");
                    }
                }
                else if ((index = logLine.LastIndexOf(LOGLINE_ABILITYUSED_PREFIX)) > 0)
                {
                    // parse ability name
                    string abilityName = logLine.Substring(index + LOGLINE_ABILITYUSED_PREFIX.Length + 1);
                    abilityName = abilityName.Split(new char[] { '\"' })[0];

                    // parse player name
                    index = logLine.LastIndexOf(LOGLINE_ABILITYUSED_INFIX);
                    string playerName = logLine.Substring(index + LOGLINE_ABILITYUSED_INFIX.Length);

                    try
                    {
                        // update player ability distribution
                        hwlog.AbilityDistribution[playerName][abilityName]++;
                    }
                    catch (Exception)
                    {
                        controller.ShowErrorDialog(playerName + " has used unknown ability " + abilityName + ".");
                    }
                }
                else if ((index = logLine.LastIndexOf(LOGLINE_ACTIONS)) > 0)
                {
                    string actionsLog = logLine.Substring(index + LOGLINE_ACTIONS.Length);
                    string[] actionsLogParts = actionsLog.Split(new char[] { ' ' });

                    // parse actions
                    string playerName = actionsLogParts[0];

                    // parse player name
                    int actions = Int32.Parse(actionsLogParts[1]);

                    hwlog.Actions[playerName] = actions;
                }
            }

            // close stream reader
            sr.Close();

            return hwlogs;
        }
        #endregion
    }
}
