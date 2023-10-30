/**
*	This is the limb script, add this to all limbs you want to be able to shoot of or receive positional damage
*
*	Version 1.2:
*	 - Fix: Scaling issue when baking the mesh there's no need for applying a scale
*	 - Added: Support for TPSA_AI: To enable add precompiler directive: TPSA
*
*	Version 1.1:
*	 - Fix: Now removing attached particle systems
**/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Ungamed.Dismember {

[RequireComponent(typeof(Collider))]
[RequireComponent(typeof(Rigidbody))]
#if UFPS
	public class GenericDismembering : vp_DamageHandler { // If using UFPS, implement the damagehandler for better support
#else
    public class GenericDismembering : MonoBehaviour {
#endif
        // Public inspector variables
        [Tooltip ("The corresponding mesh")]
		public GameObject mesh;
		[Tooltip ("How much health should the limb have, when it reaches 0 the limb will dismember.")]
		public float initialHealth = 5f;
		[Tooltip ("What type of bodypart is this, this is used to add more damage for head/critical, same for body, and less for extremities")]
		public DAMAGETYPE bodyPart = DAMAGETYPE.ARM;
		[Tooltip("Will the npc die if this gets dismembered?")]
		public bool dieOnDismember = true;
		[Tooltip("If this part can dismember or just receive damage")]
		public bool cantDie = false;
		[Tooltip("In case you just want messy explosion you can prevent the creation of shot off limbs by disabling this")]
		public bool createLimbOnDismember = true;

		[HideInInspector] public float dmgMultiplier = 1f;
		[HideInInspector] public DismemberManager manager;
		[HideInInspector] public float health; // current health of the limb

		// references initialized in start for faster access
		Rigidbody[] rbs; // references rigidbodies on this transform+children
		Collider[] cols; // references colliders on this transform+children
		List <SkinnedMeshRenderer> meshes = new List<SkinnedMeshRenderer>();// references SkinnedMeshRenders on the assigned mesh+children
		//precalculated values
		float mass; // the combined mass for the limb

#if UFPS
		protected override void Awake() {
#else
        void Awake() {
#endif
                health = initialHealth;

			if (!mesh) {
				if (!cantDie) {
					Debug.LogError ("No mesh assigned to bone, but it's set to dismember");
				}
				return; // update behaviour to allow no mesh, for positional damage without dismembering
			}

			// populate the arrays with references to the children components that we'll need.
			cols = GetComponentsInChildren<Collider> ();
			rbs = GetComponentsInChildren<Rigidbody> ();

			//Get child meshes
			GenericDismembering[] otherParts = GetComponentsInChildren<GenericDismembering>();

			for (int i = 0; i < otherParts.Length; i++) {
				meshes.Add (otherParts [i].mesh.GetComponent<SkinnedMeshRenderer>());
			}

			// calculate mass of entire limb (with children)
			mass = 0f;
			for (int i = 0; i < rbs.Length; i++) {
				mass += rbs [i].mass;
			}
			// if this was manually created we need to set the reference to the manager
			if (!manager) {		
				manager = transform.root.gameObject.GetComponent<DismemberManager> ();
				if (!manager) {
					Debug.LogError("You need to add the DismemberManager script to the root object ("+transform.root.name+").");
				}
			}
			#if TPSA
			tag = "Enemy";
			#endif
		}

		// This function is where the magic of dismembering is happening
		// it creates a copy of the affected meshes, generates colliders, disables the now unused stuff (RigidBodies, Colliders, meshes etc)
		// and finally spawns the bloodeffect and executes the event
		Rigidbody LimbDie() {
			// Debug.Log ("Limb dying");
			Rigidbody rb = null;
			if (createLimbOnDismember) {
				GameObject goRoot = new GameObject ();
				goRoot.transform.position = mesh.transform.position;
				goRoot.transform.rotation = mesh.transform.rotation;
				goRoot.transform.localScale = Vector3.one; // since using bakemesh this needs to be one..
				//transform.lossyScale;
				int index = 0;
				Transform parent = goRoot.transform;
				for (int i=0; i<meshes.Count; i++) {
					SkinnedMeshRenderer smr = meshes [i];
					if (smr.enabled) {
						GameObject go = new GameObject ();
						MeshRenderer mr = go.AddComponent<MeshRenderer> ();
						MeshFilter mf = go.AddComponent<MeshFilter> ();
						Mesh newMesh = new Mesh ();
						smr.BakeMesh (newMesh);
						mf.sharedMesh = newMesh;
						mr.materials = smr.materials;
						//newMesh.RecalculateBounds ();

						if (newMesh.triangles.Length < 2048) { // hack/fix since physx can't create meshcolliders on complex meshes
							MeshCollider mc = go.AddComponent<MeshCollider> ();
							mc.convex = true;
							#if UNITY_5_5_OR_NEWER
							mc.inflateMesh = true;
							mc.skinWidth = .02f;
							#endif
							mc.isTrigger = false;
							mc.sharedMesh = newMesh;

						} else {
							BoxCollider mc = go.AddComponent<BoxCollider> ();
							mc.center = mf.mesh.bounds.center;
							mc.size = mf.mesh.bounds.extents;
							mc.isTrigger = false;
						}

						if (index == 0) { // only add rb to the first object so they dont seperate
							rb = go.AddComponent<Rigidbody> ();
							rb.collisionDetectionMode = CollisionDetectionMode.Discrete;
							rb.mass = mass;
						}

						go.transform.position = smr.transform.position;
						go.transform.rotation = smr.transform.rotation;

						go.transform.parent = parent;
						go.transform.localScale = Vector3.one;
						parent = go.transform;
						// hide the mesh
						smr.enabled = false;
						index++;
					}
				}

				Destroy (goRoot, 10f); // remove limb after 10 seconds (should be public, maybe)
			} else {
				for (int i=0;i<meshes.Count;i++) {
					meshes[i].enabled = false;
				}
			}
			//mesh.SetActive (false);

			//disable attached colliders
			for (int i = 0; i < cols.Length; i++) {
				cols [i].enabled = false;
			}

			//disable any particle systems that might be playing ( limited to one, since only one is present at a time
			ParticleSystem ps = GetComponentInChildren<ParticleSystem>();
			if (ps) {
				Destroy (ps);
			}

			if (bodyPart == DAMAGETYPE.THIGH || bodyPart == DAMAGETYPE.LEG || bodyPart == DAMAGETYPE.FOOT) {
				manager.canWalk = false;
				if (manager.OnCripple != null) {
					manager.OnCripple.Invoke ();
				}
			}
			if (manager.OnDismember != null) {
				manager.OnDismember.Invoke (bodyPart);
			}

			manager.OnLimbDie (bodyPart, transform, dieOnDismember);

			if (rb) {
				return rb;
			} else {
				return null;
			}
		}

		// Needed for object pooling, call this function!
		public void DoRespawn() { // renamed from Respawn due to UFPS damage handler conflict
			health = initialHealth;
			mesh.SetActive (true);
			//enable attached colliders
			for (int i = 0; i < cols.Length; i++) {
				cols [i].enabled = true;
			}
		}

		/**
		 * This is to enable ufps damage system, so we dont use the damage function from sendmessage (it collides with the ufps damagehandler)
		 * 
		 **/
		void ApplyDamage(float amount) {
			Damage (amount);
		}

#if UFPS // override UFPS damage functions

		public override void Damage(float damage) {
			Damage(new vp_DamageInfo(damage, null));
		}

		public override void Damage(vp_DamageInfo damageInfo) {
			Vector3 forceDirection = (transform.position - damageInfo.OriginalSource.position).normalized;
			float forceAmount;

			switch (damageInfo.Type) {
				case vp_DamageInfo.DamageType.Bullet:
					forceAmount = 10f;
					break;
				case vp_DamageInfo.DamageType.Explosion:
					forceAmount = (1 / Vector3.Distance (transform.position, damageInfo.Source.position)) * 30f;
					damageInfo.Damage *= 5f;
					break;
				default:
					forceAmount = 5f;
					break;
			}

			Vector3 force =  forceDirection * forceAmount;
			//Debug.Log ("Calling Damage with force: " + force);
			Damage (damageInfo.Damage, force);
		}


		public override void DieBySources(Transform[] sourceAndOriginalSource) {

			if (sourceAndOriginalSource.Length != 2) {
				Debug.LogWarning("Warning (" + this + ") 'DieBySources' argument must contain 2 transforms.");
				return;
			}

			Source = sourceAndOriginalSource[0];
			OriginalSource = sourceAndOriginalSource[1];
			// Debug.Log ("DieBySources");
			LimbDie();

		}

		public override void DieBySource(Transform source) {
			OriginalSource = Source = source;
			// Debug.Log ("DieBySource");
			LimbDie();
		}

#endif

#if TPSA
		// TPSA compability, TODO: Find an unintrusive way to specify which weapons can dismember
		void ReceiveDamage(TPSA_Damage dmg) {
			// Debug.Log ("Damage received");
			Damage (dmg.Damage);
		}
#endif
        // Call this function to apply damage to the limb, with force
        public void Damage( float amount, Vector3 force, bool canDismember = true) {
			health -= amount;

			// Debug.Log ("Damaging limb " + mesh.name + " Health left: " + health + " cantDie: "+cantDie+" canDismember: " +canDismember);
			
			if (health <= 0f && !cantDie && canDismember) {
				// Debug.Log("Dismembering");
				health = 0f;
				Rigidbody rb = LimbDie ();
				if (rb) {
					rb.AddForce(force, ForceMode.Impulse);
				}
			}
			// we have to send the damage after the effect so if we add enough damage to kill the npc, then the checks for colliders is ran after they are disabled
			// eg. if we shoot off the head with enough damage to kill the npc then the manager will kill the npc and when it checks if head is still attached to the body
			// it will return true, and the manager will play the death sound even though the npc has no head attached to the body.
			manager.Damage(amount * dmgMultiplier);
		}

		// Call this function to apply damage to the limb
		public void Damage( float amount, bool canDismember = true) {
			// Debug.Log ("Damaging limb " + mesh.name);

			health -= amount;
			if (health <= 0f && !cantDie && canDismember) {
				health = 0f;
				LimbDie ();
			}
			// we have to send the damage after the effect so if we add enough damage to kill the npc, then the checks for colliders is ran after they are disabled
			// eg. if we shoot off the head with enough damage to kill the npc then the manager will kill the npc and when it checks if head is still attached to the body
			// it will return true, and the manager will play the death sound even though the npc has no head attached to the body.
			manager.Damage(amount * dmgMultiplier);
		}
	}
}
