using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Ungamed.Dismember;

public class BallShooter : MonoBehaviour {
	public GameObject prefab;

	void Update() {
		if (Input.GetMouseButtonDown(0)) {
			Vector3 viewPoint = Camera.main.ScreenToViewportPoint (Input.mousePosition);
			Vector3 worldView = new Vector3 (
				transform.forward.x + (transform.right.x * (viewPoint.x -.5f)),
				transform.forward.y + (transform.up.y * (viewPoint.y -.5f)),
				transform.forward.z);
			GameObject go = Instantiate (prefab, transform.position, Quaternion.identity) as GameObject;
			Rigidbody rb = go.GetComponent<Rigidbody> ();
			rb.AddForce ((worldView.normalized) * 10f, ForceMode.Impulse);
			Destroy (go, 5f);
		}
	}
}
