using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
[ExecuteInEditMode]
public class BloodAnimation : MonoBehaviour {

public Texture2D[] Reflection;
public Texture2D[] Opasity;
public Texture2D[] Thickness;
public int Frame;
public Material mat;
public bool on;
bool destroy_;
	void Update () {
		if (on) {
			if (destroy_) {
Dest();
			}
		mat.SetTexture("_Reflection",Reflection[Frame]);
		mat.SetTexture("_Opasity",Opasity[Frame]);
		mat.SetTexture("_Thickness",Thickness[Frame]);
		if (Frame == Opasity.Length - 1){
destroy_ = true;
		}
	}
	}
	void Dest() {
		Destroy(gameObject);
	
	}
}
}