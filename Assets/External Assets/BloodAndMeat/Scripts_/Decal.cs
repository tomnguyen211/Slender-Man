using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class Decal : MonoBehaviour {


public Material[] material;
public bool on;
public Vector4[] VectorAdd;

public int SizeArray;
[HideInInspector]
public int SizeArrayClamp = 0;
[Range(0, 40)]
public int MaxSize = 30;
bool Clamp;

	void Update () {
		if (on) {

if (SizeArrayClamp > MaxSize - 1) {
Clamp = true;
}
if (Clamp == true) {
SizeArrayClamp = MaxSize;
}
for (int i = 0;i < material.Length;i++) {
material[i].SetInt("LengthArray",SizeArrayClamp);
material[i].SetVectorArray("BloodPointArray",VectorAdd);
		}
		}
	}

}
}