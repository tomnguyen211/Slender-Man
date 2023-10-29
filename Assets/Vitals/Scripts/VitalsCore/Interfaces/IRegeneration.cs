using System;

namespace Vitals
{
    public interface IRegeneration
    {
        public float RegenerationRate { get; }
        public bool IsRegenerating { get; }
        public float DrainRate { get; }
        public bool IsDraining { get; }
        
        public event Action<bool> OnRegenerationStatusChanged;
        public event Action<bool> OnDrainStatusChanged;

        public void StartRegeneration();
        public void StopRegeneration();
        
        public void StartDrain();
        public void StopDrain();
        
        public void SetRegenerationRate(float rate);
        
        public void SetDrainRate(float rate);
        
    }
}