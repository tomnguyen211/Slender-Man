using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class GrenadeSpawn : MonoBehaviour {
    public GameObject Prefab;
	void Update () {
		if (Input.GetKeyDown(KeyCode.G) || Input.GetKeyDown(KeyCode.F))
        {
            Instantiate(Prefab,transform.position,Quaternion.identity,transform);
        }
	}

}
}