using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class SnapInVertex : MonoBehaviour {
     Transform clothObject;
    public Cloth cloth;
    public bool on;
public float time = 10;
    int index__;

    public bool snap;
    Vector3 dir;

    void Start()
    {
        if (on)
        {
            clothObject = cloth.transform;
            index__ = Random.Range(0, cloth.vertices.Length);
           Invoke("Dest",time);


            on = false;
            snap = true;
        }
    } 
     void Update()
    {
       
        if (snap) {
            if (clothObject == null)
            {
                clothObject = cloth.transform;
            }
            dir = cloth.normals[index__];
            transform.position = cloth.vertices[index__] + clothObject.position;
            transform.rotation = Quaternion.FromToRotation(Vector3.up, dir);
        }
    }
    	void Dest(){
		Destroy(this);
	}

}
}