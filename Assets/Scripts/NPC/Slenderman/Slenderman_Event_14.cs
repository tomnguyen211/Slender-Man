using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Slenderman_Event_14 : MonoBehaviour
{
    public bool hasTrigger;

    public bool hasActivate;

    public UnityEvent triggerEvent;

    [SerializeField]
    Slender_Entity Slender_Entity;

    [SerializeField]
    GameObject Vendigo;
    [SerializeField]
    Transform spawnLocation;

    [SerializeField]
    LayerMask armor;

    private void OnTriggerEnter(Collider other)
    {
        if (((1 << other.gameObject.layer) & armor) != 0 && other.CompareTag("Player") && !hasTrigger && hasActivate)
        {
            triggerEvent?.Invoke();
            hasTrigger = true;
            StartCoroutine(DelayEvent());
        }
    }

    public void TriggerEvent()
    {
        Slender_Entity.gameObject.SetActive(true);
        Instantiate(Vendigo, spawnLocation.position, Vendigo.transform.rotation);
    }

    IEnumerator DelayEvent()
    {
        yield return new WaitForSeconds(2);
        Slender_Entity.TriggerState("Scream");
    }

    public void Activate() => hasActivate = true;
}
