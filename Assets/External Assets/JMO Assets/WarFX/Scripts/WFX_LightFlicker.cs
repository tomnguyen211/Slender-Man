using UnityEngine;
using System.Collections;
using Unity.VisualScripting;

/**
 *	Rapidly sets a light on/off.
 *	
 *	(c) 2015, Jean Moreno
**/

[RequireComponent(typeof(Light))]
public class WFX_LightFlicker : MonoBehaviour
{
	public float time = 0.05f;
	
	private float timer;

	public bool isStart = true;
	
	void Start ()
	{
		timer = time;
		if(isStart)	
			StartCoroutine("Flicker");
	}

	public void TriggerEvent()
	{
        StartCoroutine("Flicker");
    }

    IEnumerator Flicker()
	{
		while(true)
		{
			GetComponent<Light>().enabled = !GetComponent<Light>().enabled;
			
			do
			{
				timer -= Time.deltaTime;
				yield return null;
			}
			while(timer > 0);
			timer = time;
		}
	}

	public void StopFlicker()
	{
		StopAllCoroutines();
	}
}
