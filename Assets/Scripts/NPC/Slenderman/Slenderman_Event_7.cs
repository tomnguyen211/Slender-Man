using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Slenderman_Event_7 : MonoBehaviour
{
    public bool hasTrigger;

    [SerializeField]
    Slender_Entity Slender_Entity;
    public void TriggerEvent()
    {
        if(!hasTrigger)
        {
            StartCoroutine(TimerDisapear());
            hasTrigger = true;
        }
    }

    IEnumerator TimerDisapear()
    {
        yield return new WaitForSeconds(20);
        if(Slender_Entity != null)
        {
            Slender_Entity.Fading();
            Slender_Entity.DisaleObject(10);
        }
    }
}
