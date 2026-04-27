using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        int x = 5; // 二进制表示为 00000101
        int y = 3; // 二进制表示为 00000011
        int result1 = x & y; // 按位与运算，结果为 00000001，十进制为1
        int result2 = x | y; // 按位或运算，结果为 00000111，十进制为7
        int result3 = x ^ y; // 按位异或运算，结果为 00000110，十进制为6
        Debug.Log("按位与运算结果: " + result1); // 输出: 按位与运算结果: 1
        Debug.Log("按位或运算结果: " + result2); // 输出: 按位或运算结果: 7
        Debug.Log("按位异或运算结果: " + result3); // 输出: 按位异或运算结果:
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
