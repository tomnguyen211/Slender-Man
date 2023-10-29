using System;
using UnityEngine;

namespace Vitals
{
    /// <summary>
    /// A base class for managing Vitals in a game, implementing the IVitalsComponent interface.
    /// </summary>
    [DefaultExecutionOrder(-10)]
    public abstract class VitalsBase : MonoBehaviour, IVitalsComponent
    {
        [Header("Config")]
        [SerializeField] private VitalsConfig vitalsConfig;
        
        /// <summary>
        /// The VitalsConfig asset containing the initial configuration for this VitalsComponent.
        /// </summary>
        public VitalsConfig VitalsConfig => vitalsConfig;
        
        #region Variables

        /// <summary>
        /// The current value of this VitalsComponent.
        /// </summary>
        public float Value { get; private set; }

        /// <summary>
        /// The maximum value that this VitalsComponent can have.
        /// </summary>
        public float MaxValue { get; private set; }

        #endregion

        #region Settings

        /// <summary>
        /// If true, saves the value and max value of this VitalsComponent to a binary file when the application quits.
        /// </summary>
        [Header("Settings")] 
        [SerializeField] private bool saveOnQuit;
        
        /// <summary>
        /// If true, loads the value and max value of this VitalsComponent from a binary file when the application starts if a save already exists.
        /// </summary>
        [SerializeField] private bool loadOnStart;
        
        [Header("[Optional]"), SerializeField] private VitalsHook vitalsHook;

        #endregion

        #region Unity Methods

        private void OnValidate()
        {
            if (VitalsConfig && !Application.isPlaying)
                Reload();
        }

        private void Awake()
        {
            if (!VitalsConfig)
            {
                Debug.LogError("Vitals Config is not assigned on " + gameObject.name + " game object.");
            }
            
        }

        protected virtual void Start()
        {
            if (!loadOnStart)
            {
                Reload();
                return;
            }

            VitalsSaveUtility.Load(this);
        }

        /// <summary>
        /// Called when the script instance is enabled.
        /// Initializes and subscribes to the VitalsHook if one is present.
        /// </summary>
        private void OnEnable()
        {
            if (vitalsHook)
            {
                vitalsHook.Initialize(this);
            }
        }

        /// <summary>
        /// Called when the script instance is disabled.
        /// Unsubscribes from the VitalsHook if one is present.
        /// </summary>
        private void OnDisable()
        {
            if (vitalsHook)
            {
                vitalsHook.Unsubscribe(this);
            }
        }

        /// <summary>
        /// Called when the application is quitting.
        /// Saves the current state of the VitalsComponent if saveOnQuit is true.
        /// </summary>
        protected virtual void OnApplicationQuit()
        {
            if (saveOnQuit)
            {
                VitalsSaveUtility.Save(this);
            }
        }

        #endregion

        #region Editor Methods

        /// <summary>
        /// Reloads the VitalsComponent values from the VitalsConfig.
        /// </summary>
        public void Reload()
        {
            SetMax(vitalsConfig.maxValue);
            Set(vitalsConfig.value);
        }

        #endregion

        #region Internal Events

        /// <summary>
        /// Event triggered when the VitalsComponent value or maximum value changes.
        /// </summary>
        public event Action<float, float, bool> OnValueChanged;

        #endregion

        #region Interface Events

        /// <summary>
        /// Event triggered when the VitalsComponent value increases.
        /// </summary>
        public event Action OnValueIncrease;
        
        /// <summary>
        /// Event triggered when the VitalsComponent value decreases.
        /// </summary>
        public event Action OnValueDecrease;
        /// <summary>
        /// Event triggered when the VitalsComponent maximum value increases.
        /// </summary>
        public event Action OnMaxValueIncrease;
    
        /// <summary>
        /// Event triggered when the VitalsComponent maximum value decreases.
        /// </summary>
        public event Action OnMaxValueDecrease;
    
        /// <summary>
        /// Event triggered when the VitalsComponent value reaches its maximum value.
        /// </summary>
        public event Action OnValueFull;
    
        /// <summary>
        /// Event triggered when the VitalsComponent value reaches 0.
        /// </summary>
        public event Action OnValueEmpty;

        #endregion
        
        #region Interface Methods

        /// <summary>
        /// Increases the VitalsComponent value by a specified amount.
        /// </summary>
        /// <param name="amount">The amount to increase the value by.</param>
        /// <param name="triggerEvents">Whether to trigger value change events.</param>
        /// <param name="isDrain">If increase is caused by the regeneration component</param>
        public virtual void Increase(float amount, bool triggerEvents = true, bool isDrain = false)
        {
            if (!VitalsUtility.IsValidAmount(amount))
            {
                Debug.LogError("Amount can't be negative.");
                return;
            }
            
            if (Value >= MaxValue)
            {
                Debug.Log("Value is already full.");
                return;
            }
            
            Value += amount;
            Value = Mathf.Clamp(Value, 0f, MaxValue);
            OnValueChanged?.Invoke(Value, MaxValue, isDrain);
            
            if (triggerEvents)
                OnValueIncrease?.Invoke();
            if (Value >= MaxValue)
            {
                OnValueFull?.Invoke();
            }
        }

        /// <summary>
        /// Decreases the VitalsComponent value by a specified amount.
        /// </summary>
        /// <param name="amount">The amount to decrease the value by.</param>
        /// <param name="triggerEvents">Whether to trigger value change events.</param>
        /// <param name="isDrain">If increase is caused by the regeneration component</param>
        public virtual void Decrease(float amount, bool triggerEvents = true, bool isDrain = false)
        {
            if (!VitalsUtility.IsValidAmount(amount))
            {
                Debug.LogError("Amount can't be negative.");
                return;
            }
            
            if (Value <= 0f)
            {
                Debug.Log("Value is already empty.");
                return;
            }
            
            Value -= amount;
            Value = Mathf.Clamp(Value, 0f, MaxValue);
            OnValueChanged?.Invoke(Value, MaxValue, isDrain);
            
            if (triggerEvents)
                OnValueDecrease?.Invoke();
            
            if (Value <= 0f)
            {
                OnValueEmpty?.Invoke();
            }
        }

        /// <summary>
        /// Increases the maximum value of the VitalsComponent by a specified amount.
        /// </summary>
        /// <param name="amount">The amount to increase the maximum value by.</param>
        public virtual void IncreaseMax(float amount)
        {
            if (!VitalsUtility.IsValidAmount(amount))
            {
                Debug.LogError("Amount can't be negative.");
                return;
            }
            
            MaxValue += amount;
            OnValueChanged?.Invoke(Value, MaxValue, false);
            
            OnMaxValueIncrease?.Invoke();
        }
        
        /// <summary>
        /// Decreases the maximum value of the VitalsComponent by a specified amount.
        /// </summary>
        /// <param name="amount">The amount to decrease the maximum value by.</param>
        public virtual void DecreaseMax(float amount)
        {
            if (!VitalsUtility.IsValidAmount(amount))
            {
                Debug.LogError("Amount can't be negative.");
                return;
            }
            
            MaxValue -= amount;
            
            if (MaxValue <= 0f)
            {
                Debug.LogError("Max Value can't be negative.");
                return;
            }
            OnValueChanged?.Invoke(Value, MaxValue, false);
            
            OnMaxValueDecrease?.Invoke();
            if (Value > MaxValue)
            {
                Value = MaxValue;
                OnValueFull?.Invoke();
            }
        }
        
        /// <summary>
        /// Sets the VitalsComponent value to a specified amount.
        /// </summary>
        /// <param name="value">The amount to set the value to.</param>
        public virtual void Set(float value)
        {
            if (!VitalsUtility.IsValidAmount(value))
            {
                Debug.LogError("Set Value can't be negative.");
                return;
            }
            Value = Mathf.Clamp(value, 0f, MaxValue);
            OnValueChanged?.Invoke(Value, MaxValue, false);
            
            if (Value <= 0f)
            {
                OnValueEmpty?.Invoke();
            }
            else if (Value >= MaxValue)
            {
                OnValueFull?.Invoke();
            }
        }
        
        /// <summary>
        /// Sets the maximum value of the VitalsComponent to a specified amount.
        /// </summary>
        /// <param name="value">The amount to set the maximum value to.</param>
        public virtual void SetMax(float value)
        {
            if (!VitalsUtility.IsValidAmount(value))
            {
                Debug.LogError("Set Value can't be negative.");
                return;
            }
            
            MaxValue = value;
            OnValueChanged?.Invoke(Value, MaxValue, false);
            
            if (Value > MaxValue)
            {
                Value = MaxValue;
                OnValueFull?.Invoke();
            }
        }

        #endregion

        #region Regeneration Extension

        private RegenerationBase _regeneration;
        
        /// <summary>
        /// The RegenerationBase component attached to this VitalsComponent, if any.
        /// </summary>
        public RegenerationBase Regeneration
        {
            get
            {
                if (_regeneration == null)
                {
                    Debug.LogWarning("Regeneration is not assigned on " + gameObject.name + " game object.");
                    return null;
                }
                return _regeneration;
            }
            private set => _regeneration = value;
        }

        /// <summary>
        /// Sets the RegenerationBase component for this VitalsComponent.
        /// </summary>
        public void SetRegeneration(RegenerationBase regeneration)
        {
            Regeneration = regeneration;
        }
        
        #endregion

        #region UI

        /// <summary>
        /// Sets the VitalsHook component for this VitalsComponent.
        /// </summary>
        /// <param name="hook">The VitalsHook component to set.</param>
        public void SetHook(VitalsHook hook)
        {
            vitalsHook = hook;
        }

        #endregion
        
    }
}