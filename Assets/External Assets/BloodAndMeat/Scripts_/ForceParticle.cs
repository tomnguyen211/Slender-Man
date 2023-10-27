using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class ForceParticle : MonoBehaviour {
    public Rigidbody rb;
    int n;
    public float force;
    public bool on;
    public bool AutoParent;
    public Vector3 AddRotation; 

    public Transform ParentDirection;
        Transform parent_;
        bool R = false;


	
	void Update () {

        if (on && n < 1)
        {
                
                if (transform.parent != null) {
                    parent_ = transform.parent;
                }
            if (AutoParent) {
ParentDirection = transform.parent.transform;
            }
            rb.AddForce(ParentDirection.forward * force);
            if (AutoParent) {
parent_ = null;
            }
                if (parent_ != null) {
                    transform.parent = parent_;
                }
                else {
                    transform.parent = null;
                }
R = true;
        }
        if (R){
  n++;
                          if (n > 150)
            {
                 on = false;
                Destroy(this);
            }
            Quaternion rot;
            rot = transform.rotation;
            rot.x += AddRotation.x;
            rot.y += AddRotation.y;
            rot.z += AddRotation.z;

        }
	}

}
}