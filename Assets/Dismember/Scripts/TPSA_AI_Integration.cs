#if TPSAI
using UnityEngine;
using System.Collections;
using Ungamed.Dismember;


[RequireComponent(typeof(DismemberManager))]
[RequireComponent(typeof(TPSA_AI))]
public class TPSA_AI_Integration : MonoBehaviour {
	TPSA_AI tpsa_ai;
	DismemberManager dismemberManager;

	// transfer the received damage from the Dismember system to the TPSA_AI system
	void OnDamage(float amount) {
		tpsa_ai.Brain.Health -= amount; // should call a function
	}

	// remember to clean up listeners
	void OnDisable() {
		dismemberManager.OnDamage.RemoveListener(OnDamage);
		dismemberManager.OnDie.RemoveListener (OnDie);
	}

	// When the head or a leg is shot off the animation doesn't really work so we ragdoll instead
	void OnDie() {
		// disable animations before ragdoll
		GetComponent<Animator> ().enabled = false;
		// Disable the navmesh agent in order to ragdoll
		GetComponent<NavMeshAgent> ().enabled = false;
		// prevent TPSA trying to access the NavAgent or play any animations and make sure that TPSA knows it's dead
		tpsa_ai.Brain.Alive = false;
		tpsa_ai.Brain.Health = 0;
		tpsa_ai.Brain.State = TPSA_AI.States.Dead;
		//finally..
		dismemberManager.Ragdoll ();
	}

	void Start() {
		tpsa_ai 			= GetComponent<TPSA_AI> ();
		dismemberManager 	= GetComponent<DismemberManager> ();

		dismemberManager.handleOwnHealth = false; // let TPSA handle the health

		dismemberManager.OnDamage.AddListener(OnDamage); // called when model is damaged
		dismemberManager.OnDie.AddListener (OnDie); // called when a vital part is shot off
	}
}
#endif
