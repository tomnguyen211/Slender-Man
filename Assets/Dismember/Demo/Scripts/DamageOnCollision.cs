using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Ungamed.Dismember {
	[RequireComponent(typeof(Collider))]
	[RequireComponent(typeof(Rigidbody))]
	public class DamageOnCollision : MonoBehaviour {
		[Tooltip("How much shal we multiply the speed of the collision with to calculate the damage")]
		public float damageAmount = .5f;

		void OnCollisionEnter(Collision other) {
			GenericDismembering dismemberScript = other.gameObject.GetComponent<GenericDismembering> ();
			if (dismemberScript) {
				dismemberScript.Damage (other.relativeVelocity.magnitude * damageAmount);
			}
		}
	}
}
