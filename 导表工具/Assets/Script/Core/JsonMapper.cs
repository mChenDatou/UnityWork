using System.Collections.Generic;

public class JsonMapper
{
    public static IJsonDic<T> ToDictionary<T>(string text)
    {
        var re = new IJsonDic<T>();
        //这里报错, 导表是数组, 最后一组元素 括号{} 后面的逗号, 去掉
        var datas = LitJson.JsonMapper.ToObject<T[]>(text);
        foreach (var data in datas)
        {
            var info = data.GetType().GetField("id");
            var idStr = int.Parse(info.GetValue(data).ToString());
            re.Add(idStr, data);
        }
        return re;
    }
}

public class IJsonDic<T>
{
    private readonly Dictionary<int, T> _dict = new ();

    public void Add(int id, T data) => _dict.Add(id, data);

    public T this[int id] => _dict[id];

    public bool ContainsKey(int id) => _dict.ContainsKey(id);

}