using System.Data;
using System.Text;

namespace CDT
{
    public static class Excel2Json
    {
        public static void Run(string excelPath, string exportJsonPath, string exportCsharpPath, int header = 3, string encoding = "\"utf8-nobom\"", string dateFormat = "\"yyyy-MM-dd\"", bool lowcase = false, bool exportArray = true, bool forceSheetName = false, string excludePrefix = "", bool cellJson = true, bool allString = false)
        {
            //-- Encoding
            Encoding cd = new UTF8Encoding(false);
            if (encoding != "utf8-nobom")
            {
                foreach (EncodingInfo ei in Encoding.GetEncodings())
                {
                    Encoding e = ei.GetEncoding();
                    if (e.HeaderName == encoding)
                    {
                        cd = e;
                        break;
                    }
                }
            }

            //-- Load Excel
            ExcelLoader excel = new ExcelLoader(excelPath, header);

            for (int i = 0; i < excel.Sheets.Count; i++)
            {
                DataTable sheet = excel.Sheets[i];

                //-- export
                JsonExporter exporter = new JsonExporter(sheet, lowcase, exportArray, dateFormat, forceSheetName, header, excludePrefix, cellJson, allString);
                exporter.SaveToFile(exportJsonPath + sheet.TableName + ".txt", cd);
            }

            //-- 生成C#定义文件
            if (exportCsharpPath != null && exportCsharpPath.Length > 0)
            {
                for (int i = 0; i < excel.Sheets.Count; i++)
                {
                    DataTable sheet = excel.Sheets[i];
                    CSDefineGenerator generator = new CSDefineGenerator(sheet, excludePrefix);
                    generator.SaveToFile(exportCsharpPath + sheet.TableName + ".cs", cd);
                }
            }
        }
    }
}
