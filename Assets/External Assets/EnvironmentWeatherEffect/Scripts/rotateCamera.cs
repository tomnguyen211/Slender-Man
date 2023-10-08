using UnityEngine;
using System.Collections;

public class rotateCamera : MonoBehaviour {

    public float turnSpeed = 50f;
    public int count = 0;
	public int maxCount = 0;
    public bool left = false;

    void Update () {

        if(left) {
			if (count >= maxCount) {
                transform.Rotate(Vector3.up, -turnSpeed * Time.deltaTime);
                count = 0;
                left = false;
            }
            else {
                transform.Rotate(Vector3.up, turnSpeed * Time.deltaTime);
                count++;
            }
        } else {
			if (count >= maxCount) {
                transform.Rotate(Vector3.up, turnSpeed * Time.deltaTime);
                count = 0;
                left = true;
            }
            else {
                transform.Rotate(Vector3.up, -turnSpeed * Time.deltaTime);
                count++;
            }
        }
    }
}