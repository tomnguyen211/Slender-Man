using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class StartMoveMeat : MonoBehaviour {
    int t;
    public float force;
    public float oldVelosity = 0.5f;
    public float NewVelosity = 40;
    Vector3 pos;
    Vector3 pos2;
    void Update () {
        t++;

        if (t == 1)
        {
            pos2 = transform.position;
            pos2 += Vector3.down * force;
            transform.position = pos2;
            GetComponent<Cloth>().worldVelocityScale = NewVelosity;

        }

            if (t == 2)
        {
            
            pos = transform.position;
            pos -= Vector3.down * force;
            transform.position = pos;
            
        }
        if (t == 3)
        {
            pos = transform.position;
            pos += Vector3.down * 0.01f;
            transform.position = pos;
        }
            if (t > 10)
        {
            GetComponent<Cloth>().worldVelocityScale = oldVelosity;
            Destroy(this);
        }
        }
}
}