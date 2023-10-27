using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class BoneClamp : MonoBehaviour {

public Transform ParentBone;

public float MaxDist;

	void Update () {
		Vector3 pos;
		pos = transform.position;
		pos.x = Mathf.Clamp(pos.x,ParentBone.position.x - MaxDist,ParentBone.position.x + MaxDist);
		pos.y = Mathf.Clamp(pos.y,ParentBone.position.y - MaxDist,ParentBone.position.y + MaxDist);
		pos.z = Mathf.Clamp(pos.z,ParentBone.position.z - MaxDist,ParentBone.position.z + MaxDist);
		transform.position = pos;
	}
}
}