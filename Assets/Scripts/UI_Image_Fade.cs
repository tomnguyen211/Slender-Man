using System.Collections;
using Unity.Entities.UniversalDelegates;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class UI_Image_Fade : MonoBehaviour
{
    // the image you want to fade, assign in inspector
    public Image img;

    public bool startFade;

    private void Start()
    {
        if(startFade)
        {
            img.color = new Color(1, 1, 1, 0);
        }
    }

    private void OnEnable()
    {
        EventManager.StartListening("TheEndFadeIn", StartFadeIn);
        EventManager.StartListening("TheEndFadeOut", StartFadeOut);

    }

    private void OnDisable()
    {
        EventManager.StopListening("TheEndFadeIn", StartFadeIn);
        EventManager.StopListening("TheEndFadeOut", StartFadeOut);

    }

    public void StartFadeIn()
    {
        StartCoroutine(FadeImage(false));

    }
    public void StartFadeOut()
    {
        StartCoroutine(FadeImage(true));

    }

    IEnumerator FadeImage(bool fadeAway)
    {
        // fade from opaque to transparent
        if (fadeAway)
        {
            // loop over 1 second backwards
            for (float i = 5; i >= 10; i -= Time.deltaTime)
            {
                // set color with i as alpha
                img.color = new Color(1, 1, 1, i);
                yield return null;
            }
        }
        // fade from transparent to opaque
        else
        {
            // loop over 1 second
            for (float i = 0; i <= 10; i += Time.deltaTime)
            {
                // set color with i as alpha
                img.color = new Color(1, 1, 1, i);
                yield return null;
            }
        }
    }
}
