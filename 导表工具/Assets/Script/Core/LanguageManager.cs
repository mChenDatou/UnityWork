using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;

public class LanguageManager : Singleton<LanguageManager>
{
    private IJsonDic<Language> _lanConfig;

    public void InitConfig()
    {
        string configPath = "Config/Language.txt";
        Addressables.LoadAssetAsync<TextAsset>(configPath).Completed += (handle) =>
        {
            _lanConfig = JsonMapper.ToDictionary<Language>(handle.Result.text);
        };
    }

    /// <summary>
    /// 获取本地化文本
    /// </summary>
    public string GetTextById(int id)
    {
        string result = "";
        if (this._lanConfig　!= null && this._lanConfig.ContainsKey(id))
        {
            switch (Application.systemLanguage)
            {
                case SystemLanguage.English:
                    result = this._lanConfig[id].en;
                    break;
                case SystemLanguage.French:
                    result = this._lanConfig[id].fr;
                    break;
                case SystemLanguage.Japanese:
                    result = this._lanConfig[id].ja;
                    break;
                case SystemLanguage.Korean:
                    result = this._lanConfig[id].kr;
                    break;
                case SystemLanguage.Portuguese:
                    result = this._lanConfig[id].pt;
                    break;
                case SystemLanguage.Russian:
                    result = this._lanConfig[id].ru;
                    break;
                case SystemLanguage.Spanish:
                    result = this._lanConfig[id].es;
                    break;
                case SystemLanguage.German:
                    result = this._lanConfig[id].de;
                    break;
                default:
                    result = this._lanConfig[id].en;
                    break;
            }
        }
        return result;
    }
    
    public string ConvertGold(float amount)
    {
        float floorGold = amount / 100f;
        string result;
        switch (Application.systemLanguage)
        {
            case SystemLanguage.English: //美国
                result = GetTextById(1000) + $"{(floorGold * 1):F2}";
                break;
            case SystemLanguage.French: //法国
                result = $"{(floorGold * 1):F2}" + GetTextById(1000);
                break;
            case SystemLanguage.Japanese: //日本
                result = GetTextById(1000) + $"{(floorGold * 140):F2}";
                break;
            case SystemLanguage.Korean: //韩国
                result = GetTextById(1000) + $"{(floorGold * 1350):F2}";
                break;
            case SystemLanguage.Portuguese: //巴西
                result = GetTextById(1000) + $"{(floorGold * 5):F2}";
                break;
            case SystemLanguage.Russian: //俄罗斯
                result = GetTextById(1000) + $"{(floorGold * 60):F2}";
                break;
            case SystemLanguage.Spanish: //西班牙
                result = $"{(floorGold * 1):F2}" + GetTextById(1000);
                break;
            case SystemLanguage.German: //德国
                result = $"{(floorGold * 1):F2}" + GetTextById(1000);
                break;
            default: //默认英语
                result = GetTextById(1000) + $"{(floorGold * 1):F2}";
                break;
        }
    
        return result;
    }
}