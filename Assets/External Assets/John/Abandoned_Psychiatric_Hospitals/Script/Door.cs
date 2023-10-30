using Unity.Collections;
using UnityEngine;
using UnityEngine.UI;

public class Door : MonoBehaviour
{
    [SerializeField,ReadOnly]
    bool trig, open;//trig-проверка входа выхода в триггер(игрок должен быть с тегом Player) open-закрыть и открыть дверь
    public float smooth = 2.0f;//скорость вращения
    public float DoorOpenAngle = 90.0f;//угол вращения
  
    Quaternion DoorOpen;
    Quaternion DoorClosed;

    [SerializeField]
    bool isOpen;

    public Text txt;//text 
    // Start is called before the first frame update
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

    // Update is called once per frame
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
        if (coll.tag == "Player")
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
        if (coll.tag == "Player")
        {
            //txt.text = " ";
            trig = false;
        }
    }
}
