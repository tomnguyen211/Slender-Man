using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Slenderman_Event_12 : MonoBehaviour
{
    public bool hasTrigger;

    public bool hasActivate;


    public UnityEvent triggerEvent;

    [SerializeField]
    Slender_Entity Slender_Entity;

    public void DisalbeSlender()
    {
        if(!hasTrigger && hasActivate)
        {
            Slender_Entity.gameObject.SetActive(false);
            hasTrigger = true;

        }
    }

    public void Activate() => hasActivate = true;
}
