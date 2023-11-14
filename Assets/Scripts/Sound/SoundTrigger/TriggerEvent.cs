using System.Collections;
using UnityEngine;
using UnityEngine.Events;

public class TriggerEvent : MonoBehaviour
{
    [SerializeField]
    bool hasTrigger;

    public UnityEvent eventTrigger;

    [SerializeField]
    float pauseTime;

    public void Trigger_Event()
    {
        if(!hasTrigger) 
        {
            if(pauseTime > 0)
                StartCoroutine(DelayTrigger());
            else
                eventTrigger?.Invoke();
            hasTrigger = true;
        }
    }

    IEnumerator DelayTrigger()
    {
        yield return new WaitForSeconds(pauseTime);
        eventTrigger?.Invoke();

    }
}
