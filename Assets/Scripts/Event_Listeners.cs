using System.Collections;
using System.Collections.Generic;
using UnityEditor.Build.Pipeline.Utilities;
using UnityEngine;

public class Event_Listeners : MonoBehaviour
{

    public int Current_PistolBullet;

    public int Current_ShotgunBullet;

    public int Current_HealthPack;

    public int Current_Battery;

    public bool knifeUnlocked;

    public bool pistolUnlocked;

    public bool shotgunUnlocked;

    public bool axeUnlocked;

    [SerializeField]
    Transform latestLocation;
    [SerializeField]
    Transform[] SpawnLocation;
    [SerializeField]
    GameObject playerPrefab;

    private void OnEnable()
    {
        EventManager.StartListening("PistolBullet", PistolBullet);
        EventManager.StartListening("ShotgunBullet", ShotgunBullet);
        EventManager.StartListening("HeathPack", HeathPack);
        EventManager.StartListening("Batttery", Batttery);
        EventManager.StartListening("WhatUnlock", WhatUnlock);
        EventManager.StartListening("LatestLocation", LatestLocation);
        EventManager.StartListening("PlayerSpawn", PlayerSpawn);

    }

    private void OnDisable()
    {
        EventManager.StopListening("PistolBullet", PistolBullet);
        EventManager.StopListening("ShotgunBullet", ShotgunBullet);
        EventManager.StopListening("HeathPack", HeathPack);
        EventManager.StopListening("Batttery", Batttery);
        EventManager.StopListening("WhatUnlock", WhatUnlock);
        EventManager.StopListening("LatestLocation", LatestLocation);
        EventManager.StopListening("PlayerSpawn", PlayerSpawn);

    }

    private void PistolBullet(object value)
    {
        Current_PistolBullet = (int)value;
    }
    private void ShotgunBullet(object value)
    {
        Current_ShotgunBullet = (int)value;
    }
    private void HeathPack(object value)
    {
        Current_HealthPack = (int)value;
    }
    private void Batttery(object value)
    {
        Current_Battery = (int)value;
    }

    private void WhatUnlock(object value)
    {
        switch((string) value)
        {
            case "handgun":
                pistolUnlocked = true;
                break;
            case "shotgun":
                shotgunUnlocked = true;
                break;
            case "kombat knife":
                knifeUnlocked = true;
                break;
            case "fireaxe":
                axeUnlocked = true;
                break;
                default: break;
        }
    }

    private void LatestLocation(object location)
    {
        latestLocation = (Transform)location;
    }

    private void PlayerSpawn()
    {
        Vector3 spawnPos = Vector3.zero;
        for(int n = 0; n < SpawnLocation.Length; n++)
        {
            if (SpawnLocation[n].parent == latestLocation)
            {
                spawnPos = SpawnLocation[n].position;

                GameObject player = Instantiate(playerPrefab, spawnPos, Quaternion.identity);

                player.GetComponent<FPSHandsController>().SpawnRefillInventory(Current_PistolBullet, Current_ShotgunBullet, Current_HealthPack, Current_Battery, knifeUnlocked, pistolUnlocked, shotgunUnlocked, axeUnlocked);
                player.GetComponent<FPSCharacterController>().ScreenDamage.CurrentHealth -= 0;
                if (n == 1 || n == 2 || n == 5 || n == 6 || n == 2)
                {
                    EventManager.TriggerEvent("TriggerThemeSound", "Theme");
                    player.GetComponent<FPSCharacterController>().isOutside = true;
                }
                else
                {
                    player.GetComponent<FPSCharacterController>().isOutside = false;
                    if(n == 0) // Skull
                    {
                        EventManager.TriggerEvent("TriggerThemeSound", "AbandonHouse");
                    }
                    else if(n == 3) // Staff
                    {
                        EventManager.TriggerEvent("TriggerThemeSound", "Hospital");
                    }
                    else if (n == 4) // Painting
                    {
                        break;
                    }
                }

                EventManager.TriggerEvent("StartFadeOut", 0.25f);

                break;
            }
        }
    }
}
