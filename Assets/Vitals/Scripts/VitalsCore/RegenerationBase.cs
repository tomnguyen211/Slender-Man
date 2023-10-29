using System;
using UnityEngine;

namespace Vitals
{
    /// <summary>
    /// A base class for Regeneration that inherits from MonoBehaviour and implements the IRegeneration interface.
    /// </summary>
    public abstract class RegenerationBase : MonoBehaviour, IRegeneration
    {
        #region Dependencies

        /// <summary>
        /// Reference to the VitalsBase component.
        /// </summary>
        protected VitalsBase VitalsComponent;

        #endregion
        
        #region Interface Properties

        /// <summary>
        /// Rate of regeneration per second.
        /// </summary>
        [field: SerializeField, Header("Configuration")] public float RegenerationRate { get; private set; }
        
        /// <summary>
        /// Indicates whether regeneration is active or not.
        /// </summary>
        public bool IsRegenerating { get; private set;}
        
        /// <summary>
        /// Rate of drain per second.
        /// </summary>
        [field: SerializeField]  public float DrainRate { get; private set;}
        
        /// <summary>
        /// Indicates whether draining is active or not.
        /// </summary>
        public bool IsDraining { get; private set;}

        #endregion

        #region Unity Methods
        
        /// <summary>
        /// Called when the script instance is enabled.
        /// Ensures the VitalsComponent is present and sets the Regeneration for the VitalsComponent.
        /// </summary>
        private void OnEnable()
        {
            if (!VitalsComponent)
            {
                Debug.LogError("Regeneration Component is missing Vitals Component on " + gameObject.name + " game object.");
                return;
            }
            VitalsComponent.SetRegeneration(this);
        }

        /// <summary>
        /// Called every frame.
        /// Handles the <c>Regenerate</c> and <c>Drain</c> methods based on the current state.
        /// </summary>
        private void Update()
        {
            if (IsRegenerating)
            {
                Regenerate();
            }
            
            if (IsDraining)
            {
                Drain();
            }
        }

        #endregion
        
        #region Interface Events

        /// <summary>
        /// Event triggered when the regeneration status changes.
        /// </summary>
        public event Action<bool> OnRegenerationStatusChanged;
        
        /// <summary>
        /// Event triggered when the drain status changes.
        /// </summary>
        public event Action<bool> OnDrainStatusChanged;

        #endregion

        #region Interface Methods

        /// <summary>
        /// Starts regeneration and stops draining if active.
        /// </summary>
        public void StartRegeneration()
        {
            StopDrain();
            IsRegenerating = true;
            OnRegenerationStatusChanged?.Invoke(IsRegenerating);
        }

        /// <summary>
        /// Stops regeneration.
        /// </summary>
        public void StopRegeneration()
        {
            IsRegenerating = false;
            OnRegenerationStatusChanged?.Invoke(IsRegenerating);
        }

        /// <summary>
        /// Starts draining and stops regeneration if active.
        /// </summary>
        public void StartDrain()
        {
            StopRegeneration();
            IsDraining = true;
            OnDrainStatusChanged?.Invoke(IsDraining);
        }

        /// <summary>
        /// Stops draining.
        /// </summary>
        public void StopDrain()
        {
            IsDraining = false;
            OnDrainStatusChanged?.Invoke(IsDraining);
        }
        
        /// <summary>
        /// Sets the regeneration rate.
        /// </summary>
        /// <param name="rate">The new rate value.</param>
        public void SetRegenerationRate(float rate)
        {
            RegenerationRate = rate;
        }

        /// <summary>
        /// Sets the drain rate.
        /// </summary>
        /// <param name="rate">The new rate value.</param>
        public void SetDrainRate(float rate)
        {
            DrainRate = rate;
        }

        #endregion

        #region Private Methods

        /// <summary>
        /// Handles the regeneration using the <c>Increase</c> method without triggering events based on the RegenerationRate.
        /// Stops regeneration when VitalsComponent is full.
        /// </summary>
        private void Regenerate()
        {
            var rate = RegenerationRate * Time.deltaTime;
            VitalsComponent.Increase(rate, false, true);
            
            if (VitalsUtility.IsFull(VitalsComponent))
                StopRegeneration();
        }

        /// <summary>
        /// Handles the draining using the <c>Decrease</c> method without triggering events based on the DrainRate.
        /// Stops regeneration when VitalsComponent is full.
        /// </summary>
        private void Drain()
        {
            var rate = DrainRate * Time.deltaTime;
            VitalsComponent.Decrease(rate, false, true);
            
            if (VitalsUtility.IsEmpty(VitalsComponent))
                StopDrain();
        }

        #endregion
    }
}