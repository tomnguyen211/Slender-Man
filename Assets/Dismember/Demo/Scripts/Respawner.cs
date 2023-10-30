using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Ungamed.Dismember;

public class Respawner : MonoBehaviour {
	public GameObject prefab;
	public bool spawnAtStart = false;

	GameObject instance = null;
	DismemberManager dm = null;

	// Get rid of the event listener, so we don't leave it hanging
	void OnDestroy() {
		if (!object.ReferenceEquals (dm, null)) { // should be faster than normal comparison
			dm.OnDie.RemoveListener(Respawn);
			dm = null;
		}
	}

	// Respawn function
	public void Respawn() {
		// dont try to respawn anything if there's nothing assigned
		if (object.ReferenceEquals (prefab, null)) {
			Debug.LogWarning ("No prefab is set to spawn.");
			return;
		}

		// remove the listener if one is assigned
		if (!object.ReferenceEquals (dm, null)) {
			dm.OnDie.RemoveListener(Respawn);
			Invoke ("Respawn", 3f);
			dm = null;
			return;
		}

		// destroy the previously spawned object, not really necessay since it's automaticly destroyed from the DismemberManager
		if (!object.ReferenceEquals (instance, null)) {
			Destroy(instance);
		}
		// spawn the entity at this position (just for demo purpose, could be adjusted to choose from several spawnpoints)
		instance = Instantiate (prefab, transform.position, transform.rotation) as GameObject;
		// grab a reference to the manager so we can hook the event
		dm = instance.GetComponent<DismemberManager> ();
		// call this function when the zombie dies
		dm.OnDie.AddListener(Respawn);
	}

	void Start() {
		if (spawnAtStart) {
			Respawn ();
		}
	}
}
