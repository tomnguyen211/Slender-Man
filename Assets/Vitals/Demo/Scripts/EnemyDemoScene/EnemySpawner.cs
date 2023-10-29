using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Vitals
{
    public class EnemySpawner : MonoBehaviour
    {
        [SerializeField] private Transform enemyPrefab;
        private Camera _camera;

        #region Input

        // The input actions
        public InputActionAsset actions;

        // The actions
        private InputAction _spawn;
        
        private void Awake()
        {
            // Cache camera
            _camera = Camera.main;
            
            // Find the actions
            _spawn = actions.FindActionMap("EnemyDemo").FindAction("Spawn");
            
            // Subscribe to the events
            _spawn.performed += OnSpawn;
        }

        private void OnEnable()
        {
            _spawn.Enable();
        }

        #endregion
        
        private void OnSpawn(InputAction.CallbackContext obj)
        {
            // Handle spawn position
            var mousePosition = Mouse.current.position.ReadValue();
            var spawnPos = GetWorldPosition(mousePosition);
            spawnPos.y = 1f;
            
            // Spawn Enemy
            var enemy = Instantiate(enemyPrefab, spawnPos, Quaternion.identity);
            
            // Setup UI binding
            var health = enemy.GetComponent<Health>();
            var uiBind = enemy.GetComponent<VitalsUIBind>();
            VitalsUtility.Bind(health, uiBind);
        }
        
        private Vector3 GetWorldPosition(Vector2 mousePosition)
        {
            var ray = _camera.ScreenPointToRay(mousePosition);
            return Physics.Raycast(ray, out var hitInfo) ? hitInfo.point : Vector3.zero;
        }
    }
}