using UnityEngine;

public class Slenderman_EndEvent : MonoBehaviour
{
    bool isActivate;

    bool hasTrigger;

    [SerializeField]
    LayerMask armor;

    private void OnEnable()
    {
        EventManager.StartListening("ActivateSafeZone", ActivateSafeZone);
    }

    private void OnDisable()
    {
        EventManager.StopListening("ActivateSafeZone", ActivateSafeZone);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (((1 << other.gameObject.layer) & armor) != 0 && other.CompareTag("Player") && !hasTrigger)
        {
            hasTrigger = true;
            GameManager.Instance.UpdateGameState(GameState.EndGame);
        }
    }

    public void ActivateSafeZone()
    {
        isActivate = true;
    }
}
