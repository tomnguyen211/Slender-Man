using Unity.Collections;
using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using UnityEngine.Events;

public class Door : MonoBehaviour
{
    [SerializeField]
    string building;
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

    public Text txt;

    AudioSource sound;

    [SerializeField]
    AudioClip[] doorOpenSound;

    [SerializeField]
    AudioClip[] doorCloseSound;

    private bool switchBooleanOn;
    private bool soundTrigger;

    public UnityEvent triggerEvent;
    private bool hasTrigger;
    [SerializeField]
    private bool unlimitedTrigger;

    public bool isRotating;



    void Start()
    {
        sound = gameObject.AddComponent<AudioSource>();
        sound.volume = 1;
        sound.pitch = 1;
        sound.minDistance = 1;
        sound.maxDistance = 10;
        sound.spatialBlend = 1;
        sound.spread = 360;
        sound.priority = 130;
        sound.dopplerLevel = 2;
        sound.rolloffMode = AudioRolloffMode.Logarithmic;

        if (isOpen)
        {
            open = true;
            DoorOpen = Quaternion.Euler(0, 0, 0);
            DoorClosed = Quaternion.Euler(0, DoorOpenAngle, 0);
            switchBooleanOn = true;
        }
        else
        {
            DoorOpen = Quaternion.Euler(0, DoorOpenAngle, 0);
            DoorClosed = transform.rotation;
            switchBooleanOn = false;
        }
    }

    void Update()
    {

        if (open && isRotating)//открыть
        {
            transform.rotation = Quaternion.RotateTowards(transform.rotation, DoorOpen, Time.deltaTime * smooth);

            if(transform.rotation == DoorOpen)
            {
                isRotating = false;
                isOpen = true;
            }

            if(soundTrigger)
            {
                soundTrigger = false;
                if (!switchBooleanOn)
                {
                    switchBooleanOn = true;
                    if (doorOpenSound.Length > 0)
                    {
                        sound.Stop();
                        sound.clip = doorOpenSound[Random.Range(0, doorOpenSound.Length)];
                        sound.Play();
                    }
                }
            }         
        }
        else if(isRotating)
        {
            transform.rotation = Quaternion.RotateTowards(transform.rotation, DoorClosed, Time.deltaTime * smooth);

            if (transform.rotation == DoorClosed)
            {
                isRotating = false;
                isOpen = false;
            }

            if (soundTrigger)
            {
                if (switchBooleanOn)
                {
                    switchBooleanOn = false;
                    if (doorCloseSound.Length > 0)
                    {
                        sound.Stop();
                        sound.clip = doorCloseSound[Random.Range(0, doorCloseSound.Length)];
                        sound.Play();
                    }
                }
                soundTrigger = false;
            }
        }

        if (Input.GetKeyDown(KeyCode.E) && trig)
        {
            soundTrigger = true;

            if (teleportDoor && !IsTransit)
            {
                transitCoroutine = StartCoroutine(TransitTeleport());
            }
            else if(!teleportDoor)
            {
                isRotating = true;
                open = !open;
            }

            if(!hasTrigger)
            {
                if(!unlimitedTrigger)
                {
                    hasTrigger = true;
                }
                triggerEvent?.Invoke();
            }
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

    public void TriggerOpen()
    {
        if(!isOpen)
        {
            soundTrigger = true;

            isRotating = true;
            open = !open;

            if (!hasTrigger)
            {
                hasTrigger = true;
                triggerEvent?.Invoke();
            }
        }
    }

    public void TriggerClose()
    {
        if (isOpen)
        {
            soundTrigger = true;

            isRotating = true;
            open = !open;

            if (!hasTrigger)
            {
                hasTrigger = true;
                triggerEvent?.Invoke();
            }
        }
    }



    IEnumerator TransitTeleport()
    {
        yield return new WaitForSeconds(0.5f);
        if (GameManager.Instance.Player.GetComponent<GetParentObject>().parent.GetComponent<FPSCharacterController>().isOutside)
        {
            EventManager.TriggerEvent("PlayerTeleport", Teleport_Inside.position);
            EventManager.TriggerEvent("TriggerThemeSound", building);
            GameManager.Instance.Player.GetComponent<GetParentObject>().parent.GetComponent<FPSCharacterController>().isOutside = false;
            Teleport_Building.teleportInside?.Invoke();
            EventManager.TriggerEvent("TeleportInside_Global");
            sound.Stop();
            sound.clip = doorOpenSound[Random.Range(0, doorOpenSound.Length)];
            sound.Play();
            EventManager.TriggerEvent("TriggerWindSound",false);
        }
        else
        {
            EventManager.TriggerEvent("PlayerTeleport", Teleport_Outside.position);
            GameManager.Instance.Player.GetComponent<GetParentObject>().parent.GetComponent<FPSCharacterController>().isOutside = true;
            EventManager.TriggerEvent("TriggerThemeSound", "Theme");
            Teleport_Building.teleportOutside?.Invoke();
            EventManager.TriggerEvent("TeleportOutside_Global");
            sound.Stop();
            sound.clip = doorOpenSound[Random.Range(0, doorOpenSound.Length)];
            sound.Play();
            EventManager.TriggerEvent("TriggerWindSound", true);
        }
        transitCoroutine = null;
    }
}
