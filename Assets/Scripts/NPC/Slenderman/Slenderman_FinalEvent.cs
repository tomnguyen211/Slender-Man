using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Slenderman_FinalEvent : MonoBehaviour
{
    GameObject playerRef;

    [SerializeField]
    private bool hasActivate;

    [SerializeField]
    private bool spawnEnable = true;

    [SerializeField]
    GameObject SlenderObj;


    private void OnDisable()
    {
        EventManager.StopListening("Activate", Activate);
        EventManager.StopListening("DeActivate", DeActivate);

    }

    private void Start()
    {
        EventManager.StartListening("Activate", Activate);
        EventManager.StartListening("DeActivate", DeActivate);


        playerRef = GameManager.Instance.Player;
        spawnEnable = true;
    }

    private void Update()
    {
        if(hasActivate && spawnEnable)
        {
            if(playerRef == null)
            {
                playerRef = GameManager.Instance.Player;
                return;
            }
            Spawn();
            spawnEnable = false;
            StartCoroutine(SpawnSlenderMan());
        }
    }

    private void Activate()
    {
        hasActivate = true;
    }
    private void DeActivate()
    {
        hasActivate = false;
    }

    private void Spawn()
    {
        Vector3 pos = new Vector3(playerRef.transform.position.x + Random.Range(-5f, 5f), playerRef.transform.position.y + Random.Range(0f, 1.5f), playerRef.transform.position.z + Random.Range(-5f, 5f));
        Vector3 dir = (playerRef.transform.position - pos).normalized;
        // Multiply the direction by our desired speed to get a velocity

        Quaternion rot = Quaternion.LookRotation(dir, Vector3.up);

        GameObject obj = Instantiate(SlenderObj, pos, rot);

        obj.GetComponent<Slender_Entity>().DisaleObject(15);
/*
        Vector3 dir = (playerRef.transform.position - obj.transform.position).normalized;
        // Multiply the direction by our desired speed to get a velocity

        Quaternion rot = Quaternion.LookRotation(dir, Vector3.up);

        *//* float newRotX = Mathf.Clamp(rot.x,)*//*

        transform.rotation = Quaternion.RotateTowards(transform.rotation, rot, 300 * Time.deltaTime);*/

    }

    IEnumerator SpawnSlenderMan()
    {
        yield return new WaitForSeconds(Random.Range(4, 8));
        spawnEnable = true;
    }
}
