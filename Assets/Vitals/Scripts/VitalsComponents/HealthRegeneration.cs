using UnityEngine;

namespace Vitals
{
    public class HealthRegeneration : RegenerationBase
    {
        [SerializeField] private Health healthComponent;

        /// <summary>
        /// Gets the VitalsComponent reference.
        /// </summary>
        private void Awake() => VitalsComponent = healthComponent;
    }
}