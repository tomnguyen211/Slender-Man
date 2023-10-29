using UnityEngine;

namespace Vitals
{
    /// <summary>
    /// A ScriptableObject used for storing and configuring VitalsComponent values.
    /// </summary>
    [CreateAssetMenu(fileName = "Vitals Config", menuName = "Vitals/New Config", order = 0)]
    public class VitalsConfig : ScriptableObject
    {
        /// <summary>
        /// The maximum value of the VitalsComponent.
        /// </summary>
        [Header("Values")]
        public float maxValue;
        
        /// <summary>
        /// The starting value of the VitalsComponent.
        /// </summary>
        public float value;

        /// <summary>
        /// Validates the VitalsConfig values. Ensures that the 'value' doesn't exceed the 'maxValue'.
        /// </summary>
        private void OnValidate()
        {
            if (value > maxValue)
            {
                value = maxValue;
            }
        }
    }
}