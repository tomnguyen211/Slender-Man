using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class ObjectManager : MonoBehaviour {

public bool on;
public ParticleSpawn PS;
public GameObject[] dest;
public GameObject[] activ;

public bool OnDirectionWeapon;


	void Update () {
		if (on) {
			on = false;
		S();
		}
	}

public void ParticleDirection(Vector3 Direction_) {
	PS.transform.eulerAngles = Direction_;
}
void S() {

for (int i = 0;i < activ.Length;i++) {
		if (activ[i] != null) {
activ[i].SetActive(true);
		}
}
for (int i = 0;i < dest.Length;i++) {
	if (dest[i] != null) {
Destroy(dest[i]);
}
}
}

}
}