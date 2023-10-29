using System.Threading.Tasks;
using UnityEngine;

namespace Vitals
{
    public static class VitalsUtility
    {
        #region Helpers

        /// <summary>
        /// Returns the percentage of the vitals value to the max value.
        /// </summary>
        public static float GetPercentage(VitalsBase vitals)
        {
            return vitals.Value / vitals.MaxValue;
        }
        
        /// <summary>
        /// Another variation of the GetPercentage method. This one takes a VitalsHook instead of a VitalsBase.
        /// This is used by VitalsUIBinding to get the percentage of the vitals value to the max value.
        /// </summary>
        public static float GetPercentage(VitalsHook vitals)
        {
            return vitals.Value / vitals.MaxValue;
        }
        
        /// <summary>
        /// Another variation of the GetPercentage method. This one takes a current and max value instead of a VitalsBase.
        /// </summary>
        public static float GetPercentage(float value, float maxValue)
        {
            return value / maxValue;
        }

        #endregion

        #region Value Manipulation

        /// <summary>
        /// Increases the vitals value by the given percentage.
        /// </summary>
        /// <param name="vitals">The component to be manipulated</param>
        /// <param name="percentage">A float between 0 and 1</param>
        public static void IncreaseByPercentage(VitalsBase vitals, float percentage)
        {
            if (!IsValidPercentage(percentage))
            {
                Debug.Log("Invalid percentage value. Percentage must be between 0 and 1.");
                return;
            }
            vitals.Increase(vitals.Value * percentage);
        }
        
        /// <summary>
        /// Decreases the vitals value by the given percentage.
        /// </summary>
        /// <param name="vitals">The component to be manipulated</param>
        /// <param name="percentage">A float between 0 and 1</param>
        public static void DecreaseByPercentage(VitalsBase vitals, float percentage)
        {
            if (!IsValidPercentage(percentage))
            {
                Debug.Log("Invalid percentage value. Percentage must be between 0 and 1.");
                return;
            }
            vitals.Decrease(vitals.Value * percentage);
        }
        
        /// <summary>
        /// Increases the max value of the vitals by the given percentage.
        /// </summary>
        /// <param name="vitals">The component to be manipulated</param>
        /// <param name="percentage">A float between 0 and 1</param>
        public static void IncreaseMaxByPercentage(VitalsBase vitals, float percentage)
        {
            if (!IsValidPercentage(percentage))
            {
                Debug.Log("Invalid percentage value. Percentage must be between 0 and 1.");
                return;
            }
            vitals.IncreaseMax(vitals.MaxValue * percentage);
        }
        
        /// <summary>
        /// Decreases the max value of the vitals by the given percentage.
        /// </summary>
        /// <param name="vitals">The component to be manipulated</param>
        /// <param name="percentage">A float between 0 and 1</param>
        public static void DecreaseMaxByPercentage(VitalsBase vitals, float percentage)
        {
            if (!IsValidPercentage(percentage))
            {
                Debug.Log("Invalid percentage value. Percentage must be between 0 and 1.");
                return;
            }
            vitals.DecreaseMax(vitals.MaxValue * percentage);
        }
        
        /// <summary>
        /// Drains the vitals value at the given rate for the given time.
        /// </summary>
        /// <param name="vitals">Vitals component to drain</param>
        /// <param name="drainRate">Drain rate per second</param>
        /// <param name="drainTime">Drain Time</param>
        public static async void DrainAtRateForTime(VitalsBase vitals, float drainRate, float drainTime)
        {
            if (!IsValidAmount(drainRate))
            {
                Debug.Log("Invalid drain rate value. Drain rate must be bigger than 0.");
                return;
            }
            if (!IsValidAmount(drainTime))
            {
                Debug.Log("Invalid drain time value. Drain time must be bigger than 0.");
                return;
            }

            if (!vitals.Regeneration)
            {
                Debug.Log("Vitals component does not have the regeneration extension.");
                return;
            }
            var initialDrainRate = vitals.Regeneration.DrainRate;
            vitals.Regeneration.SetDrainRate(drainRate);
            vitals.Regeneration.StartDrain();
            await Task.Delay((int) (drainTime * 1000));
            vitals.Regeneration.StopDrain();
            vitals.Regeneration.SetDrainRate(initialDrainRate);
        }
        
        /// <summary>
        /// Regenerates the vitals value at the given rate for the given time.
        /// </summary>
        /// <param name="vitals">Vitals component to regenerate</param>
        /// <param name="regenerationRate">Regeneration rate per second</param>
        /// <param name="regenerationTime">Regeneration time</param>
        public static async void RegenerateAtRateForTime(VitalsBase vitals, float regenerationRate, float regenerationTime)
        {
            if (!IsValidAmount(regenerationRate))
            {
                Debug.Log("Invalid regeneration rate value. Regeneration rate must be bigger than 0.");
                return;
            }
            if (!IsValidAmount(regenerationTime))
            {
                Debug.Log("Invalid regeneration time value. Regeneration time must be bigger than 0.");
                return;
            }

            if (!vitals.Regeneration)
            {
                Debug.Log("Vitals component does not have the regeneration extension.");
                return;
            }
            var initialRegenerationRate = vitals.Regeneration.RegenerationRate;
            vitals.Regeneration.SetRegenerationRate(regenerationRate);
            vitals.Regeneration.StartRegeneration();
            await Task.Delay((int) (regenerationTime * 1000));
            vitals.Regeneration.StopRegeneration();
            vitals.Regeneration.SetRegenerationRate(initialRegenerationRate);
        }

        #endregion

        #region Verification Methods

        /// <summary>
        /// Checks if the given percentage is between 0 and 1.
        /// </summary>
        /// <returns>True if the percentage value is valid</returns>
        public static bool IsValidPercentage(float percentage)
        {
            return percentage is >= 0 and <= 1;
        }
        
        /// <summary>
        /// Checks if the given amount is greater than or equal to 0.
        /// Since Increase and Decrease can't take negative values, this method is used to validate the amount.
        /// </summary>
        /// <returns>True if the amount is equals or bigger than 0</returns>
        public static bool IsValidAmount(float amount)
        {
            return amount >= 0;
        }
        
        /// <summary>
        /// Checks if the vitals value is equals or bigger than the max value.
        /// </summary>
        /// <returns>True if the current value is equals to or bigger than max value</returns>
        public static bool IsFull(VitalsBase vitals)
        {
            return vitals.Value >= vitals.MaxValue;
        }
        
        /// <summary>
        /// Checks if the vitals value is equals or smaller than 0.
        /// </summary>
        /// <returns>True if the current value is equals to or smaller than 0</returns>
        public static bool IsEmpty(VitalsBase vitals)
        {
            return vitals.Value <= 0f;
        }

        #endregion

        #region Instantiation Methods

        /// <summary>
        /// Creates a VitalsHook at runtime to bind the UI to a vitals component.
        /// </summary>
        /// <param name="vitals">The vitals component to bind</param>
        /// <param name="vitalsUIBind">The vitals UI component to bind to</param>
        public static void Bind(VitalsBase vitals, VitalsUIBind vitalsUIBind)
        {
            VitalsHook hook = ScriptableObject.CreateInstance<VitalsHook>();
            vitalsUIBind.Initialize(hook);
            vitals.SetHook(hook);
            hook.Initialize(vitals);
        }

        #endregion
    }
}
