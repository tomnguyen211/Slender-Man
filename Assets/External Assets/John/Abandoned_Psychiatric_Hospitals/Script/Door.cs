using Unity.Collections;
using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class Door : MonoBehaviour
{
    [SerializeField]
    Teleport_Building Teleport_Building;
    [SerializeField]
    bool teleportDoor;
    [SerializeField]
    Transform Teleport_Outside;
    [SerializeField]
    Transform Teleport_Inside;
    public bool IsTransit => transitCoroutine != null;
    private Coroutine transitCoroutine = null;

    [SerializeField,ReadOnly]
    bool trig, open;//trig-проверка входа выхода в триггер(игрок должен быть с тегом Player) open-закрыть и открыть дверь
    public float smooth = 2.0f;//скорость вращения
    public float DoorOpenAngle = 90.0f;//угол вращения
  
    Quaternion DoorOpen;
    Quaternion DoorClosed;

    [SerializeField]
    bool isOpen;

    public Text txt;//text 


    private void OnDisable()
    {
        
    }

    private void OnEnable()
    {
        
    }

    void Start()
    {
        if(isOpen)
        {
            open = true;
            DoorOpen = Quaternion.Euler(0, 0, 0);
            DoorClosed = Quaternion.Euler(0, DoorOpenAngle, 0);
        }
        else
        {
            DoorOpen = Quaternion.Euler(0, DoorOpenAngle, 0);
            DoorClosed = transform.rotation;
        }
    }

    void Update()
    {

        if (open)//открыть
        {
            transform.rotation = Quaternion.RotateTowards(transform.rotation, DoorOpen, Time.deltaTime * smooth);
        }
        else//закрыть
        {
            transform.rotation = Quaternion.RotateTowards(transform.rotation, DoorClosed, Time.deltaTime * smooth);
        }
        if (Input.GetKeyDown(KeyCode.E) && trig)
        {
            if(teleportDoor && !IsTransit)
            {
                transitCoroutine = StartCoroutine(TransitTeleport());
            }
            else if(!teleportDoor)
                open = !open;

        }
        if (trig)
        {
           /* if (open)
            {
                txt.text = "Close E";
            }
            else
            {
                txt.text = "Open E";
            }*/
        }
    }
    private void OnTriggerEnter(Collider coll)//вход и выход в\из  триггера 
    {
        if (coll.CompareTag("Player"))
        {
            /*if (!open)
            {
                txt.text = "Close E ";
            }
            else
            {
                txt.text = "Open E";
            }*/
            trig = true;
        }
    }
    private void OnTriggerExit(Collider coll)//вход и выход в\из  триггера 
    {
        if (coll.CompareTag("Player"))
        {
            //txt.text = " ";
            trig = false;
        }
    }

    IEnumerator TransitTeleport()
    {
        yield return new WaitForSeconds(0.5f);
        if (GameManager.Instance.Player.GetComponent<FPSCharacterController>().isOutside)
        {
            EventManager.TriggerEvent("PlayerTeleport", Teleport_Inside.position);
            GameManager.Instance.Player.GetComponent<FPSCharacterController>().isOutside = false;
            Teleport_Building.teleportInside?.Invoke();
        }
        else
        {
            EventManager.TriggerEvent("PlayerTeleport", Teleport_Outside.position);
            GameManager.Instance.Player.GetComponent<FPSCharacterController>().isOutside = true;
            Teleport_Building.teleportOutside?.Invoke();
        }
        transitCoroutine = null;
    }
}
