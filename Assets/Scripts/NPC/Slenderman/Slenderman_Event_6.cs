using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Slenderman_Event_6 : MonoBehaviour
{
    public bool hasTrigger;

    public UnityEvent<Vector3> triggerEvent;

    [SerializeField]
    LayerMask armor;


    [SerializeField]
    Slender_Entity Slender_Entity;

    private void OnTriggerEnter(Collider other)
    {
        if (((1 << other.gameObject.layer) & armor) != 0 && other.CompareTag("Slender"))
        {
            Slender_Entity.Fading();
            Slender_Entity.DisaleObject(10);
        }

        if (((1 << other.gameObject.layer) & armor) != 0 && other.CompareTag("Player") && !hasTrigger)
        {
            Slender_Entity.gameObject.SetActive(true);
            Slender_Entity.FlatingDestination(transform.position);
            hasTrigger = true;
        }
    }
}
