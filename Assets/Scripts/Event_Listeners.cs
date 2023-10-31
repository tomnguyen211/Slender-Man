using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Event_Listeners : MonoBehaviour
{
    private void OnEnable()
    {
        //EventManager.StartListening("TriggerBurn", TriggerBurn);

    }

    private void OnDisable()
    {
        //EventManager.StopListening("TriggerBurn", TriggerBurn);
    }


    private void CollectItem(object itemName)
    {
        switch((string)itemName)
        {
            default: break;
        }
    }
}
