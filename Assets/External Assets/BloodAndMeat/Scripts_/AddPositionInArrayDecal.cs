using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class AddPositionInArrayDecal : MonoBehaviour {

GameObject g;

Decal decal;

bool on = true;
	void Start () {
	g = GameObject.Find("/ArrayDecal");
	decal = g.GetComponent<Decal>();
	}
	
void OnCollisionEnter(Collision collision)
    {
		if (on) {
if (collision.transform.tag == "WallsAndGround") {

Vector4 vector;
vector = transform.position;
vector.w = Random.Range(-3.0f,3.0f);
decal.VectorAdd[decal.SizeArray] = vector;
decal.SizeArray++;
decal.SizeArrayClamp++;
if (decal.SizeArray == decal.MaxSize) {
decal.SizeArray = 0;
}

on = false;
}

}
	}

}
}