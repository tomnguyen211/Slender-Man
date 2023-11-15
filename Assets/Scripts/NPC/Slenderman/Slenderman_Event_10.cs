using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Slenderman_Event_10 : MonoBehaviour
{
    public bool hasTrigger;

    public bool hasDisepar;

    public UnityEvent triggerEvent;

    [SerializeField]
    ReflectionProbe probe;

    [SerializeField]
    LayerMask armor;

    [SerializeField]
    Slender_Entity Slender_Entity;

    private void OnTriggerEnter(Collider other)
    {
        if (((1 << other.gameObject.layer) & armor) != 0 && other.CompareTag("Player") && !hasTrigger)
        {
            Slender_Entity.gameObject.SetActive(false);
            hasTrigger = true;
            StartCoroutine(ResetEmpty());
            EventManager.TriggerEvent("JumpScareSound");
        }
    }

    IEnumerator ResetEmpty()
    {
        yield return new WaitForSeconds(5);
        probe.RenderProbe();


    }
}
