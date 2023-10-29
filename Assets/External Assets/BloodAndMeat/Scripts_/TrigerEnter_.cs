using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class TrigerEnter_ : MonoBehaviour {

void OnTriggerEnter(Collider col) {

            
        
	if (col.tag == "Bomb") {
col.transform.GetComponent<ExplosionEnter>().on = true;
	}
}

}
}