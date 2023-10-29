using UnityEngine;

namespace Vitals
{
    public class StaminaRegeneration : RegenerationBase
    {
        [SerializeField] private Stamina staminaComponent;
        
        private void Awake() => VitalsComponent = staminaComponent;
    }
}