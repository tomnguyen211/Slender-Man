using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class Shoting : MonoBehaviour {

public GameObject Prefab;
	void Update () {
		        RaycastHit hit;
        if (Input.GetKeyDown(KeyCode.Mouse0)) {
        if (Physics.Raycast(transform.position, transform.forward, out hit, 1000.0f))
        {
if (hit.collider.tag == "target") {
if (hit.transform.GetComponent<ObjectManager>().OnDirectionWeapon) {
hit.transform.GetComponent<ObjectManager>().ParticleDirection(transform.forward * -1);
}
hit.transform.GetComponent<ObjectManager>().on = true;
}
if (hit.collider.tag == "zombie") {
Instantiate(Prefab, hit.point, Quaternion.LookRotation(hit.normal));
}
        }
	}
	}
}
}