using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Slenderman_Event_8 : MonoBehaviour
{
    public bool hasTrigger;

    public bool hasDisepar;

    public UnityEvent triggerEvent;

    [SerializeField]
    LayerMask armor;


    [SerializeField]
    Slender_Entity Slender_Entity;

    private void OnTriggerEnter(Collider other)
    {
        if (((1 << other.gameObject.layer) & armor) != 0 && other.CompareTag("Player") && !hasTrigger)
        {
            Slender_Entity.gameObject.SetActive(true);
            hasTrigger = true;
        }
    }

    public void TriggerEvent()
    {
        if (Slender_Entity.gameObject.activeSelf && !hasDisepar && hasTrigger)
        {
            hasDisepar = true;
            if(Slender_Entity != null)
            {
                Slender_Entity.Fading();
                Slender_Entity.DisaleObject(10);
            }
        }
    }
}
