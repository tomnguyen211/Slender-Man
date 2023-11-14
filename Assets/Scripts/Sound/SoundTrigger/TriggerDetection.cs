using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerDetection : MonoBehaviour
{
    [SerializeField]
    GameObject[] enemies;

    public void Trigger_Detection()
    {
        for(int i = 0; i < enemies.Length; i++)
        {
            if (enemies[i].TryGetComponent<IDetect>(out IDetect detect))
            {
                detect.TriggerDetectionEvent();
            }

        }
    }
}
