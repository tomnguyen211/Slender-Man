using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Teleport_Building : MonoBehaviour
{
    public GameObject[] enemies;

    public  UnityAction teleportInside;

    public UnityAction teleportOutside;

    private void Start()
    {
        teleportInside += TeleportInside;
        teleportOutside += TeleportOutside;
    }

    private void OnDisable()
    {
        teleportInside -= TeleportInside;
        teleportOutside -= TeleportOutside;
    }


    private void TeleportInside()
    {
        for(int n = 0; n < enemies.Length; n++)
        {
            if(enemies[n].TryGetComponent<IDetect>(out IDetect detect))
            {
                detect.EnableDetect();
            }
        }
    }

    private void TeleportOutside()
    {
        for (int n = 0; n < enemies.Length; n++)
        {
            if (enemies[n].TryGetComponent<IDetect>(out IDetect detect))
            {
                detect.DisableDetect();
            }
        }
    }
}
