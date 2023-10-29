using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Vitals
{
    public class CanvasLook : MonoBehaviour
    {
        private Transform _cameraTransform;
        
        private void Awake()
        {
            _cameraTransform = Camera.main.transform;
        }
        void Update()
        {
            transform.LookAt(_cameraTransform);
        }
    }
}
