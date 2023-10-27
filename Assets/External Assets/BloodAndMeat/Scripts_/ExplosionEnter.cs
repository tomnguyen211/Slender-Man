using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class ExplosionEnter : MonoBehaviour {

public bool on;
public GameObject[] dest;
public GameObject[] activ;
	void Update () {
		if (on) {
for (int i = 0;i < activ.Length;i++) {
	if (activ[i] != null){
activ[i].SetActive(true);
}
}
for (int i = 0;i < dest.Length;i++) {
	if (dest[i] != null){
dest[i].SetActive(false);
	}
}

		}
	}
}
}