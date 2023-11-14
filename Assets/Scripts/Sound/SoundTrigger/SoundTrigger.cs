using UnityEngine;

public class SoundTrigger : MonoBehaviour
{
    [SerializeField]
    AudioSource sound;

    private void OnTriggerEnter(Collider col)
    {
        sound.Play();
    }

    private void OnTriggerExit(Collider col)
    {
        sound.Stop();
    }
}
