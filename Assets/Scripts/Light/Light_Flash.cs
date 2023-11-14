using System.Collections;
using System.Collections.Generic;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class Light_Flash : MonoBehaviour
{
    [SerializeField]
    bool isStart = true;

    Light lightA;

    public float duration;

    public float maxIntesity;

    public float minIntesity;

    [SerializeField]
    float pauseTime;

    [HideInInspector]
    public float orignalIntensity;


    private void Start()
    {
        lightA = GetComponent<Light>();

        if (isStart)
            StartCoroutine(DoLight());

        orignalIntensity = lightA.intensity;
    }

    public float GetLightIntensity() => lightA.intensity;

    public void TurnOffLight()
    {
        lightA.intensity = 0;
        StopAllCoroutines();
    }

    public void TurnOnLight(float amount) => lightA.intensity = amount;

    public void TurnLightFlashing() => StartCoroutine(DoLight());

    public void TurnLightNormal() => lightA.intensity = orignalIntensity;


    public IEnumerator DoLight()
    {
        float acceleration = (maxIntesity - minIntesity) / duration;

        if(pauseTime > 0)
        {
            while (true)
            {
                lightA.intensity += acceleration * Time.deltaTime;

                if(lightA.intensity < minIntesity)
                {
                    lightA.intensity = minIntesity;
                    acceleration = -acceleration;
                    yield return new WaitForSeconds(pauseTime);
                }
                else if(lightA.intensity > maxIntesity)
                {
                    lightA.intensity = maxIntesity;
                    acceleration = -acceleration;
                    yield return new WaitForSeconds(pauseTime);
                }
                yield return null;
            }
        }
        else
        {
            while (true)
            {
                if (lightA.intensity < minIntesity)
                    lightA.intensity += acceleration * Time.deltaTime;
                else
                    lightA.intensity -= acceleration * Time.deltaTime;
                yield return null;
            }
        }
    }
}
