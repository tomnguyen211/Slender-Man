using Unity.Collections;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    private static GameManager _instance;

    [ReadOnly]
    public CharacterInfoBar CharacterBar;
    //public UnityAction<GameState> GameStateAction;

    public static GameManager Instance
    {
        get
        {
            if (!_instance)
            {
                _instance = FindObjectOfType(typeof(GameManager)) as GameManager;

                if (!_instance)
                {
                    Debug.LogError("There needs to be one active EventManger script on a GameObject in your scene.");
                }
                else
                {
                    _instance.Init();
                }
            }

            return _instance;
        }
    }

    /*[ReadOnly]
    public CharacterBar CharacterBar;*/

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);

    }

    private void Init()
    {
        //UpdateStateGame(GameState.StartGame);

    }
    private void OnEnable()
    {
        //EventManager.StartListening("TriggerBurn", TriggerBurn);

    }

    private void OnDisable()
    {
        //EventManager.StopListening("TriggerBurn", TriggerBurn);
    }
}
