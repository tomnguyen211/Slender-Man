using System;
using UnityEngine;
using UnityEngine.Audio;

public class AudioManager : MonoBehaviour
{
    public AudioSound[] sounds;

    public static AudioManager instance;

    public void Awake()
    {
        // For BackGround // Music Only
        /*if (instance == null)
            instance = this;
        else
        {
            Destroy(gameObject);
            return;
        }       
        DontDestroyOnLoad(gameObject);*/
        foreach (AudioSound s in sounds)
        {
            s.source = gameObject.AddComponent<AudioSource>();
            s.source.clip = s.clip;
            s.source.outputAudioMixerGroup = s.audioMixer;
            s.source.volume = s.volume;
            s.source.pitch = s.pitch;
            s.source.loop = s.loop;
            s.source.mute = s.mute;
            s.source.minDistance = 1;
            s.source.maxDistance = 5;
            s.source.spatialBlend = 1;
            s.source.spread = 360;
            s.source.priority = s.priority;
            s.source.dopplerLevel = s.dopplerEffect;
            if (s.rollOffModeLogarithmic)
                s.source.rolloffMode = AudioRolloffMode.Logarithmic;
            else if (s.rollOffModeLinear)
                s.source.rolloffMode = AudioRolloffMode.Linear;
        }

    }

    public bool IsPlaying(string name)
    {
        AudioSound s = Array.Find(sounds, sound => sound.name == name);
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
            return false;
        }
        return s.source.isPlaying;
    }

    public void Play(string name)
    {
        AudioSound s = Array.Find(sounds, sound => sound.name == name);
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
            return;
        }
        s.source.pitch = s.pitch;
        float random = UnityEngine.Random.Range(-0.3f, 0.3f);
        s.source.pitch += random;
        //s.source.DOPitch(s.source.pitch + random, 0.5f);

        //audioPools.PlayAtPoint(s.source.clip, transform.position);

        s.source.Play();
    }
    public float Find(string name, string component)
    {
        AudioSound s = Array.Find(sounds, sound => sound.name == name);
        float n = 0;
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
        }
        switch (component)
        {
            case "Pitch":
                n = s.source.pitch;
                break;
            case "Volume":
                n = s.source.volume;
                break;

        }
        return n;
    }
    public AudioClip GetAudioClip(string name)
    {
        AudioSound s = Array.Find(sounds, sound => sound.name == name);
        return s.source.clip;

    }
    public void AudioMixer(string name, string control, float n)
    {
        AudioSound s = Array.Find(sounds, sound => sound.name == name);
        if (s == null)
        {
            Debug.LogWarning("AudioMixer: " + name + " not found!");
            return;
        }
        s.source.outputAudioMixerGroup.audioMixer.SetFloat(control, n);
    }
    public void AudioSourceControl(string name, string component, float n)
    {
        AudioSound s = Array.Find(sounds, sound => sound.name == name);
        if (s == null)
        {
            Debug.LogWarning("AudioMixer: " + name + " not found!");
            return;
        }
        switch (component)
        {
            case "Pitch":
                s.source.pitch = n;
                break;
            case "Volume":
                s.source.volume = n;
                break;
            default:
                break;
        }
    }
    public void Stop(string name)
    {
        AudioSound s = Array.Find(sounds, sound => sound.name == name);
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
            return;
        }
        s.source.Stop();
    }

    public void StopAll()
    {
        foreach (AudioSound s in sounds)
        {
            if (s.source.isPlaying)
                s.source.Stop();
        }
    }
}


[System.Serializable]
public class AudioSound
{
    public string name;

    public AudioClip clip;
    public AudioMixerGroup audioMixer;

    [Range(0f, 1f)]
    public float volume;

    [Range(.1f, 3f)]
    public float pitch;

    [HideInInspector]
    public AudioSource source;

    public bool loop;

    public bool mute;

    [Range(0f, 1f)]
    public float spatialBlend = 1;
    [Range(0f, 360f)]
    public float spread = 180;

    public float minDis;

    public float maxDis;

    public bool rollOffModeLogarithmic;

    public bool rollOffModeLinear;

    [Range(0, 256)]
    public int priority;

    [Range(0f, 5f)]
    public float dopplerEffect;

    public bool delaySound;
    public float delayTime;

    public bool fadingSound;
    public float fadingTime;
    public float fading_delayTime;



}
