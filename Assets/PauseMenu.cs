using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseMenu : MonoBehaviour
{
    public GameObject PauseMenuUI;
    public static bool GameIsPaused = false;

    private bool eventPause;
    private bool eventResume;


    AudioSource source;
    [SerializeField]
    AudioClip Click;
    [SerializeField]
    AudioClip soundRollOver_Option;
    [SerializeField]
    AudioClip soundRollOver_Exit;

    private void Start()
    {
        source = GetComponent<AudioSource>();

    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (GameIsPaused) 
            { 
                Resume();
            } 
            else
            {
                Pause();
            }
        }
    }

    public void Resume()
    {
        PauseMenuUI.SetActive(false);
        Time.timeScale = 1;
        GameIsPaused = false;

        if (!eventResume)
        {
            EventManager.TriggerEvent("PauseEvent", false);
            eventResume = true;
            eventPause = false;
        }
    }

    void Pause()
    {
        PauseMenuUI.SetActive(true);
        Time.timeScale = 0;
        GameIsPaused = true;

        if (!eventPause)
        {
            EventManager.TriggerEvent("PauseEvent", true);
            eventResume = false;
            eventPause = true;
        }
    }

    public void LoadMenu()
    {
        Time.timeScale = 1;
        source.clip = Click;
        source.Play();
        SceneManager.LoadScene("Menu");
    }

    public void Exit()
    {
        source.clip = Click;
        source.Play();
        Debug.Log("Exiting Game...");
        Application.Quit();
    }

    public void RollOverSoundOption()
    {
        Debug.Log("Passed");
        source.clip = soundRollOver_Option;
        source.Play();
    }

    public void RollOverSoundQuit()
    {
        Debug.Log("Passed");
        source.clip = soundRollOver_Exit;
        source.Play();
    }
}
