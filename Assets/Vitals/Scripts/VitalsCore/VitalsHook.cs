using System;
using UnityEngine;

namespace Vitals
{
    /// <summary>
    /// A ScriptableObject used for binding UI elements to a VitalsComponent. This class updates and manages the values displayed in the UI.
    /// </summary>
    [CreateAssetMenu(fileName = "Vitals Hook", menuName = "Vitals/New Hook", order = 0)]
    public class VitalsHook : ScriptableObject
    {
        private bool _initialized;
        
        /// <summary>
        /// Returns true if the VitalsHook has been initialized.
        /// </summary>
        public bool Initialized => _initialized;
        
        /// <summary>
        /// The current value of the VitalsComponent.
        /// </summary>
        public float Value { get; private set; }
        
        /// <summary>
        /// The maximum value of the VitalsComponent.
        /// </summary>
        public float MaxValue { get; private set; }
        
        /// <summary>
        /// Event that gets triggered when the VitalsComponent values change.
        /// </summary>
        public event Action<float, float, bool> OnValueChanged;
        
        /// <summary>
        /// Initializes the VitalsHook and subscribes to the OnValueChanged event of the VitalsComponent.
        /// </summary>
        /// <param name="vitalsBase">The VitalsComponent to subscribe to.</param>
        public void Initialize(VitalsBase vitalsBase)
        {
            vitalsBase.OnValueChanged += UpdateValues;
            _initialized = true;
            UpdateValues(vitalsBase.Value, vitalsBase.MaxValue, false);
        }
        
        /// <summary>
        /// Unsubscribes the VitalsHook from the OnValueChanged event of the VitalsComponent.
        /// </summary>
        /// <param name="vitalsBase">The VitalsComponent to unsubscribe from.</param>
        public void Unsubscribe(VitalsBase vitalsBase)
        {
            vitalsBase.OnValueChanged -= UpdateValues;
            _initialized = false;
        }

        /// <summary>
        /// Updates the values of the VitalsHook and invokes the OnValueChanged event.
        /// </summary>
        /// <param name="value">The current value of the VitalsComponent.</param>
        /// <param name="maxValue">The maximum value of the VitalsComponent.</param>
        /// <param name="isDrain">If change is caused by the regeneration component</param>
        private void UpdateValues(float value, float maxValue, bool isDrain)
        {
            Value = value;
            MaxValue = maxValue;
            OnValueChanged?.Invoke(value, maxValue, isDrain);
        }
    }
}