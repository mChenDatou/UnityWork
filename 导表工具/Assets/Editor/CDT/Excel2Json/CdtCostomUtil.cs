using System.IO;
using UnityEditor;
using UnityEngine;

namespace CDT
{
    /// <summary>
    /// GameFrame框架工具菜单
    /// </summary>
    public partial class MyMenuItems
    {
        [MenuItem("★工具★/导表/一键导表", false, 2)]
        public static void AutoExcel2Json()
        {
            try
            {
                string projectPath = Directory.GetParent(Application.dataPath).FullName;
                string configPath = $"{projectPath}/Assets/Config/";
                string csPath = $"{projectPath}/Assets/Scripts/Config/";
                
                configPath = configPath.Replace('/', Path.DirectorySeparatorChar);
                csPath = csPath.Replace('/', Path.DirectorySeparatorChar);
                
                // 删除csPath路径下的所有文件
                if (Directory.Exists(csPath))
                {
                    string[] csFiles = Directory.GetFiles(csPath);
                    foreach (var csFile in csFiles)
                    {
                        if (Path.GetExtension(csFile).ToLower() == ".meta")
                        {
                            continue;
                        }
                        File.Delete(csFile);
                    }
                    //Debug.Log($"已清空目录: {csPath}");
                }
                
                // 删除configPath路径下的所有文件
                if (Directory.Exists(configPath))
                {
                    string[] cfFiles = Directory.GetFiles(configPath);
                    foreach (var csFile in cfFiles)
                    {
                        if (Path.GetExtension(csFile).ToLower() == ".meta")
                        {
                            continue;
                        }
                        File.Delete(csFile);
                    }
                    //Debug.Log($"已清空目录: {configPath}");
                }
                string[] excelFiles = Directory.GetFiles($"{projectPath}/Excel", "*.xlsx");
                foreach (var excel in excelFiles)
                {
                    Excel2Json.Run(excel, configPath, csPath);
                }
                Debug.Log("导出配置完成");
            }
            catch (System.Exception ex)
            {
                Debug.LogError(ex.Message);
                throw;
            }
            AssetDatabase.Refresh();
        }


    }

}