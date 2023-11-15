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

        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;

        EventManager.TriggerEvent("StartFadeOut", 1f);

    }
    public void PlayGame()
    {
        source.clip = Click;
        source.Play();
        laughSound.Play();
        staticSound.Play();
        EventManager.TriggerEvent("StartFadeIn", 0.2f);
        StartCoroutine(LoadGame());
    }

    IEnumerator LoadGame()
    {
        yield return new WaitForSeconds(5);
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(SceneManager.GetActiveScene().buildIndex + 1);

        // Wait until the asynchronous scene fully loads
        while (!asyncLoad.isDone)
        {
            yield return null;
        }

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
