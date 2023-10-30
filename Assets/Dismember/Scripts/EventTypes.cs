/**
 * This is just a holder file for the events.
 **/
namespace Ungamed.Dismember {
	using System;
	using UnityEngine;
	using UnityEngine.Events;

	[Serializable] public class DamageEventType : UnityEvent<float> {}
	[Serializable] public class DismemberEventType : UnityEvent<DAMAGETYPE> {}
	public class AdvDismemberEventType : UnityEvent<DAMAGETYPE, Vector3, Vector3> {}
}