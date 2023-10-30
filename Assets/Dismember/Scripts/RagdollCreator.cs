#if UNITY_EDITOR
/*
	Ragdoll creator Version 1.1
	Changes in 1.1:
	- Tweaked some joint parameters to limit repeated bounces of the head
	- Added neck to the ragdoll
	
	This is a helperclass for the dismembering system.
	This is also why it doesn't add colliders to the ragdoll, that is to be done with the dismembering system.

	I haven't tested it in runtime as I only need it in the editor.
	If you want to use it at runtime you have to remove the precompiler flags (#if UNITY_EDITOR and #endif)

	Regards
	Thomas 'ungamed' Hartvig (HartvigsIT)
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Ungamed.Dismember {

	public class JointParms {
		public Vector3 axis;
		public Vector3 swingAxis;

		public float lowTwistLimit 		= -20f;
		public float highTwistLimit 	= 0f;
		public float swing1Limit 		= 0f;
		public float swing2Limit 		= 0f;

		public JointParms() {
			axis 		= new Vector3 (0f, 0f, -1f);
			swingAxis 	= new Vector3 (1f, 0f, 0f);
		}
	}

	public class RagdollCreator {
		public float totalMass = 20f;

		private Animator animator;

		public RagdollCreator(GameObject gameObject) {
			animator = gameObject.GetComponent<Animator>();
		}

		Transform getBone(HumanBodyBones humanBodyBone) {
			return animator.GetBoneTransform(humanBodyBone);
		}

		// helper function to set up the ragdoll
		SoftJointLimit getJointLimit(float limit, float bounciness = 0f, float contactDistance = 0f) {
			SoftJointLimit result 	= new SoftJointLimit();
			result.limit 			= limit;
			result.bounciness 		= bounciness;
			result.contactDistance 	= contactDistance;
			return result;
		}

		Rigidbody CreateRagdollPart(HumanBodyBones bone, float massMultiplier, Rigidbody connectedBody, JointParms jointParms) {
			Transform thisBone = getBone(bone);
			Rigidbody rb = thisBone.gameObject.GetComponent<Rigidbody>();
			if (!rb) {
				rb = thisBone.gameObject.AddComponent<Rigidbody>();
			}
			rb.mass = totalMass * massMultiplier;
			rb.isKinematic = true;

			if (connectedBody) {
				CharacterJoint cJoint 	= thisBone.gameObject.GetComponent<CharacterJoint>();
				if (!cJoint) {
					cJoint 				=  thisBone.gameObject.AddComponent<CharacterJoint>();
				}
				cJoint.axis 			= jointParms.axis;
				cJoint.swingAxis 		= jointParms.swingAxis;
				cJoint.connectedBody 	= connectedBody;				
				cJoint.lowTwistLimit 	= getJointLimit(jointParms.lowTwistLimit);
				cJoint.highTwistLimit 	= getJointLimit(jointParms.highTwistLimit);
				cJoint.swing1Limit 		= getJointLimit(jointParms.swing1Limit);
				cJoint.swing2Limit 		= getJointLimit(jointParms.swing2Limit);
				cJoint.enablePreprocessing = false;
			}
			return rb;
		}

		public void Create() {
			JointParms jointParms 		= new JointParms();
			// Create Root object (Hips)
			Rigidbody rootRB 			= CreateRagdollPart(HumanBodyBones.Hips, 0.2f, null, jointParms);
			// Create Body
			jointParms.highTwistLimit 	= 20f;
			jointParms.swing1Limit 		= 10f;
			Rigidbody bodyRB 			= CreateRagdollPart(HumanBodyBones.Chest, 0.4f, rootRB, jointParms);
			jointParms 					= new JointParms(); // reset the values to default
			// Create Head
			jointParms.lowTwistLimit 	= -20f;
			jointParms.highTwistLimit 	= 0f;
			jointParms.swing1Limit 		= 25f;
			CreateRagdollPart(HumanBodyBones.Head, 0.2f, bodyRB, jointParms);
			jointParms 					= new JointParms(); // reset the values to default
			// Create Neck
			jointParms.lowTwistLimit 	= 0f;//-40f;
			jointParms.highTwistLimit 	= 0f;//25f;
			jointParms.swing1Limit 		= 0f;//25f;
			CreateRagdollPart(HumanBodyBones.Neck, 0.02f, bodyRB, jointParms);
			jointParms 					= new JointParms(); // reset the values to default
			// Create UpperArms
			jointParms.lowTwistLimit 	= -70f;
			jointParms.highTwistLimit 	= 10f;
			jointParms.swing1Limit 		= 50f;
			jointParms.axis 			= new Vector3 (0f, -1f, 0f);
			jointParms.swingAxis 		= new Vector3 (0f, 0f, -1f);
			Rigidbody leftUpperArmRB 	= CreateRagdollPart(HumanBodyBones.LeftUpperArm, 0.2f, bodyRB, jointParms);
			Rigidbody rightUpperArmRB 	= CreateRagdollPart(HumanBodyBones.RightUpperArm, 0.2f, bodyRB, jointParms);
			jointParms 					= new JointParms(); // reset the values to default
			// Create LowerArms
			jointParms.lowTwistLimit 	= -90f;
			jointParms.axis 			= new Vector3 (0f, 0f, 1f);
			jointParms.swingAxis 		= new Vector3 (0f, -1f, 0f);
			Rigidbody leftLowerArmRB 	= CreateRagdollPart(HumanBodyBones.LeftLowerArm, 0.2f, leftUpperArmRB, jointParms);
			Rigidbody rightLowerArmRB 	= CreateRagdollPart(HumanBodyBones.RightLowerArm, 0.2f, rightUpperArmRB, jointParms);
			jointParms 					= new JointParms(); // reset the values to default
			// Create Hands
			CreateRagdollPart(HumanBodyBones.LeftHand, 0.02f, leftLowerArmRB, jointParms);
			CreateRagdollPart(HumanBodyBones.RightHand, 0.02f, rightLowerArmRB, jointParms);
			jointParms 					= new JointParms(); // reset the values to default
			// Create UpperLegs
			jointParms.lowTwistLimit 	= -20f;
			jointParms.highTwistLimit 	= 70f;
			jointParms.swing1Limit 		= 30f;
			jointParms.axis 			= new Vector3 (0f, 0f, 1f);
			jointParms.swingAxis 		= new Vector3 (1f, 0f, 0f);
			Rigidbody leftUpperLegRB 	= CreateRagdollPart(HumanBodyBones.LeftUpperLeg, 0.2f, rootRB, jointParms);
			Rigidbody rightUpperLegRB 	= CreateRagdollPart(HumanBodyBones.RightUpperLeg, 0.2f, rootRB, jointParms);
			jointParms 					= new JointParms(); // reset the values to default
			// Create LowerLegs
			jointParms.lowTwistLimit 	= -80f;
			jointParms.highTwistLimit 	= 0f;
			jointParms.swing1Limit 		= 0f;
			jointParms.axis 			= new Vector3 (0f, 0f, 1f);
			jointParms.swingAxis 		= new Vector3 (1f, 0f, 0f);
			Rigidbody leftLowerLegRB 	= CreateRagdollPart(HumanBodyBones.LeftLowerLeg, 0.2f, leftUpperLegRB, jointParms);
			Rigidbody rightLowerLegRB 	= CreateRagdollPart(HumanBodyBones.RightLowerLeg, 0.2f, rightUpperLegRB, jointParms);
			jointParms 					= new JointParms(); // reset the values to default
			// Create Feet
			CreateRagdollPart(HumanBodyBones.LeftFoot, 0.02f, leftLowerLegRB, jointParms);
			CreateRagdollPart(HumanBodyBones.RightFoot, 0.02f, rightLowerLegRB, jointParms);
		}
	}
}
#endif