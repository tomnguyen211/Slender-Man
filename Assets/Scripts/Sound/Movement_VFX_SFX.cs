using UnityEngine;
using UnityEngine.Audio;

[System.Serializable]
public struct Movement_VFX_SFX_Struct
{
    public AudioClip[] clip;

    public string name;

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
    public float spatialBlend;

    [Range(0f, 180f)]
    public float spread;

    public float minDis;

    public float maxDis;

    public bool rollOffModeLogarithmic;

    public bool rollOffModeLinear;

    [Range(0, 256)]
    public int priority;

    [Range(0f, 5f)]
    public float dopplerEffect;
}
[CreateAssetMenu(fileName = "MovementManager", menuName = "Data/Player Data/MovementManager")]
public class Movement_VFX_SFX : ScriptableObject
{
    [Header("Sound")]

    public Movement_VFX_SFX_Struct SFX_Normal_Ground;

    public Movement_VFX_SFX_Struct SFX_Normal_Wood;

    public Movement_VFX_SFX_Struct SFX_Normal_Concrete;


    [Space]

    public Movement_VFX_SFX_Struct SFX_Large_Ground;

    public Movement_VFX_SFX_Struct SFX_Large_Wood;

    public Movement_VFX_SFX_Struct SFX_Large_Concrete;

}
