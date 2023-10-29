using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GlassBreak : MonoBehaviour
{
    public Transform VFX;
    private float hitToBreak;
    public string gameObjectTag;
    public Transform VFXSocket;

    void Start()
    {
        hitToBreak = 2;
    }

    void OnCollisionEnter(Collision collision)
    {
        if(collision.gameObject.CompareTag(gameObjectTag))
        {
            hitToBreak += -1;
            if(hitToBreak <= 0 )
            {
                glassBreak();
            }
            
        }
        
    }
    void glassBreak()
    {   
        if(VFX != null)
        {
            Instantiate(VFX, VFXSocket.position, VFXSocket.rotation);
            Destroy(gameObject);
        }
    }
}
