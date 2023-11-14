using System.Collections;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Events;

public enum EntityBodyTag_Sound
{
    Normal,
    Large,
    Custom,
}


public class MovementManager : MonoBehaviour
{
    [SerializeField]
    EntityBodyTag_Sound entityBodyTag;

    [SerializeField, Range(0, 1)]
    float volume;

    AudioSource Sound { get; set; }

    [SerializeField]
    Movement_VFX_SFX Movement_VFX_SFX;


    [SerializeField]
    bool CustomSound;
    [SerializeField]
    AudioSound[] customSurface_SFX;

    [Space]

    [SerializeField]
    private float paceTimer = 1;
    [SerializeField]
    private float paceTimerRandom = 0.5f;

    [Space]

    [Space]
    [SerializeField]
    private Transform groundCheck;
    private Vector2 groundCheckPosition;

    [SerializeField]
    LayerMask groundLayer;

    public delegate bool IsIdle();
    public IsIdle isIdle;

    public delegate bool IsMoving();
    public IsMoving isMoving;

    private void Awake()
    {
        Sound = gameObject.AddComponent<AudioSource>(); 
    }

    private void Start()
    {
        groundLayer |= (1 << LayerMask.NameToLayer("Ground"));
        groundLayer |= (1 << LayerMask.NameToLayer("Floor_1"));
        groundLayer |= (1 << LayerMask.NameToLayer("Floor_2"));
        groundCheckPosition = groundCheck.position;

        StartCoroutine(Movemnent_Pace(paceTimer));
    }

    IEnumerator Movemnent_Pace(float timer)
    {
        yield return new WaitForSeconds(timer + Random.Range(-paceTimerRandom, paceTimerRandom));
        /*        if (!isPlayer)
                {
                    CollisionSoundTrigger();
                    StartCoroutine(Movemnent_Pace(paceTimer));
                }
                else
                    paceEnable = true;*/
        CollisionSoundTrigger();
        StartCoroutine(Movemnent_Pace(paceTimer));
    }

    private void Play_Sound(int index, Movement_VFX_SFX_Struct s)
    {
        Sound.clip = s.clip[index];
        Sound.outputAudioMixerGroup = s.audioMixer;
        //Sound.volume = s.volume;
        Sound.volume = volume;
        Sound.pitch = s.pitch;
        Sound.loop = s.loop;
        Sound.mute = s.mute;
        Sound.minDistance = s.minDis;
        Sound.maxDistance = s.maxDis;
        Sound.spatialBlend = s.spatialBlend;
        Sound.spread = s.spread;
        Sound.priority = s.priority;
        Sound.dopplerLevel = s.dopplerEffect;
        if (s.rollOffModeLogarithmic)
            Sound.rolloffMode = AudioRolloffMode.Logarithmic;
        else if (s.rollOffModeLinear)
            Sound.rolloffMode = AudioRolloffMode.Linear;

        Sound.Play();
    }

    private void CollisionSoundTrigger()
    {
        if (isMoving.Invoke())
        {
            Ray ray = new Ray(groundCheckPosition, -transform.up);
            RaycastHit rayGround;
            if (Physics.Raycast(ray, out rayGround, 10, groundLayer))
            {

                Transform col = rayGround.transform;
                if (entityBodyTag == EntityBodyTag_Sound.Normal)
                {
                    if (col.gameObject.CompareTag("Ground"))
                    {
                        if (Movement_VFX_SFX.SFX_Normal_Ground.clip.Length > 0)
                        {
                            int random_S = Random.Range(0, Movement_VFX_SFX.SFX_Normal_Ground.clip.Length);
                            Play_Sound(random_S, Movement_VFX_SFX.SFX_Normal_Ground);
                        }
                    }
                    else if (col.gameObject.CompareTag("Wood"))
                    {
                        if (Movement_VFX_SFX.SFX_Normal_Wood.clip.Length > 0)
                        {
                            int random_S = Random.Range(0, Movement_VFX_SFX.SFX_Normal_Wood.clip.Length);
                            Play_Sound(random_S, Movement_VFX_SFX.SFX_Normal_Wood);
                        }
                    }
                    else if (col.gameObject.CompareTag("Concrete"))
                    {
                        if (Movement_VFX_SFX.SFX_Normal_Concrete.clip.Length > 0)
                        {
                            int random_S = Random.Range(0, Movement_VFX_SFX.SFX_Normal_Concrete.clip.Length);
                            Play_Sound(random_S, Movement_VFX_SFX.SFX_Normal_Concrete);
                        }
                    }
                }
                else if (entityBodyTag == EntityBodyTag_Sound.Large)
                {
                    if (col.gameObject.CompareTag("Ground"))
                    {
                        if (Movement_VFX_SFX.SFX_Large_Ground.clip.Length > 0)
                        {
                            int random_S = Random.Range(0, Movement_VFX_SFX.SFX_Large_Ground.clip.Length);
                            Play_Sound(random_S, Movement_VFX_SFX.SFX_Large_Ground);
                        }
                    }
                    else if (col.gameObject.CompareTag("Wood"))
                    {
                        if (Movement_VFX_SFX.SFX_Large_Wood.clip.Length > 0)
                        {
                            int random_S = Random.Range(0, Movement_VFX_SFX.SFX_Large_Wood.clip.Length);
                            Play_Sound(random_S, Movement_VFX_SFX.SFX_Large_Wood);
                        }
                    }
                    else if (col.gameObject.CompareTag("Concrete"))
                    {
                        if (Movement_VFX_SFX.SFX_Large_Concrete.clip.Length > 0)
                        {
                            int random_S = Random.Range(0, Movement_VFX_SFX.SFX_Large_Concrete.clip.Length);
                            Play_Sound(random_S, Movement_VFX_SFX.SFX_Large_Concrete);
                        }
                    }
                }
                else if (entityBodyTag == EntityBodyTag_Sound.Custom)
                {
                    int random_S = Random.Range(0, customSurface_SFX.Length);
                    customSurface_SFX[random_S].source.Play();
                }
            }
        }
    }

    public void SetPaceTimer(float t) => paceTimer = t;
    public void SetPaceTimerRandom(float t) => paceTimerRandom = t;

}
