using UnityEngine;

namespace Ungamed.Dismember {

	[System.Serializable]
	public class LimbDismemberData {
		[Header("Custom effect")]
		[Tooltip("If assigned, this effect will be used, otherwise the default is the one specified in the manager")]
		public GameObject effect = null;
		[Header("Animation to play on this dismember")]
		[Tooltip("Leave blank for none")]
		public string animationName = "";
        [Tooltip("Ragdoll after animation finishes")]
        public bool ragdollAfterAnimation = true;
		[Header("Event for more customization")]
		public DismemberEventType OnTrigger;
	}

	public class AdvancedDismemberEventData {
		public DAMAGETYPE dmgType;
		public Transform parent;
		public bool dieOnDismember;
		public LimbDismemberData dismemberData;

		public AdvancedDismemberEventData(DAMAGETYPE _dmgType, Transform _parent, bool _dieOnDismember) {
			dmgType = _dmgType;
			parent = _parent;
			dieOnDismember = _dieOnDismember;
		}
	}

	public class AdvancedDismember : MonoBehaviour {
        [Header("Seconds to wait to destroy model after death")]
        [Tooltip("Set to 0 if you dont want to destroy the model after death")]
        public float destroyAfter = 10f;
		[Header("Overrites events and effects.")]
		[Header("Adds possibility to assign a custom animations")]
		public LimbDismemberData Decapitation;
		public LimbDismemberData Arm;
		public LimbDismemberData Hand;
		public LimbDismemberData UpperLeg;
		public LimbDismemberData LowerLeg;
		public LimbDismemberData Foot;

		DismemberManager manager;
		Animator anim;

		void Awake() {
			manager = GetComponent<DismemberManager> ();
			anim = GetComponent<Animator> ();
		}

		public bool hasEffect(DAMAGETYPE dmgType) {
			switch (dmgType) {
				case DAMAGETYPE.HEAD:
					return Decapitation.effect != null;
					//break;
				case DAMAGETYPE.ARM:
					return Arm.effect != null;
					//break;
				case DAMAGETYPE.HAND:
					return Hand.effect != null;
					//break;
				case DAMAGETYPE.THIGH:
					return UpperLeg.effect != null;
					//break;
				case DAMAGETYPE.LEG:
					return LowerLeg.effect != null;
					//break;
				case DAMAGETYPE.FOOT:
					return Foot.effect != null;
					//break;
			}
			return false;
		}

        float GetAnimationClipLength(string animationName) {
            float clipLength = -1f;
            RuntimeAnimatorController ac = anim.runtimeAnimatorController;
            for (int i = 0; i < ac.animationClips.Length; i++)                 //For all animations
            {
                if (ac.animationClips[i].name == animationName)        //If it has the same name as your clip
                {
                    clipLength = ac.animationClips[i].length;
                }
            }
            return clipLength;
        }

        void DoRagdoll() {
            anim.enabled = false;
            manager.Ragdoll(true);
        }

        void TriggerEvent(AdvancedDismemberEventData eventData) {
			GameObject effect = null;
			if (eventData.dismemberData.effect) {
				effect = Instantiate (eventData.dismemberData.effect, eventData.parent.position, Quaternion.identity) as GameObject;
			} else {
				if (manager.bloodEffect) {
					effect = Instantiate (manager.bloodEffect, eventData.parent.position, Quaternion.identity) as GameObject;
				}
			}
			if (effect != null) {
				manager.SetEffectTransform(eventData.parent, effect);
				Destroy (
					effect,
					manager.GetEffectDuration(effect)
				);
			}
			if (anim && eventData.dismemberData.animationName != "") {
				anim.Play(Animator.StringToHash(eventData.dismemberData.animationName)); // should cache ref to Hash
                if (eventData.dismemberData.ragdollAfterAnimation && eventData.dieOnDismember) {
                    Invoke("DoRagdoll", GetAnimationClipLength(eventData.dismemberData.animationName));
                }
                // prevent the manager overriding our event
                if (eventData.dieOnDismember) {
					manager.customDeathAnimation = true;
				}
			} else {
                if (eventData.dieOnDismember || manager.GetHealth() <= 0f) {
                    DoRagdoll();
                }
            }
            if (destroyAfter > 0f && manager.GetHealth() <= 0f) {
                Destroy(gameObject, destroyAfter);
            }
			if (eventData.dismemberData.OnTrigger != null) {
				eventData.dismemberData.OnTrigger.Invoke(eventData.dmgType);
			}
		}

		public void OnDismember(DAMAGETYPE dmgType, Transform parent, bool dieOnDismember) {
			AdvancedDismemberEventData eventData = new AdvancedDismemberEventData (dmgType, parent, dieOnDismember);
			switch (dmgType) {
				case DAMAGETYPE.HEAD:
					eventData.dismemberData = Decapitation;
					break;
				case DAMAGETYPE.ARM:
					eventData.dismemberData = Arm;
					break;
				case DAMAGETYPE.HAND:
					eventData.dismemberData = Hand;
					break;
				case DAMAGETYPE.THIGH:
					eventData.dismemberData = UpperLeg;
					break;
				case DAMAGETYPE.LEG:
					eventData.dismemberData = LowerLeg;
					break;
				case DAMAGETYPE.FOOT:
					eventData.dismemberData = Foot;
					break;
			}
			TriggerEvent (eventData);
		}
	}
}