using System.Data;
using System.Text;

namespace CDT
{
    public static class Excel2Json
    {
        /*
        -e, –excel Required. 输入的Excel文件路径.
        -j, –json 指定输出的json文件路径.
        -p, –csharp 指定输出的C#文件路径.
        -h, –header (Default: 3)表格中有几行是表头.
        -c, –encoding (Default: utf8-nobom) 指定编码的名称.
        -l, –lowcase (Default: false) 自动把字段名称转换成小写格式.
        -a 序列化成数组
        -d, –date:指定日期格式化字符串，例如：dd / MM / yyy hh: mm:ss
        -s 序列化时强制带上sheet name，即使只有一个sheet
        -exclude_prefix： 导出时，排除掉包含指定前缀的表单和列，例如：-exclude_prefix #
        -cell_json：自动识别单元格中的Json对象和Json数组，Default：false
         */
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
