using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class MouseCamera : MonoBehaviour {
public float m_LookSpeedMouse = 10.0f;
        private static string kMouseX = "Mouse X";
        private static string kMouseY = "Mouse Y";
        private static string kRightStickX = "Controller Right Stick X";
        private static string kRightStickY = "Controller Right Stick Y";
		
	void Update () {

if (Input.GetKeyDown(KeyCode.Mouse0) || Input.GetKeyDown(KeyCode.Mouse1)) {
Cursor.visible = false;
  Cursor.lockState = CursorLockMode.Locked;
}
if (Input.GetKeyDown(KeyCode.Escape)) {
Cursor.visible = true;
  Cursor.lockState = CursorLockMode.None;
}

		    float inputRotateAxisX = 0.0f;
            float inputRotateAxisY = 0.0f;

 float rotationX = transform.localEulerAngles.x;

inputRotateAxisX = Input.GetAxis(kMouseX) * m_LookSpeedMouse;
                inputRotateAxisY = Input.GetAxis(kMouseY) * m_LookSpeedMouse;
            

 
                float newRotationY = transform.localEulerAngles.y + inputRotateAxisX;

           
                float newRotationX = (rotationX - inputRotateAxisY);
                if (rotationX <= 90.0f && newRotationX >= 0.0f)
                    newRotationX = Mathf.Clamp(newRotationX, 0.0f, 90.0f);
                if (rotationX >= 270.0f)
                    newRotationX = Mathf.Clamp(newRotationX, 270.0f, 360.0f);




		transform.localRotation = Quaternion.Euler(newRotationX, newRotationY, transform.localEulerAngles.z);
	}



}
}