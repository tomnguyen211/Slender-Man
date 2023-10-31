using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

[System.Serializable]
public class TypedEvent : UnityEvent<object> { }

[System.Serializable]
public class DoubleTypedEvent : UnityEvent<object, object> { }

public class EventManager : MonoBehaviour
{
    private Dictionary<string, UnityEvent> eventDictionary;
    private Dictionary<string, TypedEvent> typedEventDictionary;
    private Dictionary<string, DoubleTypedEvent> doubleTypedEventDictionary;

    private static EventManager eventManager;

    public static EventManager Instance
    {
        get
        {
            if (!eventManager)
            {
                eventManager = FindObjectOfType(typeof(EventManager)) as EventManager;

                if (!eventManager)
                {
                    Debug.LogError("There needs to be one active EventManger script on a GameObject in your scene.");
                }
                else
                {
                    eventManager.Init();
                }
            }

            return eventManager;
        }
    }

    void Init()
    {
        if (eventDictionary == null)
        {
            eventDictionary = new Dictionary<string, UnityEvent>();
            typedEventDictionary = new Dictionary<string, TypedEvent>();
            doubleTypedEventDictionary = new Dictionary<string, DoubleTypedEvent> { };
        }
    }

    public static void StartListening(string eventName, UnityAction listener)
    {
        UnityEvent thisEvent = null;
        if (Instance.eventDictionary.TryGetValue(eventName, out thisEvent))
        {
            thisEvent.AddListener(listener);
        }
        else
        {
            thisEvent = new UnityEvent();
            thisEvent.AddListener(listener);
            Instance.eventDictionary.Add(eventName, thisEvent);
        }
    }

    public static void StopListening(string eventName, UnityAction listener)
    {
        if (eventManager == null) return;
        UnityEvent thisEvent = null;
        if (Instance.eventDictionary.TryGetValue(eventName, out thisEvent))
        {
            thisEvent.RemoveListener(listener);
        }
    }

    public static void TriggerEvent(string eventName)
    {
        UnityEvent thisEvent = null;
        if (Instance.eventDictionary.TryGetValue(eventName, out thisEvent))
        {
            thisEvent.Invoke();
        }
    }



    public static void StartListening(string eventName, UnityAction<object> listener)
    {
        TypedEvent thisEvent = null;
        if (Instance.typedEventDictionary.TryGetValue(eventName, out thisEvent))
        {
            thisEvent.AddListener(listener);
        }
        else
        {
            thisEvent = new TypedEvent();
            thisEvent.AddListener(listener);
            Instance.typedEventDictionary.Add(eventName, thisEvent);
        }
    }

    public static void StopListening(string eventName, UnityAction<object> listener)
    {
        if (eventManager == null) return;
        TypedEvent thisEvent = null;
        if (Instance.typedEventDictionary.TryGetValue(eventName, out thisEvent))
        {
            thisEvent.RemoveListener(listener);
        }
    }

    public static void TriggerEvent(string eventName, object data)
    {
        TypedEvent thisEvent = null;
        if (Instance.typedEventDictionary.TryGetValue(eventName, out thisEvent))
        {
            thisEvent.Invoke(data);
        }
    }

    public static void StartListening(string eventName, UnityAction<object, object> listener)
    {
        DoubleTypedEvent thisEvent = null;
        if (Instance.doubleTypedEventDictionary.TryGetValue(eventName, out thisEvent))
        {
            thisEvent.AddListener(listener);
        }
        else
        {
            thisEvent = new DoubleTypedEvent();
            thisEvent.AddListener(listener);
            Instance.doubleTypedEventDictionary.Add(eventName, thisEvent);
        }
    }

    public static void StopListening(string eventName, UnityAction<object, object> listener)
    {
        if (eventManager == null) return;
        DoubleTypedEvent thisEvent = null;
        if (Instance.doubleTypedEventDictionary.TryGetValue(eventName, out thisEvent))
        {
            thisEvent.RemoveListener(listener);
        }
    }

    public static void TriggerEvent(string eventName, object data1, object data2)
    {
        DoubleTypedEvent thisEvent = null;
        if (Instance.doubleTypedEventDictionary.TryGetValue(eventName, out thisEvent))
        {
            thisEvent.Invoke(data1, data2);
        }
    }
}

