using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Slenderman_Event_4 : MonoBehaviour
{
    public bool hasTrigger;

    public UnityEvent triggerEvent;

    [SerializeField]
    Slender_Entity Slender_Entity;

    [SerializeField]
    GameObject Beast;
    [SerializeField]
    Transform spawnLocation;

    [SerializeField]
    LayerMask armor;

    private void OnTriggerEnter(Collider other)
    {
        if (((1 << other.gameObject.layer) & armor) != 0 && other.CompareTag("Player") && !hasTrigger)
        {
            triggerEvent?.Invoke();
            hasTrigger = true;
        }
    }

    public void TriggerEvent()
    {
        if(Slender_Entity.gameObject.activeSelf && !hasTrigger)
        {
            StartCoroutine(DelayEvent());
            hasTrigger = true;
            Instantiate(Beast, spawnLocation.position, Beast.transform.rotation);
        }
    }

    IEnumerator DelayEvent()
    {
        yield return new WaitForSeconds(2);
        Slender_Entity.TriggerState("Scream");
        Slender_Entity.DisaleObject(8);
        StartCoroutine(DelayFading());
    }

    IEnumerator DelayFading()
    {
        yield return new WaitForSeconds(3);
        Slender_Entity.Fading();
    }
}
