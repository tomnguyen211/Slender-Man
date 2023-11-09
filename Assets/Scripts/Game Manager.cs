using Unity.Collections;
using UnityEngine;
using UnityEngine.Events;

public class GameManager : MonoBehaviour
{
    public GameObject Player;

    private static GameManager _instance;

    public QuestItem[] questItems;

    public GameState GameState;

    public static event UnityAction<GameState> OnGameStateChanged;

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
        Player = GameObject.Find("FPS Character Controller");
    }

    private void Start()
    {
        UpdateGameState(GameState.StartGame);
    }

    private void Init()
    {
        //UpdateStateGame(GameState.StartGame);

    }
    private void OnEnable()
    {
        EventManager.StartListening("QuestItemCheck", QuestItemCheck);

    }

    private void OnDisable()
    {
        EventManager.StopListening("QuestItemCheck", QuestItemCheck);
    }

    private void QuestItemCheck(object item)
    {
        int count = 0;

        string prop = (string) item;
        for(int n = 0; n < questItems.Length; n++)
        {
            if (questItems[n].hasUnlock)
                count++;

            if (prop == questItems[n].item)
            {
                questItems[n].hasUnlock = true;
                count++;
            }
        }

        CharacterBar.UpdateUIQuest(count);

        if (count == 2)
        {
            UpdateGameState(GameState.Stage_1);
        }
        else if (count == 4)
        {
            UpdateGameState(GameState.Stage_2);
        }
        else if(count == 7)
        {
            UpdateGameState(GameState.Stage_3);
        }
    }

    public void UpdateGameState(GameState newState)
    {
        GameState = newState;
        switch(newState)
        {
            case GameState.StartGame:
                break;
            case GameState.Stage_1:
                break;
            case GameState.Stage_2:
                break;
            case GameState.Stage_3:
                break;
            case GameState.EndGame:
                break;
        }

        OnGameStateChanged?.Invoke(newState);
    }
}



[System.Serializable]
public class QuestItem
{
    public string item;
    public bool hasUnlock;
}

public enum GameState
{
    StartGame,
    Stage_1,
    Stage_2,
    Stage_3,
    EndGame
}
