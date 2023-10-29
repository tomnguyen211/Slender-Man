using System;

namespace Vitals
{
    public interface IVitalsComponent
    {
        public float Value { get; }
        public float MaxValue { get; }
        
        public event Action OnValueIncrease;
        public event Action OnValueDecrease;
        public event Action OnMaxValueIncrease;
        public event Action OnMaxValueDecrease;
        public event Action OnValueFull;
        public event Action OnValueEmpty;
        
        public void Increase(float amount, bool triggerEvents = true, bool isDrain = false);
        
        public void Decrease(float amount, bool triggerEvents = true, bool isDrain = false);
        
        public void IncreaseMax(float amount);
        
        public void DecreaseMax(float amount);
        
        public void Set(float value);
        
        public void SetMax(float value);
        
    }
}
