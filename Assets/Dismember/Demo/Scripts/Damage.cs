/**********************************
* The purpose of this file is to demonstrate how you can handle giving damage from a third party asset or simular
* call TryFire(position, direction) to shoot a ray from "position" towards "direction" with a given force, damage and wether the projectile can dismember or not
* position is usually the npc's transform.position and the direction transform.forward
***********************************/

using UnityEngine;
namespace Ungamed.Dismember {
	public class Damage : MonoBehaviour {
		[Header("Amount of damage to give on hit")]
		public float damageAmount = 10f;
		[Header("How much force is given to the target")]
		public float forceAmount = 100f;
		[Header("Can this ammotype dismember limbs")]
		public bool canDismember = true;

		private RaycastHit hit;
		private GenericDismembering limbScript;

		public virtual void TryFire(Vector3 position, Vector3 direction) {
			Ray ray = new Ray(position, direction);
            TryFire(ray);
		}

		public virtual void TryFire(Ray ray) {
			// if the ray is intersected
			if (Physics.Raycast (ray, out hit)) { // should mask
				// get the attached limbscript
				limbScript = hit.transform.GetComponent<GenericDismembering>();
				// try to hit
				TryHit (ray.direction);
			}
		}

		public virtual void TryHit(Vector3 hitDirection) {
			Rigidbody rb = hit.collider.attachedRigidbody;
			// if there is a rigidbody attached to the collider we hit add some force to it
			if (rb) {
				TryAddForce (rb, hitDirection * forceAmount);
			}
			// if there's a limbscript on the gameobject of the collider we shot, apply the damage and tell the script if the projectile can dismember the limb
			if (limbScript) {
				limbScript.Damage (damageAmount, hitDirection*forceAmount, canDismember);
			}
		}

		void TryAddForce(Rigidbody rigidbody, Vector3 force) {
			rigidbody.AddForceAtPosition (force, hit.point);
		}
	}
}