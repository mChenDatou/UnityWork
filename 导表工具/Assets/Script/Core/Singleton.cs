using System;

public abstract class Singleton<T> where T : class
{
    private static readonly T i = InitializeInstance();

    private static T InitializeInstance() => Activator.CreateInstance(typeof(T), true) as T;

    public static T I => i;
}