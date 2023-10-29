using UnityEngine;

namespace Vitals
{
    public class VitalsDemoScript : MonoBehaviour
    {
        [SerializeField] private DemoCharacter character;

        #region Health Methods

        public void Heal(float amount) => character.Health.Increase(amount);

        public void Damage(float amount) => character.Health.Decrease(amount);
        
        public void IncreaseMaxHealth(float amount) => character.Health.IncreaseMax(amount);
        
        public void DecreaseMaxHealth(float amount) => character.Health.DecreaseMax(amount);

        public void StartHealthRegeneration() => character.Health.Regeneration.StartRegeneration();

        public void StopHealthRegeneration() => character.Health.Regeneration.StopRegeneration();

        public void StartHealthDrain() => character.Health.Regeneration.StartDrain();

        public void StopHealthDrain() => character.Health.Regeneration.StopDrain();
        
        public void StartTimedHealthRegeneration(float duration) => VitalsUtility.RegenerateAtRateForTime(character.Health, character.Health.Regeneration.RegenerationRate, duration);
        
        public void StartTimedHealthDrain(float duration) => VitalsUtility.DrainAtRateForTime(character.Health, character.Health.Regeneration.DrainRate, duration);

        #endregion

        #region Stamina Methods

        public void RestoreStamina(float amount) => character.Stamina.Increase(amount);

        public void ConsumeStamina(float amount) => character.Stamina.Decrease(amount);
        
        public void IncreaseMaxStamina(float amount) => character.Stamina.IncreaseMax(amount);
        
        public void DecreaseMaxStamina(float amount) => character.Stamina.DecreaseMax(amount);
        
        public void StartStaminaRegeneration() => character.Stamina.Regeneration.StartRegeneration();
        
        public void StopStaminaRegeneration() => character.Stamina.Regeneration.StopRegeneration();
        
        public void StartStaminaDrain() => character.Stamina.Regeneration.StartDrain();
        
        public void StopStaminaDrain() => character.Stamina.Regeneration.StopDrain();
        
        public void StartTimedStaminaRegeneration(float duration) => VitalsUtility.RegenerateAtRateForTime(character.Stamina, character.Stamina.Regeneration.RegenerationRate, duration);
        
        public void StartTimedStaminaDrain(float duration) => VitalsUtility.DrainAtRateForTime(character.Stamina, character.Stamina.Regeneration.DrainRate, duration);
        
        #endregion
    }
}
