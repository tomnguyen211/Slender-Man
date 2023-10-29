using UnityEngine;

namespace Vitals
{
    public class DemoCharacter : MonoBehaviour
    {
        public Health Health { get; private set; }
        public Stamina Stamina { get; private set; }
        
        private void Awake()
        {
            Health = GetComponent<Health>();
            Stamina = GetComponent<Stamina>();
        }
    }
}
