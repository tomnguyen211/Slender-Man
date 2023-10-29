using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class SpawnObjects : MonoBehaviour {
public float time = 4;
public GameObject Prefab;
	void Update () {
		Invoke("spawn",time);
	}
	void spawn (){
Instantiate(Prefab,transform.position,Quaternion.identity);
	}
}
}