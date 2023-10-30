using UnityEngine;

namespace Ungamed.Dismember {
    [RequireComponent(typeof(Damage))]
    public class PlayerFire : MonoBehaviour {
        Damage dmgHandler;
        void Start() {
            dmgHandler = GetComponent<Damage>();
        }

        void Update() {
            if (Input.GetButtonDown("Fire1")) {
                dmgHandler.TryFire(transform.position, transform.forward);
            }
        }
    }
}
