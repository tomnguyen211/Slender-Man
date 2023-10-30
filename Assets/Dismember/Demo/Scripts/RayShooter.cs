using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Ungamed.Dismember;

public class RayShooter : Damage {
	void Update() {
		if (Input.GetMouseButtonDown(0)) {
			TryFire (Camera.main.ScreenPointToRay (Input.mousePosition));
		}
	}
}
