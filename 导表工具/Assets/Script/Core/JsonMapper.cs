using System.Collections.Generic;
using UnityEngine;

public class JsonMapper
{
    [System.Serializable]
    private class Wrapper<T>
    {
        public T[] array;
    }
    
    public static T[] ToArray<T>(string text)
    {
        var newJson = "{ \"array\": " + text + "}";
        var wrapper = JsonUtility.FromJson<Wrapper<T>>(newJson);
        return wrapper.array;
    }

    public static IJsonDic<T> ToDictionary<T>(string text)
    {
        var re = new IJsonDic<T>();
        //这里报错, 导表是数组, 最后一组元素 括号{} 后面的逗号, 去掉
        var datas = ToArray<T>(text);
        foreach (var data in datas)
        {
            var info = data.GetType().GetField("id");
            var idStr = (int)info.GetValue(data);
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