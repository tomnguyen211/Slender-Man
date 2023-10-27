using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class PlayerController : MonoBehaviour {




	public float Speed;
	public Transform camera;
	Vector3 moveVector;
public CharacterController CC;
	void Update () {



         moveVector = Vector3.zero;
 
         //Check if cjharacter is grounded
         if (CC.isGrounded == false)
         {
             //Add our gravity Vecotr
             moveVector += Physics.gravity;
			 CC.Move(moveVector * Speed);
         }


		if (Input.GetKey(KeyCode.W)) {
CC.Move(camera.forward * Speed);
		}
		if (Input.GetKey(KeyCode.S)) {
CC.Move(camera.forward * Speed * -1);
		}
		if (Input.GetKey(KeyCode.A)) {
CC.Move(camera.right * Speed * -1);
		}
		if (Input.GetKey(KeyCode.D)) {
CC.Move(camera.right * Speed);
		}
	}

}
}