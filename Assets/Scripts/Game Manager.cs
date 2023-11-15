using System.Collections;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

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
        EventManager.StartListening("Get_Player", Get_Player);

    }

    private void OnDisable()
    {
        EventManager.StopListening("QuestItemCheck", QuestItemCheck);
        EventManager.StopListening("Get_Player", Get_Player);
    }

    private void QuestItemCheck(object item)
    {
        int count = 0;

        string prop = (string) item;
        Debug.Log("Quest: " + prop);
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

        Debug.Log("count: " + count);


        CharacterBar.UpdateUIQuest(count);

        if (count == 2)
        {
            UpdateGameState(GameState.Stage_1);
        }
        else if (count == 4)
        {
            UpdateGameState(GameState.Stage_2);
        }
        else if(count == 6)
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
                EventManager.TriggerEvent("Activate");
                EventManager.TriggerEvent("FinalEvent");
                break;
            case GameState.EndGame:
                EventManager.TriggerEvent("EndGame_Player");
                EventManager.TriggerEvent("DisableAllEnemies");
                StartCoroutine(ResetGame());
                for (int n = 0; n < questItems.Length; n++)
                {
                    questItems[n].hasUnlock = false;
                }
                break;
        }

        OnGameStateChanged?.Invoke(newState);
    }

    private void Get_Player(object p)
    {
        Player = (GameObject)p;
    }

    IEnumerator ResetGame()
    {
        yield return new WaitForSeconds(15);
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex - 1);

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




