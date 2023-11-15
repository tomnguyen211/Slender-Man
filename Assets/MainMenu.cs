using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    AudioSource source;
    [SerializeField]
    AudioClip Click;
    [SerializeField]
    AudioClip soundRollOver_Play;
    [SerializeField]
    AudioClip soundRollOver_Exit;

    [SerializeField]
    AudioSource laughSound;
    [SerializeField]
    AudioSource staticSound;
    private void Start()
    {
        source = GetComponent<AudioSource>();
    }
    public void PlayGame()
    {
        source.clip = Click;
        source.Play();
        laughSound.Play();
        staticSound.Play();
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }

    public void QuitGame()
    {
        source.clip = Click;
        source.Play();
        Application.Quit();
    }

    public void RollOverSoundPlay()
    {        source.clip = soundRollOver_Play;
        source.Play();
    }

    public void RollOverSoundQuit()
    {
        source.clip = soundRollOver_Exit;
        source.Play();
    }
}
