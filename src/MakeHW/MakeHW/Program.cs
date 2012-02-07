using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO;
using System.Diagnostics;

namespace MakeHW
{
    /// <remarks>
    /// MakeHW allows the automatic building of a new Hostile Worlds version,
    /// including the automatic increase of the current version number on
    /// UnrealScript code level, enabling mouse scrolling, recompiling,
    /// cooking and packaging the game, and finally renaming the resulting
    /// setup executable.
    /// </remarks>
    class Program
    {
        #region Constants: Version Information
        /// <summary>
        /// The current version number of the MakeHW tool.
        /// </summary>
        private const string MAKEHW_VERSION           = "1.0 (March 12, 2011)";

        /// <summary>
        /// The underline of the version number in the console.
        /// </summary>
        private const string MAKEHW_VERSION_UNDERLINE = "====================";
        #endregion

        #region Constants: Hostile Worlds Game Class
        /// <summary>
        /// The relative path from the UDK Binaries directory to the Hostile Worlds game class file.
        /// </summary>
        private const string RELATIVE_PATH_TO_HWGAME_CLASS = @"..\Development\Src\HostileWorlds\Classes\";

        /// <summary>
        /// The file name of the class file containing the Hostile Worlds version definition.
        /// </summary>
        private const string HWGAME_CLASS_FILENAME = "HWGame.uc";

        /// <summary>
        /// The name of the file to backup the game class file to.
        /// </summary>
        private const string HWGAME_CLASS_BACKUP_FILENAME = "HWGame.bak";

        /// <summary>
        /// The beginning of the code line denoting the Hostile Worlds version definition.
        /// </summary>
        private const string HWGAME_CLASS_VERSION_DEFINITION = "const VERSION = ";
        #endregion

        #region Constants: Hostile Worlds Config File
        /// <summary>
        /// The relative path from the UDK Binaries directory to the Hostile Worlds config file.
        /// </summary>
        private const string RELATIVE_PATH_TO_CONFIG_FILE = @"..\UDKGame\Config\";

        /// <summary>
        /// The file name of the config file containing the mouse scrolling settings.
        /// </summary>
        private const string HWCONFIG_FILENAME = "UDKHostileWorlds.ini";

        /// <summary>
        /// The name of the file to backup the config file to.
        /// </summary>
        private const string HWCONFIG_BACKUP_FILENAME = "UDKHostileWorlds.bak";

        /// <summary>
        /// The beginning of the line denoting the mouse scrolling setting.
        /// </summary>
        private const string HWCONFIG_MOUSESCROLL_DEFINITION = "bMouseScrollEnabled=";
        #endregion

        #region Constants: Building and Cooking
        /// <summary>
        /// The file name of the main UDK executable.
        /// </summary>
        private const string UDK_EXECUTABLE_FILENAME = "UDK.exe";

        /// <summary>
        /// The argument string to pass to the UDK executable in order to perform a full recompile.
        /// </summary>
        private const string COMMANDLET_ARGUMENTS_FULL_RECOMPILE = "make -full";

        /// <summary>
        /// The first half of the argument string to pass to the UDK executable in order to perform cooking.
        /// </summary>
        private const string COMMANDLET_ARGUMENTS_COOK_1 = "CookPackages -platform=PC";

        /// <summary>
        /// The name of the map to release.
        /// </summary>
        private const string MAP_FILENAME = "HW-FrontEnd HW-Prototype HW-Desert.udk HW-Ruins.udk";

        /// <summary>
        /// The second half of the argument string to pass to the UDK executable in order to perform cooking.
        /// </summary>
        private const string COMMANDLET_ARGUMENTS_COOK_2 = "-languageforcooking=INT -noloccooking";
        #endregion

        #region Constants: Packaging
        /// <summary>
        /// The file name of the UnSetup executable.
        /// </summary>
        private const string UDKSETUP_EXECUTABLE_FILENAME = @"Binaries\UnSetup.exe";

        /// <summary>
        /// The argument to pass to the UnSetup executable in order to prepare the game setup specification XML file.
        /// </summary>
        private const string COMMANDLET_ARGUMENTS_SETUP = "/GameSetup";

        /// <summary>
        /// The argument to pass to the UnSetup executable in order to create the game manifest.
        /// </summary>
        private const string COMMANDLET_ARGUMENTS_CREATE_MANIFEST = "-GameCreateManifest";

        /// <summary>
        /// The argument to pass to the UnSetup executable in order to build the game installer.
        /// </summary>
        private const string COMMANDLET_ARGUMENTS_BUILD_INSTALLER = "-BuildGameInstaller";

        /// <summary>
        /// The argument to pass to the UnSetup executable in order to package the game.
        /// </summary>
        private const string COMMANDLET_ARGUMENTS_PACKAGE = "-Package";
        #endregion

        #region Constants: Hostile Worlds Setup Executable
        /// <summary>
        /// The prefix of the filename that is generated by the UnSetup executable.
        /// </summary>
        private const string GENERATED_SETUP_EXECUTABLE_FILENAME_PREFIX = ".\\UDKInstall";

        /// <summary>
        /// The prefix of the file name of the final Hostile Worlds Setup executable.
        /// </summary>
        private const string FINAL_SETUP_EXECUTABLE_FILENAME = "HWSetup";
        #endregion


        #region Variables
        /// <summary>
        /// The current Hostile Worlds version number.
        /// </summary>
        private static string hwVersion;
        #endregion


        #region Methods
        /// <summary>
        /// The main entry point of the application.
        /// </summary>
        /// <param name="args">ignored</param>
        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine();
                Console.WriteLine("MakeHW Version " + MAKEHW_VERSION);
                Console.WriteLine("===============" + MAKEHW_VERSION_UNDERLINE);
                Console.WriteLine();

                IncreaseVersionNumber();

                Console.WriteLine();

                EnableMouseScrolling();

                Console.WriteLine();

                PerformFullRecompile();

                Console.WriteLine();

                Cook();

                Console.WriteLine();

                // change working directory for UnSetup
                Environment.CurrentDirectory += "\\..\\";
                Console.WriteLine("Changed working directory to " + Environment.CurrentDirectory  + ".");
                
                Console.WriteLine();

                PackageGame();

                Console.WriteLine();

                RenameSetupExecutable();

                Exit(1);
            }
            catch (Exception e)
            {
                Console.WriteLine();
                Console.WriteLine();
                Console.WriteLine("An error has occured:");
                Console.WriteLine();
                Console.WriteLine(e.ToString());
            }
        }

        /// <summary>
        /// Looks for the Hostile Worlds main game class file and increases its
        /// current version number in code, backing up the old class file.
        /// </summary>
        private static void IncreaseVersionNumber()
        {
            StreamReader sr;
            StreamWriter sw;

            string line;
            string[] parsedLine;

            string hwVersionOld;

            Console.WriteLine("1. Increasing Version Number...");
            Console.WriteLine("-------------------------------");

            // find and backup the Hostile Worlds main game class
            FindAndBackupFile(RELATIVE_PATH_TO_HWGAME_CLASS, HWGAME_CLASS_FILENAME, HWGAME_CLASS_BACKUP_FILENAME, out sr, out sw);

            // increase version number within the code of the main game class file
            while ((line = sr.ReadLine()) != null)
            {
                if (line.StartsWith(HWGAME_CLASS_VERSION_DEFINITION))
                {
                    // found version definition - split it
                    parsedLine = line.Split(new char[] { '=' });
                    parsedLine = parsedLine[1].Split(new char[] { '"' });

                    // remember old version number
                    hwVersionOld = parsedLine[1];

                    parsedLine = hwVersionOld.Split(new char[] { '.' });

                    // construct and write new one
                    hwVersion = parsedLine[0] + "." + parsedLine[1] + "." + (Int32.Parse(parsedLine[2]) + 1);

                    sw.WriteLine(HWGAME_CLASS_VERSION_DEFINITION + "\"" + hwVersion + "\";");

                    Console.WriteLine("Increased version number from " + hwVersionOld + " to " + hwVersion + ".");
                }
                else
                {
                    // just copy all other parts of the file
                    sw.WriteLine(line);
                }
            }

            sr.Close();
            sw.Close();
        }

        /// <summary>
        /// Looks for the Hostile Worlds config file and enables mouse
        /// scrolling there, backing up the old config file.
        /// </summary>
        private static void EnableMouseScrolling()
        {
            StreamReader sr;
            StreamWriter sw;

            string line;
            string[] parsedLine;

            Console.WriteLine("2. Enabling Mouse Scrolling...");
            Console.WriteLine("------------------------------");

            // find and backup the Hostile Worlds config file
            FindAndBackupFile(RELATIVE_PATH_TO_CONFIG_FILE, HWCONFIG_FILENAME, HWCONFIG_BACKUP_FILENAME, out sr, out sw);

            // enable mouse scrolling within the config file
            while ((line = sr.ReadLine()) != null)
            {
                if (line.StartsWith(HWCONFIG_MOUSESCROLL_DEFINITION))
                {
                    // found mouse scrolling definition - split it
                    parsedLine = line.Split(new char[] { '=' });

                    // write new one
                    sw.WriteLine(HWCONFIG_MOUSESCROLL_DEFINITION + "true");

                    Console.WriteLine("Enabled mouse scrolling.");
                }
                else
                {
                    // just copy all other parts of the file
                    sw.WriteLine(line);
                }
            }

            sr.Close();
            sw.Close();
        }

        /// <summary>
        /// Runs the UDK main executable to perform a full recompile of all
        /// UnrealScript files.
        /// </summary>
        private static void PerformFullRecompile()
        {
            Console.WriteLine("3. Performing Full Recompile...");
            Console.WriteLine("-------------------------------");

            StartProcessWithArguments(UDK_EXECUTABLE_FILENAME, COMMANDLET_ARGUMENTS_FULL_RECOMPILE);
        }

        /// <summary>
        /// Runs the UDK main executable to cook all Unreal packages.
        /// </summary>
        private static void Cook()
        {
            Console.WriteLine("4. Cooking...");
            Console.WriteLine("-------------");

            StartProcessWithArguments(UDK_EXECUTABLE_FILENAME, COMMANDLET_ARGUMENTS_COOK_1 + " " + MAP_FILENAME + " " + COMMANDLET_ARGUMENTS_COOK_2);
        }

        /// <summary>
        /// Runs the UnSetup executable to package a new Hostile Worlds setup
        /// file.
        /// </summary>
        private static void PackageGame()
        {
            Console.WriteLine("5. Preparing Game Setup Specification...");
            Console.WriteLine("----------------------------------------");

            // prepare XML file
            StartProcessWithArguments(UDKSETUP_EXECUTABLE_FILENAME, COMMANDLET_ARGUMENTS_SETUP);

            Console.WriteLine();

            Console.WriteLine("6. Creating Manifest...");
            Console.WriteLine("-----------------------");

            // create manifest
            StartProcessWithArguments(UDKSETUP_EXECUTABLE_FILENAME, COMMANDLET_ARGUMENTS_CREATE_MANIFEST);

            Console.WriteLine();

            Console.WriteLine("7. Building Game Installer...");
            Console.WriteLine("-----------------------------");

            // build game installer
            StartProcessWithArguments(UDKSETUP_EXECUTABLE_FILENAME, COMMANDLET_ARGUMENTS_BUILD_INSTALLER);

            Console.WriteLine();

            Console.WriteLine("8. Packaging...");
            Console.WriteLine("---------------");

            // package game
            StartProcessWithArguments(UDKSETUP_EXECUTABLE_FILENAME, COMMANDLET_ARGUMENTS_PACKAGE);
        }

        /// <summary>
        /// Looks for the generated Hostile Worlds setup file and renames it.
        /// </summary>
        private static void RenameSetupExecutable()
        {
            Console.WriteLine("9. Renaming...");
            Console.WriteLine("--------------");

            // try to find the generated setup file
            string[] fileNames = Directory.GetFiles(".", "*.exe");

            foreach (string fileName in fileNames)
            {
                if (fileName.StartsWith(GENERATED_SETUP_EXECUTABLE_FILENAME_PREFIX))
                {
                    // found setup file - rename it
                    string newFileName = FINAL_SETUP_EXECUTABLE_FILENAME + hwVersion + ".exe";

                    File.Move(fileName, newFileName);
                    Console.WriteLine("Renamed " + fileName + " to " + newFileName + ".");
                    return;
                }
            }

            Console.WriteLine("Unable to find generated UDK install package.");
        }
        #endregion

        #region Methods: Utility
        /// <summary>
        /// Tries to find the specified file at the given path relative to the
        /// current working directory of this application. Removes any old
        /// backup files and creates a new one. Finally returns a stream to
        /// read from the backup file and to write to a new one.
        /// 
        /// Terminates this application if unable to find the specified file.
        /// </summary>
        /// <param name="RelativePathToFile">
        /// The path to the file to re-write, relative to the current working
        /// directory of this application.
        /// </param>
        /// <param name="Filename">
        /// The name of the file to re-write.
        /// </param>
        /// <param name="BackupFilename">
        /// The name of the file to backup the specified file to.
        /// </param>
        /// <param name="sr">
        /// A stream to read from the backup file.
        /// </param>
        /// <param name="sw">
        /// A stream to write to the new file.
        /// </param>
        private static void FindAndBackupFile(string RelativePathToFile, string Filename, string BackupFilename, out StreamReader sr, out StreamWriter sw)
        {
            // check if we can find the specified file
            if (File.Exists(RelativePathToFile + Filename))
            {
                Console.WriteLine("Found " + Filename + ".");
            }
            else
            {
                Console.WriteLine("Could not find " + Filename + ". Please run MakeHW from the Binaries directory of your UDK installation.");
                Exit(1);
            }

            // delete old backup file
            if (File.Exists(RelativePathToFile + BackupFilename))
            {
                File.Delete(RelativePathToFile + BackupFilename);
            }

            // backup file
            File.Move(RelativePathToFile + Filename, RelativePathToFile + BackupFilename);
            Console.WriteLine("Renamed " + Filename + " to " + BackupFilename + ".");

            // open streams for re-writing the specified file
            sr = File.OpenText(RelativePathToFile + BackupFilename);
            sw = new StreamWriter(RelativePathToFile + Filename);
        }

        /// <summary>
        /// Runs the specified program with the passed argument string within
        /// the current working directory of this application.
        /// 
        /// Terminates this application the program returns with a non-zero
        /// error code.
        /// </summary>
        /// <param name="FileName">
        /// The program to run.
        /// </param>
        /// <param name="Arguments">
        /// The arguments to pass to the program.
        /// </param>
        private static void StartProcessWithArguments(string FileName, string Arguments)
        {
            StartProcessWithArguments(FileName, Arguments, null);
        }

        /// <summary>
        /// Runs the specified program with the passed argument string within
        /// the given working directory.
        /// 
        /// Terminates this application the program returns with a non-zero
        /// error code.
        /// </summary>
        /// <param name="FileName">
        /// The program to run.
        /// </param>
        /// <param name="Arguments">
        /// The arguments to pass to the program.
        /// </param>
        /// <param name="WorkingDirectory">
        /// The working directory to run the program in.
        /// </param>
        private static void StartProcessWithArguments(string FileName, string Arguments, string WorkingDirectory)
        {
            // construct and prepare information for the process to start
            ProcessStartInfo psi = new ProcessStartInfo(FileName);

            psi.Arguments = Arguments;
            psi.CreateNoWindow = false;
            psi.ErrorDialog = true;

            if (WorkingDirectory != null)
            {
                psi.WorkingDirectory = WorkingDirectory;
            }

            // start the process and wait for it to finish
            Process process = Process.Start(psi);
            process.WaitForExit();

            Console.WriteLine();
            Console.WriteLine("\"" + FileName + " " + psi.Arguments + "\" exited with code " + process.ExitCode + ".");

            if (process.ExitCode != 0)
            {
                Console.WriteLine("Please fix all errors and try again.");

                process.Close();

                Exit(1);
                
            }

            process.Close();
        }

        /// <summary>
        /// Gives the user the opportunity to see all log output and exits the
        /// application with the specified code.
        /// </summary>
        /// <param name="ExitCode">
        /// The code to exit the application with.
        /// </param>
        private static void Exit(int ExitCode)
        {
            Console.WriteLine();
            Console.WriteLine("Press any key to finish.");
            Console.ReadKey();

            Environment.Exit(ExitCode);
        }
        #endregion
    }
}
