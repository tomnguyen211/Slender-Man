using System;
using UnityEngine;

namespace Ungamed.Dismember
{
	public class LimbData {
		public GameObject gameObject;
		public Collider collider = null;
		public Rigidbody rigidbody = null;
		public CharacterJoint joint = null;

		public static implicit operator bool(LimbData instance) {
			return instance != null && instance.gameObject != null;
		}
	}
}

