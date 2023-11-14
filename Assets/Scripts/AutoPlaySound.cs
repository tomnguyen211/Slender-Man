using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoPlaySound : MonoBehaviour
{
    public AudioSound[] sounds;

    public static AutoPlaySound instance;

    [Space]

    public bool delayEnable;
    public float delayTime;

    [Space]
    public bool fadeSound;
    public float fadeTime;


    public void Awake()
    {
        foreach (AudioSound s in sounds)
        {
            s.source = gameObject.AddComponent<AudioSource>();
            s.source.clip = s.clip;
            s.source.outputAudioMixerGroup = s.audioMixer;
            s.source.volume = s.volume;
            s.source.pitch = s.pitch;
            s.source.loop = s.loop;
            s.source.mute = s.mute;
            s.source.minDistance = s.minDis;
            s.source.maxDistance = s.maxDis;
            s.source.spatialBlend = s.spatialBlend;
            s.source.spread = s.spread;
            s.source.priority = s.priority;
            s.source.dopplerLevel = s.dopplerEffect;
            if (s.rollOffModeLogarithmic)
                s.source.rolloffMode = AudioRolloffMode.Logarithmic;
            else if (s.rollOffModeLinear)
                s.source.rolloffMode = AudioRolloffMode.Linear;
        }
    }

    private void Start()
    {
        if (!delayEnable)
            Play();
        else
            StartCoroutine(Delay_Timer(delayTime));

        if (fadeSound)
        {
            StartCoroutine(Fade_Time(fadeTime));
        }
    }


    IEnumerator Delay_Timer(float delay)
    {
        yield return new WaitForSeconds(delay);
        Play();
    }

    IEnumerator Fade_Time(float delay)
    {
        yield return new WaitForSeconds(delay);
        foreach (AudioSound s in sounds)
        {
            StartCoroutine(DoFade(1, 0, s));
        }
    }

    IEnumerator DoFade(float duration, float endValue, AudioSound s)
    {
        float acceleration = (endValue - s.source.volume) / duration;
        while (true)
        {
            s.source.volume += acceleration * Time.deltaTime;
            if (s.source.volume <= endValue)
                yield break;
            yield return null;
        }
    }

    private void Play()
    {
        int random = Random.Range(0, sounds.Length);
        float n = UnityEngine.Random.Range(-0.3f, 0.3f);
        sounds[random].source.pitch += n;
        sounds[random].source.Play();
    }
}
