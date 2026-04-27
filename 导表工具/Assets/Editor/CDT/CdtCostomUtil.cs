using System.IO;
using UnityEditor;
using UnityEngine;

namespace CDT
{
    /// <summary>
    /// GameFrame框架工具菜单
    /// </summary>
    public class MyMenuItems
    {
        [MenuItem("★工具★/导表/一键导表", false, 2)]
        public static void AutoExcel2Json()
        {
            try
            {
                string projectPath = Directory.GetParent(Application.dataPath).FullName;
                string exePath = $"{projectPath}/excel2json/excel2json.exe";
                string configPath = $"{projectPath}/Assets/Config/";
                string csPath = $"{projectPath}/Assets/Script/Config/";
                configPath = configPath.Replace('/', Path.DirectorySeparatorChar);
                csPath = csPath.Replace('/', Path.DirectorySeparatorChar);
                exePath = exePath.Replace('/', Path.DirectorySeparatorChar);
                
                string[] excelFiles = Directory.GetFiles($"{projectPath}/Excel", "*.xlsx");
                foreach (var excel in excelFiles)
                {
                    string fileName = Path.GetFileNameWithoutExtension(excel);
                    string cmdStr = $" -e {excel} -j {configPath}{fileName}.txt -p {csPath}{fileName}.cs -h 3 -a true";
                    Debug.Log(cmdStr);
                    System.Diagnostics.Process.Start(exePath, @cmdStr);
                }
            }
            catch (System.Exception ex)
            {
                Debug.LogError(ex.Message);
                throw;
            }
            AssetDatabase.Refresh();
            Debug.Log("导出配置完成");
        }
        


    }

}