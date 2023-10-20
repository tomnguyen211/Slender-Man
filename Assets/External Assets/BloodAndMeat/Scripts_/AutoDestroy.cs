using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class AutoDestroy : MonoBehaviour {

public float time = 10;
	public bool on;
	
	void Update () {
		if (on) {
		Invoke("Dest",time);
	}
	}
	void Dest(){
		Destroy(gameObject);
	}
}
}