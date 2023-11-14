using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Slenderman_Event_3 : MonoBehaviour
{
    public bool hasTrigger;

    public UnityEvent triggerEvent;

    [SerializeField]
    Slender_Entity Slender_Entity;

    [SerializeField]
    LayerMask armor;

    private void OnTriggerEnter(Collider other)
    {
        if (((1 << other.gameObject.layer) & armor) != 0 && other.CompareTag("Player"))
        {
            triggerEvent?.Invoke();
            Slender_Entity.Fading();
            Slender_Entity.DisaleObject(5);
            gameObject.SetActive(false);
        }
    }   
}
