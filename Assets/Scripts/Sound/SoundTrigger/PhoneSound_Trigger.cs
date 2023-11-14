using System.Collections;
using UnityEngine;
using UnityEngine.Events;

public class PhoneSound_Trigger : MonoBehaviour
{
    [SerializeField]
    AudioSource sound;

    public bool isActivate;
    [SerializeField]
    Collider[] activateCollider;
    [SerializeField]
    AudioClip ringingSound;

    public bool isInteract;
    [SerializeField]
    Collider interactCollider;
    [SerializeField]
    AudioClip answerSound;

    bool trig;

    public bool isAbleToStop;

    public bool waitTime;

    public Light_Flash lightEvent;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.E) && trig && !isInteract)
        {
            isInteract = true;
            sound.Stop();
            sound.clip = answerSound;
            sound.loop = false;
            sound.Play();
            StartCoroutine(StopPhone());
            lightEvent.TurnOnLight(lightEvent.maxIntesity);
            lightEvent.StopAllCoroutines();

        }

        if (isAbleToStop && Input.GetKeyDown(KeyCode.E) && trig)
        {
            sound.Stop();
            isAbleToStop = false;
            lightEvent.TurnLightNormal();
        }

        if(!sound.isPlaying && lightEvent.GetLightIntensity() != lightEvent.orignalIntensity)
        {
            lightEvent.TurnLightNormal();
        }
    }
    private void OnTriggerEnter(Collider col)
    {
        if (isActivate && waitTime)
        {
            trig = true;
        }

        if (col.CompareTag("Player") && !isActivate)
        {
            isActivate = true;
            for (int i = 0; i < activateCollider.Length; i++)
            {
                activateCollider[i].enabled = false;
            }
            interactCollider.enabled = true;
            sound.clip = ringingSound;
            sound.loop = true;
            sound.Play();
            StartCoroutine(WaitTime());
            lightEvent.TurnLightFlashing();
        }
    }

    private void OnTriggerExit(Collider coll)
    {
        if (coll.CompareTag("Player"))
        {
            trig = false;
        }
    }

    IEnumerator WaitTime()
    {
        yield return new WaitForSeconds(1);
        waitTime = true;
    }

    IEnumerator StopPhone()
    {
        yield return new WaitForSeconds(5);
        isAbleToStop = true;
    }
}
