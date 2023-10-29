using UnityEngine;
using UnityEngine.Events;

namespace Vitals
{
    /// <summary>
    /// This class is used as a Unity Event wrapper for the VitalsComponent and RegenerationComponent events.
    /// It can be used for Health and Stamina.
    /// </summary>
    public class VitalsEventWrapper : MonoBehaviour
    {
        /// <summary>
        /// VitalsComponent reference.
        /// </summary>
        [SerializeField] private VitalsBase vitalsComponent;
        /// <summary>
        /// RegenerationComponent reference.
        /// </summary>
        [Header("[Optional]"), SerializeField] private RegenerationBase regenerationComponent;
        [Space(10)]
        
        #region Unity Events
        
        public UnityEvent onValueIncrease;
        public UnityEvent onValueDecrease;
        public UnityEvent onMaxValueIncrease;
        public UnityEvent onMaxValueDecrease;
        public UnityEvent onValueFull;
        public UnityEvent onValueEmpty;
        
        public UnityEvent onRegenerationStart;
        public UnityEvent onRegenerationStop;
        public UnityEvent onDrainStart;
        public UnityEvent onDrainStop;

        #endregion

        #region Initialization

        /// <summary>
        /// Checks if the VitalsComponent and RegenerationComponent references are valid.
        /// Subscribes to the VitalsComponent and RegenerationComponent events.
        /// </summary>
        private void OnEnable()
        {
            if (vitalsComponent == null)
            {
                Debug.LogError("Vitals component is null");
                return;
            }
            vitalsComponent.OnValueIncrease += OnIncrease;
            vitalsComponent.OnValueDecrease += OnDecrease;
            vitalsComponent.OnMaxValueIncrease += OnMaxIncrease;
            vitalsComponent.OnMaxValueDecrease += OnMaxDecrease;
            vitalsComponent.OnValueEmpty += OnDeath;
            vitalsComponent.OnValueFull += OnFullVitals;
            
            if (regenerationComponent == null)
            {
                return;
            }
            regenerationComponent.OnRegenerationStatusChanged += OnRegenerationStatusChanged;
            regenerationComponent.OnDrainStatusChanged += OnDrainStatusChanged;
        }
        
        /// <summary>
        /// Unsubscribes from the VitalsComponent and RegenerationComponent events.
        /// </summary>
        private void OnDisable()
        {
            if (vitalsComponent == null)
            {
                Debug.LogError("Vitals component is null");
                return;
            }
            vitalsComponent.OnValueIncrease -= OnIncrease;
            vitalsComponent.OnValueDecrease -= OnDecrease;
            vitalsComponent.OnMaxValueIncrease -= OnMaxIncrease;
            vitalsComponent.OnMaxValueDecrease -= OnMaxDecrease;
            vitalsComponent.OnValueEmpty -= OnDeath;
            vitalsComponent.OnValueFull -= OnFullVitals;
            
            if (regenerationComponent == null)
            {
                return;
            }
            
            regenerationComponent.OnRegenerationStatusChanged -= OnRegenerationStatusChanged;
            regenerationComponent.OnDrainStatusChanged -= OnDrainStatusChanged;
        }

        #endregion

        #region Event Invokers

        private void OnIncrease() => onValueIncrease?.Invoke();
        private void OnDecrease() => onValueDecrease?.Invoke();

        private void OnMaxIncrease() => onMaxValueIncrease?.Invoke();
        
        private void OnMaxDecrease() => onMaxValueDecrease?.Invoke();
        
        private void OnFullVitals() => onValueFull?.Invoke();
        
        private void OnDeath() => onValueEmpty?.Invoke();
        
        private void OnRegenerationStatusChanged(bool status)
        {
            if (status)
            {
                onRegenerationStart?.Invoke();
            }
            else
            {
                onRegenerationStop?.Invoke();
            }
        }
        
        private void OnDrainStatusChanged(bool status)
        {
            if (status)
            {
                onDrainStart?.Invoke();
            }
            else
            {
                onDrainStop?.Invoke();
            }
        }

        #endregion

    }
}