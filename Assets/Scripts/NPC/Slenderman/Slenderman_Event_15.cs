using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Slenderman_Event_15 : MonoBehaviour
{
    public bool hasTrigger;

    public bool hasActivate;

    public UnityEvent triggerEvent;

    [SerializeField]
    Slender_Entity[] Slender_Entity;

    [SerializeField]
    LayerMask armor;

    private void OnTriggerExit(Collider other)
    {
        if (((1 << other.gameObject.layer) & armor) != 0 && other.CompareTag("Player") && !hasTrigger && hasActivate)
        {
            for (int n = 0; n < Slender_Entity.Length; n++)
            {
                Slender_Entity[n].Fading();
                Slender_Entity[n].DisaleObject(10);

            }
            hasTrigger = true;
        }
    }



    public void TriggerEvent()
    {
        hasActivate = true;
        for (int n = 0; n < Slender_Entity.Length;n++)
        {
            Slender_Entity[n].gameObject.SetActive(true);

        }
        StartCoroutine(DelayEvent());
    }

    IEnumerator DelayEvent()
    {
        yield return new WaitForSeconds(5);
        for (int n = 0; n < Slender_Entity.Length; n++)
        {
            Slender_Entity[n].SetRadius(30);
        }

    }

}
