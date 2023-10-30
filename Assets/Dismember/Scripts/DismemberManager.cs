/*****************************************************
 * Dismember manager - Current version: 1.3.0
 * Latest Addition: 23rd June 2017
 * 
 * Thank you for purchasing this asset!
 * I hope you will feel that you've got your moneys worth!
 * 
 * Best wishes
 * Thomas.
 * 
 * Version 1.3.0
 *  - Added support for not generating a copy of the limb if a particle system just "blows up the limb"
 *  - Added "AdvancedDismember" for more customization (Thank you Mio!)
 *  - Optimised some internals
 *  - Increased support for both TPSA and UFPS
 *  - Probably added more bugs to fix later
 *  - Improved blood effect...again.
 * 
 * Version 1.2.2:
 *  - Added support for TPSA
 *  - Fixed scaling issue
 * 
 * Version 1.2.1:
 *  - Fixed BloodEffect rotation
 *  - Added checkbox to make the model die if it get crippled.
 *  - Fixed spelling (Thank you D.R.) >.<
 * 
 * Version 1.2.0:
 * 	- Fixed mesh copy instead of t-pose now we bake the mesh to conform with animation data.
 *	- Added UnityEvents 
 *	- Added more tooltips
 *	- Changed default fall animation state to a blank string, so it doesn't try to play a non existent animation
 * 	- Added a custom deathtype, for those who want to handle death animation themselves. 
 *	- Added some more error checking.
 *	- Added more code comments.
 *
 * Version 1.1.0: Added this header
 * 	- Rewrote pretty much everything, to make the script work with other models and not require strict naming of meshes
 * 
 * @author Thomas 'ungamed' Hartvig (Hartvigs IT)
 * @email ungamed.th@gmail.com
 ******************************************************/

using UnityEngine;
using UnityEngine.Events;
using System.Collections.Generic;

namespace Ungamed.Dismember {
	
	// Damagetypes for adding different amount of damage
	public enum DAMAGETYPE {
		LEG,
		ARM,
		HAND,
		FOOT,
		THIGH,
		BODY,
		HEAD,
		CRITICAL
	}
	
	// the death types that we're supporting
	public enum DEATHTYPE {
		RAGDOLL, // default: turns the model into a ragdoll when health is zero
		ANIMATION, // plays the animation defined by the "animationStateName" string
		CUSTOM // does nothing but call the unityevent OnDie, that way there's support for more advanced animations and 3rd party AI.
	}
	
	public class DismemberManager: MonoBehaviour {
		
		[Header("Stats")]
		public float initialHealth = 10;
		private float health;
		
		[Header("On Death")]
		[Tooltip("This sets wether to ragdoll, play an animation on death or nothing (you handle it from the OnDie event)")]
		public DEATHTYPE deathType = DEATHTYPE.RAGDOLL;
		[Tooltip("This animation will play if Death type is set to animation")]
		public string animationStateName = "Death";
		[Tooltip("If sat the model will die when a foot or leg is shot off")]
		public bool dieOnCripple = true;
		[Tooltip("This animation will play if a part of one of the legs are shot off, leave blank to skip")]
		public string fallAnimation = "";
		[Tooltip("The sound to play when the model dies, this is skipped if the model have the head shot off")]
		public AudioClip deathSound;
		[HideInInspector] public bool isDead;
		private bool _canWalk;
		[HideInInspector] public bool canWalk {
			get {
				return _canWalk;
			}
			set {
				if (isDead)
					return;
				_canWalk = value;
				if (!_canWalk) {
					if (dieOnCripple) {
						Die (Vector3.zero);
					} else if (fallAnimation != "") {
						animator.Play (fallAnimation);
					}
				}
			}
		}
		
		// When using 3rd party AI you can set this in your bridge damage controller
		[HideInInspector] public bool handleOwnHealth = true;
		
		[Header("Damage multipliers")]
		public float dmgArms = .5f;
		public float dmgLowerLeg = .5f;
		public float dmgFootHand = .1f;
		public float dmgHead = 2f;
		public float dmgUpperLeg = .8f;
		public float dmgBody = 1f;
		
		[Header("When limb is shot off")]
		public GameObject bloodEffect;
		[Tooltip("How many seconds before destrying the gameobject?\nIf 0 then it will try to detect the duration (only works with particlesystems.")]
		public float bloodEffectDuration = 0f;
		public AudioClip soundEffect;
		
		[Header("Events")]
		[Tooltip("This is called every time a limb is shot off. The parameter says what kind of limb was hit.")]
		public DismemberEventType OnDismember;
		[Tooltip("This event is called every time the model receives damage, with the damage amount as a float parameter ")]
		public DamageEventType OnDamage;
		[Tooltip("This event is called when the health reaches 0")]
		public UnityEvent OnDie;
		[Tooltip("Called when a upper leg, lower leg or a foot is dismembered")]
		public UnityEvent OnCripple;
		
		new private AudioSource audio;
		
		private Animator animator;
		private SkinnedMeshRenderer[] renderers;
#if UNITY_EDITOR
        private ColliderHelper colliderHelper;
#endif
        private AdvancedDismember advDismember;
		
		private List<SkinnedMeshRenderer> usedMeshes = new List<SkinnedMeshRenderer>();


		[HideInInspector] public bool customDeathAnimation = false;

#if UNITY_5_5_OR_NEWER
		float getMaxTime(ParticleSystem.MinMaxCurve minMaxCurve) {
			switch (minMaxCurve.mode) {
				case ParticleSystemCurveMode.Constant:
					return minMaxCurve.constant;
				case ParticleSystemCurveMode.TwoConstants:
					return minMaxCurve.constantMax;
				case ParticleSystemCurveMode.Curve:
				case ParticleSystemCurveMode.TwoCurves:
					return minMaxCurve.curveMax.Evaluate(1f) * minMaxCurve.curveMultiplier;
			}
			return 0f;
		}
#endif
		// Must be spawned!!
		public float GetEffectDuration(GameObject effect) {
			float duration = bloodEffectDuration; //use this for default, if for some reason we cant detect the real duration
			ParticleSystem ps = effect.GetComponentInChildren<ParticleSystem> ();
			#if UNITY_5_5_OR_NEWER
			if (ps) {
				duration = getMaxTime(ps.main.startDelay) + ps.main.duration + getMaxTime(ps.main.startLifetime.constantMax);
			}
			#else
			if (ps) {
				duration = ps.startDelay + ps.duration + ps.startLifetime;
				//Debug.Log ("Destroying after: "+duration);
			}
			#endif
			return duration;
		}

		public void SetEffectTransform(Transform parent, GameObject effect) {
			Vector3 position = parent.position;
			Vector3 direction = (parent.position - parent.parent.position).normalized; // get the direction vector between this bone and the parent, to align the effect
			position = Vector3.Lerp (position, position + direction, .04f); // move a little out of the mesh.
			effect.transform.forward = direction; // set the blood spray direction
			effect.transform.parent = parent; // attach the effect to the mesh
		}

		public void OnLimbDie(DAMAGETYPE dmgType, Transform placement, bool dieOnDismember) {
			if (advDismember) {
				advDismember.OnDismember (dmgType, placement, dieOnDismember);
			} else {
				if (bloodEffect) {
					GameObject effect = Instantiate (bloodEffect, placement.position, Quaternion.identity) as GameObject;
					SetEffectTransform(placement, effect);

					float duration = bloodEffectDuration;
					if (duration == 0f) {
						duration = GetEffectDuration(effect);
					}

					Destroy (effect, duration);
				}
			}
			if (isDead) {
				if (audio) {
					audio.Stop ();
				}
				return;
			}
			
			if (soundEffect && !dieOnDismember) {
				if (audio) {
					audio.PlayOneShot (soundEffect);
				} else {
					AudioSource.PlayClipAtPoint (soundEffect, placement.position);
				}
			}
			if (dieOnDismember) {
				Die (-Vector3.forward);
			}
		}
		
		
		void Awake() {
			// Set up refferences
			audio = GetComponent<AudioSource> (); // not required but recomendet
			animator = GetComponent<Animator> ();
			advDismember = GetComponent<AdvancedDismember> ();
			// We don't start dead
			isDead = false; // lets not use object pooling rutines when it's the first spawn
			// Reset is meant to be called if we use object pooling or respawning
			Reset ();
		}
		
		void Reset() {
			if (isDead) { // we are respawning, so reset all limbs (so shot of limbs are restored and limb-health is back to normal)
				GenericDismembering[] allScripts = GetComponentsInChildren<GenericDismembering>();
				for (int i = 0; i < allScripts.Length; i++) {
					allScripts [i].DoRespawn ();
				}
			}
			health = initialHealth; // restore health
			isDead = false;
			canWalk = true; // we haven't shot off any legs, yet :D
			Rigidbody[] attachedBodies = GetComponentsInChildren<Rigidbody> ();
			for (int i = 0; i < attachedBodies.Length; i++) {
				attachedBodies [i].isKinematic = true; // disable ragdoll
			}
		}
		
		public void Ragdoll(bool activate = true) {
			Rigidbody[] attachedBodies = GetComponentsInChildren<Rigidbody> ();
			for (int i = 0; i < attachedBodies.Length; i++) {
				attachedBodies [i].isKinematic = !activate; // set ragdoll
			}
		}

        public float GetHealth() {
            return health;
        }
		
		public void Die(Vector3 addForce) {
			if (isDead)
				return;
			isDead = true;

			if (!handleOwnHealth) {
				// we get here if a vital part is shot off, but somebody else is handling health so we need to notify that somebody..
				// and we'll do that by invoking the ondie event
				if (OnDie != null) {
					OnDie.Invoke ();
				}
				return;
			}

			if (deathType == DEATHTYPE.RAGDOLL && !customDeathAnimation) {
				animator.enabled = false;
				Rigidbody[] attachedBodies = GetComponentsInChildren<Rigidbody> ();
				for (int i = 0; i < attachedBodies.Length; i++) {
					attachedBodies [i].isKinematic = false;
				}
				animator.GetBoneTransform (HumanBodyBones.Chest).GetComponent<Rigidbody> ().AddForce (addForce, ForceMode.Impulse);
			} else {
				if (deathType == DEATHTYPE.ANIMATION) {
					animator.Play (animationStateName);
				}
			}

			customDeathAnimation = false; // reset this for next usage (to support pooling)

			if (audio) {
				audio.Stop ();
			}
			if (deathSound) {
				// lets detect if the head is attached to the body otherwise die silently
				Transform headTransform = animator.GetBoneTransform(HumanBodyBones.Head);
				SphereCollider headCollider = headTransform.GetComponent<SphereCollider> ();
				if (headCollider.enabled) {
					PlaySound(deathSound);
				}
			}
			if (OnDie != null) {
				OnDie.Invoke ();
			}
			// Invoke ("DisableSelf", 5f);
			if (deathType != DEATHTYPE.CUSTOM) {
				Destroy(gameObject, 5f);
			}
			// Invoke ("Respawn", 4f);
		}

		void PlaySound(AudioClip clip) {
			if (audio) {
				audio.PlayOneShot (clip);
			} else {
				AudioSource.PlayClipAtPoint (clip, transform.position);
			}
		}

		void Respawn() {
			//Instantiate (prefab, spawnPoint.transform.position, spawnPoint.transform.rotation);
		}
		
		public void Damage(float amount) {
			if (isDead)
				return;
			Damage (amount, -transform.forward * 100);
		}
		
		public void Damage(float amount, Vector3 addForce) {
			if (isDead)
				return;
			if (OnDamage != null) {
				OnDamage.Invoke (amount);
			}
			if (handleOwnHealth) {
				health -= amount;
				if (health <= 0f) {
					health = 0f;
					Die (addForce);
				}
			}
		}
		
		#if UNITY_EDITOR
		// Don't include this part in a build...as it's all for generating the ragdoll
		
		void Initialize() {
			animator = GetComponent<Animator>();
			if (!animator || !animator.isHuman) {
				Debug.LogError("The automatic setup requires the model to be imported as a Humanoid");
			}
			renderers = GetComponentsInChildren<SkinnedMeshRenderer>();
			if (renderers.Length < 1) {
				Debug.LogError ("No SkinnedMeshRenderers found in this GameObject!");
			}
		}
		/**
		 * This is maybe the most complex function in this script.. it tries to get the mesh that fits the bone, by fx. to get the RightUpperArm
		 * it goes from the bone (called RightUpperArm) that is positioned near the shoulder travels halfway towards the next bone (which is the elbow) and returns the nearest mesh
		 * on hips and body/chest the bone is generally allready near the center of the mesh, so it doesn't try to find a center position.
		 * */
		SkinnedMeshRenderer GetFromBone(HumanBodyBones bone) {
			Transform boneTransform = animator.GetBoneTransform(bone);
			List<SkinnedMeshRenderer> results = new List<SkinnedMeshRenderer>();
			for (int rendererIndex=0;rendererIndex<renderers.Length;rendererIndex++) {
				Transform[] bones = renderers[rendererIndex].bones;
				for (int boneIndex=0;boneIndex<bones.Length; boneIndex++) {
					if (boneTransform == bones [boneIndex]) {
						results.Add(renderers [rendererIndex]);
					}
				}
			}
			if (results.Count == 0)
				return null;
			// Debug.Log ("Number of meshes for " + bone.ToString () + " is: " + results.Count);
			// return the best guess (the mesh closest to the point between this bone and the next)
			
			/* HACKY NOTE!!
			 * Apparently in editormode the child transform.position is not in worldspace!
			 * Therefore I've commented out the stuff that takes the worldposition into account, 
			 * since unity will likely fix this in a future update
			 */
			
			Vector3 bonePosition = boneTransform.position;// - transform.position;
			Vector3 childBonePosition = boneTransform.GetChild (0) ? boneTransform.GetChild (0).position : Vector3.zero;//transform.position;
			//childBonePosition -= transform.position; // will be zero if there isn't a childnode
			// Debug.Log(bone.ToString() + " pos: "+boneTransform.position);
			Vector3 midPoint = bonePosition + ((childBonePosition-bonePosition)/2);
			if (bone == HumanBodyBones.Hips || bone == HumanBodyBones.Chest) {		
				midPoint = bonePosition;		
			}
			SkinnedMeshRenderer result = results[0];
			for (int i = 1; i < results.Count; i++) {
				if (Vector3.Distance (midPoint, results [i].bounds.center) < Vector3.Distance (midPoint, result.bounds.center)) {
					result = results [i];
				}
			}
			if (usedMeshes.Contains (result))
				return null;
			usedMeshes.Add (result); // this array annoys me.. shouldn't have a global array like this, however we need to make sure that we only assign each mesh once!
			return result;
		}
		
		float GetDamageMultiplier(DAMAGETYPE dmgType) {
			float result = dmgBody; // default value is body (pre configured to 1)
			switch (dmgType) {
			case DAMAGETYPE.ARM:
				result = dmgArms;
				break;
			case DAMAGETYPE.LEG: //lower
				result = dmgLowerLeg;
				break;
			case DAMAGETYPE.FOOT:
			case DAMAGETYPE.HAND:
				result = dmgFootHand;
				break;
			case DAMAGETYPE.CRITICAL:
			case DAMAGETYPE.HEAD:
				result = dmgHead;
				break;
			case DAMAGETYPE.THIGH:
				result = dmgUpperLeg;
				break;
				
			}
			return result;
		}
		
		// This function sets up and adds the "GenericDismembering" script to bodyparts.
		// If you want to change which bodyparts will kill the owner when dismembered this is the place to do it (see dieOnDismember)
		void AddDismemberScript(HumanBodyBones bone, GameObject meshGO, bool cantDismember) {
			if (_ragdollOnly)
				return;
			GameObject go = animator.GetBoneTransform (bone).gameObject;
			GenericDismembering dismemberScript = go.GetComponent<GenericDismembering> ();
			if (!dismemberScript)
				dismemberScript = go.AddComponent<GenericDismembering> ();
			dismemberScript.mesh = meshGO;
			dismemberScript.cantDie = cantDismember; // this allows for only receiving damage and not dismembering (default only hips have this sat to true)
			switch (bone) {
			case HumanBodyBones.Head:
				dismemberScript.bodyPart = DAMAGETYPE.HEAD;
				dismemberScript.dieOnDismember = true;
				break;
			case HumanBodyBones.LeftLowerArm:
			case HumanBodyBones.LeftUpperArm:
			case HumanBodyBones.RightLowerArm:
			case HumanBodyBones.RightUpperArm:
				dismemberScript.bodyPart = DAMAGETYPE.ARM;
				dismemberScript.dieOnDismember = false;
				break;
			case HumanBodyBones.LeftLowerLeg:
			case HumanBodyBones.RightLowerLeg:
			case HumanBodyBones.LeftFoot:
			case HumanBodyBones.RightFoot:
				dismemberScript.bodyPart = DAMAGETYPE.LEG;
				dismemberScript.dieOnDismember = false;
				break;
			case HumanBodyBones.LeftUpperLeg:
			case HumanBodyBones.RightUpperLeg:
				dismemberScript.bodyPart = DAMAGETYPE.THIGH;
				dismemberScript.dieOnDismember = true;
				break;
			case HumanBodyBones.LeftHand:
			case HumanBodyBones.RightHand:
				dismemberScript.bodyPart = DAMAGETYPE.HAND;
				dismemberScript.dieOnDismember = false;
				break;
			default:
				dismemberScript.bodyPart = DAMAGETYPE.BODY;
				dismemberScript.dieOnDismember = true;
				break;
			}
			
			dismemberScript.dmgMultiplier = GetDamageMultiplier (dismemberScript.bodyPart);
			
			dismemberScript.manager = this;
			
		}
		
		void AddLimb<T>(HumanBodyBones partId, bool cantDismember = false) where T: Collider {
			SkinnedMeshRenderer meshRenderer = GetFromBone(partId);
			if (meshRenderer) {
				colliderHelper.AddCollider<T>(meshRenderer, animator.GetBoneTransform(partId));
				AddDismemberScript(partId, meshRenderer.gameObject, cantDismember);
			} else { // fail silently to support models that doesn't have all the meshes
				// Debug.Log("No mesh found for: "+partId.ToString());
			}
		}
		
		private bool _ragdollOnly = false;
		
        // This function is run when you press one of the buttons in the inspector
		public void Setup(bool ragdollOnly = false) {
			Initialize();
			
			_ragdollOnly = ragdollOnly;
			
			// Create/update the ragdoll (The RagdollCreator does NOT make colliders)
			RagdollCreator ragdoll = new RagdollCreator(gameObject);
			ragdoll.Create();
			
			// Initialize the colliderhelper class for use with the AddLimb function
			// I'm sorry to put it here and use it as a global, but passing it in all calls or redeclaring it is not a good solution either
			// TODO: I should make the AddLimb function a part of the ColliderHelper instead? But the addDismemberScript doesn't fit in that class...
			colliderHelper = new ColliderHelper();
			
			// Add colliders and scripts to all the supported bones, if one (or more) doesn't have a corresponding mesh it will be skipped.
			AddLimb<BoxCollider>(HumanBodyBones.Chest, true); // chest before hips, because if the hips mesh doesn't exist it will take the body mesh (chest) since they can both point to the same (hips) bone
			
			AddLimb<BoxCollider>(HumanBodyBones.Hips, true); // the second parameter tells the function that this part cant be dismembered (you can add this to other parts as you see fit)
			
			AddLimb<SphereCollider>(HumanBodyBones.Head);
			
			AddLimb<BoxCollider>(HumanBodyBones.Neck, true); // cannot be dismembered but is supported
			
			AddLimb<CapsuleCollider>(HumanBodyBones.LeftUpperArm);
			AddLimb<CapsuleCollider>(HumanBodyBones.RightUpperArm);
			AddLimb<CapsuleCollider>(HumanBodyBones.LeftLowerArm);
			AddLimb<CapsuleCollider>(HumanBodyBones.RightLowerArm);
			AddLimb<BoxCollider>(HumanBodyBones.LeftHand);
			AddLimb<BoxCollider>(HumanBodyBones.RightHand);
			
			AddLimb<CapsuleCollider>(HumanBodyBones.LeftUpperLeg);
			AddLimb<CapsuleCollider>(HumanBodyBones.RightUpperLeg);
			AddLimb<CapsuleCollider>(HumanBodyBones.LeftLowerLeg);
			AddLimb<CapsuleCollider>(HumanBodyBones.RightLowerLeg);
			AddLimb<BoxCollider>(HumanBodyBones.LeftFoot);
			AddLimb<BoxCollider>(HumanBodyBones.RightFoot);
		}
#endif
    }
}