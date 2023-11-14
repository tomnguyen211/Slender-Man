using UnityEngine;
using UnityEngine.Events;

public class Slenderman_Event_1 : MonoBehaviour
{
    public bool hasTrigger;

    public UnityEvent triggerEvent;


    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Player") && !hasTrigger)
        {
            hasTrigger = true;
            triggerEvent?.Invoke();
        }
    }
}
