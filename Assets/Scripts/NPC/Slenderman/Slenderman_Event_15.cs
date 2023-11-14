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

    [SerializeField]
    AudioSource scaryLoop;

    [SerializeField]
    AudioSource[] laughSound;


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
        scaryLoop.Play();
        StartCoroutine(StopScaryLoop());
        StartCoroutine(Laugh_1());
        StartCoroutine(Laugh_5());
        StartCoroutine(Laugh_2());
        StartCoroutine(Laugh_3());
        StartCoroutine(Laugh_4());

        EventManager.TriggerEvent("HeartBeatSound");

    }

    IEnumerator DelayEvent()
    {
        yield return new WaitForSeconds(5);
        for (int n = 0; n < Slender_Entity.Length; n++)
        {
            Slender_Entity[n].SetRadius(30);
        }

    }

    IEnumerator StopScaryLoop()
    {
        yield return new WaitForSeconds(20);
        scaryLoop.Stop();
    }

    IEnumerator Laugh_1()
    {
        yield return new WaitForSeconds(1);
        laughSound[0].Play();
    }
    IEnumerator Laugh_2()
    {
        yield return new WaitForSeconds(2);
        laughSound[1].Play();
    }
    IEnumerator Laugh_3()
    {
        yield return new WaitForSeconds(3);
        laughSound[2].Play();
    }
    IEnumerator Laugh_4()
    {
        yield return new WaitForSeconds(4);
        laughSound[3].Play();
    }
    IEnumerator Laugh_5()
    {
        yield return new WaitForSeconds(5);
        laughSound[4].Play();
    }


}
