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
        EventManager.TriggerEvent("StartFadeIn", 0.1f);
        SceneManager.LoadSceneAsync(SceneManager.GetActiveScene().buildIndex + 1);

    }

    IEnumerator Wait()
    {
        yield return new WaitForSeconds(2);
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);

        // The Application loads the Scene in the background as the current Scene runs.
        // This is particularly good for creating loading screens.
        // You could also load the Scene by using sceneBuildIndex. In this case Scene2 has
        // a sceneBuildIndex of 1 as shown in Build Settings.

        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync("Scene2");

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
