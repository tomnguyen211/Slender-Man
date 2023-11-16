using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Teleport_Building : MonoBehaviour
{
    public bool isGlobal;

    public GameObject[] enemies;

    public  UnityAction teleportInside;

    public UnityEvent teleportInside_Event;

    public UnityAction teleportOutside;

    public UnityEvent teleportOutside_Event;


    private void Start()
    {
        teleportInside += TeleportInside;
        teleportOutside += TeleportOutside;

        if (isGlobal)
        {
            EventManager.StartListening("TeleportOutside_Global", TeleportOutside_Global);
            EventManager.StartListening("TeleportInside_Global", TeleportInside_Global);
            EventManager.StartListening("DisableAllEnemies", DisableAllEnemies);


        }
    }

    private void OnDisable()
    {
        teleportInside -= TeleportInside;
        teleportOutside -= TeleportOutside;

        if (isGlobal)
        {
            EventManager.StopListening("TeleportOutside_Global", TeleportOutside_Global);
            EventManager.StopListening("TeleportInside_Global", TeleportInside_Global);
            EventManager.StopListening("DisableAllEnemies", DisableAllEnemies);

        }
    }


    private void TeleportInside()
    {
        for(int n = 0; n < enemies.Length; n++)
        {
            if(enemies[n] != null && enemies[n].TryGetComponent<IDetect>(out IDetect detect))
            {
                detect.EnableDetect();
            }
        }

        teleportInside_Event?.Invoke();
    }

    private void TeleportOutside()
    {
        for (int n = 0; n < enemies.Length; n++)
        {

            if (enemies[n] != null && enemies[n].TryGetComponent<IDetect>(out IDetect detect))
            {
                detect.DisableDetect();
            }
        }

        teleportOutside_Event?.Invoke();
    }

    private void TeleportOutside_Global()
    {

        for (int n = 0; n < enemies.Length; n++)
        {
            if (enemies[n] != null && enemies[n].TryGetComponent<IDetect>(out IDetect detect))
            {
                detect.EnableDetect();
            }
        }
    }
    private void TeleportInside_Global()
    {
        for (int n = 0; n < enemies.Length; n++)
        {
            if (enemies[n] != null && enemies[n].TryGetComponent<IDetect>(out IDetect detect))
            {
                detect.DisableDetect();
            }
        }
    }

    private void DisableAllEnemies()
    {
        for (int n = 0; n < enemies.Length; n++)
        {
            if (enemies[n] != null && enemies[n].TryGetComponent<IDetect>(out IDetect detect))
            {
                detect.DisableDetect();
            }
        }
    }
}
