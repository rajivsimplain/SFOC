using Newtonsoft.Json;
using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Runtime.Remoting.Messaging;
using System;
using NLog;
using System.Diagnostics;
using System.Security.Policy;
using System.Threading;

namespace DexConsoleApp_3._5.net
{
    internal class Program
    {
        private static Logger logger = LogManager.GetCurrentClassLogger();
        static void Main(string[] args)
        {
            String fileRcvd = "";
            String fileName = "";
            String commId = "";

            try
            {
                logger.Info("Stub Initiated.. ");

                logger.Info("Total command arguments: {0}", args.Length);
                if (args.Length > 0)
                {
                    fileRcvd = args[0];
                    commId  = args[1];
                    fileName = Path.GetFileName(fileRcvd);
                    logger.Info("File Received: {0} / CommId: {1} / FileName: {2}",
                                     args.Length, commId, fileName);
                }
                else
                {
                    logger.Info("Missing Arguments in the command, Exiting");
                    return;
                }
                
                // Retrieve the Params
                String iniFile = AppDomain.CurrentDomain.BaseDirectory + "DexConsoleApp.ini";
                IniParser parser = new IniParser(iniFile);

                String storeNum = parser.GetSetting("appsettings", "storenum");
                String dockNum = parser.GetSetting("appsettings", "docknum");
                String destFolder = parser.GetSetting("appsettings", "dest_folder");

                logger.Info("Ini File settings => Store Num: {0}  Dock Num: {1}  Dest Folder {2}",
                             storeNum, dockNum, destFolder);

                // Move the file.
                logger.Info("Moving the file from {0} to {1}", fileRcvd, destFolder + fileName);
                File.Move(fileRcvd, destFolder + fileName);
                logger.Info("File Move Complete.");

                // Webclient code
                logger.Info("Start of EDI Integration Process");
                File.Move(fileRcvd, destFolder + fileName);
                logger.Info("End of Integration Process");

                /*
                User user = new User();
                using (WebClient webClient = new WebClient())
                {
                    webClient.BaseAddress = "https://jsonplaceholder.typicode.com";
                    var url = "/posts";
                    webClient.Headers.Add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)");
                    webClient.Headers[HttpRequestHeader.ContentType] = "application/json";
                    string data = JsonConvert.SerializeObject(user);
                    var response = webClient.UploadString(url, data);
                    var result = JsonConvert.DeserializeObject<object>(response);
                    //System.Console.WriteLine(result);
                    //logger.Debug(result);
                    logger.Info(result);
                    //Console.ReadLine();
                }
                */

                // Async Calls
                {
                    /*    
                        Console.WriteLine("Main thread started.");

                        // Create a list of tasks to be executed asynchronously
                        var tasks = new[]
                        {
                            new WaitCallback(DoWork),
                            new WaitCallback(DoWork),
                            new WaitCallback(DoWork)
                        };

                        // Queue the tasks to the thread pool
                        foreach (var task in tasks)
                        {
                            ThreadPool.QueueUserWorkItem(task, "Task");
                        }

                        // Main thread continues while tasks are executed asynchronously
                        Console.WriteLine("Main thread doing other work.");

                        // Wait for all tasks to complete
                        Thread.Sleep(1000); // Simulate other work
                        Console.WriteLine("Main thread finished.");
                        Console.WriteLine("Press any key to exit...");
                        Console.ReadKey();
                    */

                }
            }
            catch (Exception ex)
            {
                logger.Error(ex, "An error occurred");
                throw ex;
            }
            finally
            {
                logger.Info("Stub Execution end.. ");
            }
            
        }

        static void DoWork(object state)
        {
            string taskName = (string)state;
            Console.WriteLine($"{taskName} started.");
            Thread.Sleep(10000);
            Console.WriteLine($"{taskName} finished.");
        }

        class User
        {
            public int id { get; set; } = 1;
            public string title { get; set; } = "First Data";
            public string body { get; set; } = "First Body";
            public int userId { get; set; } = 222;
        }
    }
}