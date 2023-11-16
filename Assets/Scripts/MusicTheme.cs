using UnityEngine;
using UnityEngine.Events;

public class MusicTheme : MonoBehaviour
{
    AudioSource music;

    private bool finalEvent;

    private void Start()
    {
        music = GetComponent<AudioSource>();
        GameManager.Instance.UpdateGameState(GameState.StartGame);
    }


    [SerializeField]
    AudioClip[] themeClip;
    public bool themeLoopEnable;

    [SerializeField]
    AudioClip hospitalClip;

    [SerializeField]
    AudioClip abandonHouseClip;

    [SerializeField]
    AudioClip chasingClip;

    [SerializeField]
    AudioClip carCrash;
    bool carCrashEvent;


    public UnityEvent triggerEvent;

    private void OnEnable()
    {
        EventManager.StartListening("TriggerThemeSound", TriggerThemeSound);
    }

    private void OnDisable()
    {
        EventManager.StopListening("TriggerThemeSound", TriggerThemeSound);
    }

    private void Update()
    {
        if(themeLoopEnable && !music.isPlaying)
        {
            music.clip = themeClip[Random.Range(0, themeClip.Length)];
            music.Play();
        }

        if(carCrashEvent)
        {
            if(!music.isPlaying) 
            {
                EventManager.TriggerEvent("StartEvent", false);
                carCrashEvent = false;
                EventManager.TriggerEvent("StartFadeOut", 0.25f);
                triggerEvent?.Invoke();
                TriggerThemeSound("Theme");

            }
        }
    }

    public void TriggerThemeSound(object name)
    {
        if(!finalEvent)
        {
            switch ((string)name)
            {
                case "Theme":
                    themeLoopEnable = true;
                    break;
                case "Hospital":
                    themeLoopEnable = false;
                    music.Stop();
                    music.clip = hospitalClip;
                    music.Play();
                    break;
                case "AbandonHouse":
                    themeLoopEnable = false;
                    music.Stop();
                    music.clip = abandonHouseClip;
                    music.Play();
                    break;
                case "Chasing":
                    themeLoopEnable = false;
                    music.Stop();
                    music.clip = chasingClip;
                    music.loop = true;
                    music.Play();
                    finalEvent = true;
                    break;
                case "CarCrash":
                    themeLoopEnable = false;
                    music.Stop();
                    music.clip = carCrash;
                    music.Play();
                    carCrashEvent = true;
                    break;
                default: break;
            }
        }
    }

   
}
