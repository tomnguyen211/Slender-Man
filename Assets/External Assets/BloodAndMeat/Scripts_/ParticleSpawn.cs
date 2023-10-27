using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class ParticleSpawn : MonoBehaviour {

public bool on;
public GameObject Prefab;


	void Update () {
		if (on) {
		Vector3 v = new Vector3(0,0,0);
		v.x = transform.eulerAngles.x;
		v.y = transform.eulerAngles.y;
		v.z = transform.eulerAngles.z;
		if (Prefab != null) {
			Instantiate(Prefab, transform.position, Quaternion.Euler(v));
		}
on = false;
		}
	}
}
}