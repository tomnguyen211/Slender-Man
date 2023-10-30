/*
	Collider Helper 1.0

	Helperclass for creating colliders that match the dimmensions of a mesh and is aligned with a bone (transform)
*/
#if UNITY_EDITOR
using UnityEngine;
using System.Collections.Generic;

namespace Ungamed.Dismember {
	public class ColliderHelper {

		private delegate object createColliderDelegate(SkinnedMeshRenderer meshRenderer, Transform boneTransform);

		private Dictionary<System.Type, createColliderDelegate> colliderFunctions = new Dictionary<System.Type, createColliderDelegate>();

		// Constructor enumerates the delegates for type specific calls
		public ColliderHelper() {
			// Enumerate the delegates
			colliderFunctions.Add(typeof(BoxCollider), AddBoxCollider);
			colliderFunctions.Add(typeof(SphereCollider), AddSphereCollider);
			colliderFunctions.Add(typeof(CapsuleCollider), AddCapsuleCollider);
		}

		// Adds a collider of the type T fitting the size of the mesh as a component to the bone
		public T AddCollider<T>(SkinnedMeshRenderer meshRenderer, Transform boneTransform) where T: Collider {
			return (T)colliderFunctions[typeof(T)](meshRenderer, boneTransform);
		}

		Bounds GetColliderBounds(Transform localspace, SkinnedMeshRenderer meshRender, float scale=1f) {
			Bounds bounds = meshRender.sharedMesh.bounds;
			Vector3 position = localspace.InverseTransformPoint (meshRender.transform.TransformPoint (bounds.center));
			return new Bounds (position, bounds.size*scale);
		}

		BoxCollider AddBoxCollider(SkinnedMeshRenderer meshRenderer, Transform boneTransform) {

			BoxCollider bodypartCollider = boneTransform.gameObject.GetComponent<BoxCollider> ();
			if (!bodypartCollider) 
				bodypartCollider = boneTransform.gameObject.AddComponent<BoxCollider> ();
			//bodypartCollider.isTrigger = true;
			Bounds bodyBounds = GetColliderBounds (
				                    boneTransform,
				                    meshRenderer,
				                    .7f // small scale because otherwise it's always to big.
			                    );

			Vector3 newDirections = new Vector3 (
				                        bodyBounds.size.y,
				                        bodyBounds.size.z,
				                        bodyBounds.size.x
			                        );

			bodypartCollider.size = newDirections;
			bodypartCollider.center = bodyBounds.center;
			return bodypartCollider;
		}

		SphereCollider AddSphereCollider(SkinnedMeshRenderer meshRenderer, Transform boneTransform) {

			SphereCollider bodypartCollider = boneTransform.gameObject.GetComponent<SphereCollider> ();
			if (!bodypartCollider) 
				bodypartCollider = boneTransform.gameObject.AddComponent<SphereCollider> ();
			//bodypartCollider.isTrigger = true;

			Bounds bodyBounds = GetColliderBounds (
				boneTransform,
				meshRenderer
			);

			float diameter = Mathf.Max (bodyBounds.size.x, bodyBounds.size.y);
			diameter = Mathf.Max (diameter, bodyBounds.size.z);
			bodypartCollider.radius = diameter/2;
			bodypartCollider.center = bodyBounds.center;
			return bodypartCollider;
		}

		// Helper function for orienting the capsule collider
		float GetHighest(Vector3 source) {
			return source.x >= source.y && source.x >= source.z ? source.x :
				source.y >= source.x && source.y >= source.z ? source.y :
				source.z;
		}
		
		// Helper function for orienting the capsule collider
		float GetLowest(Vector3 source) {
			return source.x <= source.y && source.x <= source.z ? source.x :
				source.y <= source.x && source.y <= source.z ? source.y :
				source.z;
		}

		CapsuleCollider AddCapsuleCollider(SkinnedMeshRenderer meshRenderer, Transform boneTransform) {

			CapsuleCollider bodypartCollider = boneTransform.gameObject.GetComponent<CapsuleCollider> ();
			if (!bodypartCollider) 
				bodypartCollider = boneTransform.gameObject.AddComponent<CapsuleCollider> ();
			//bodypartCollider.isTrigger = true;

			Bounds bodyBounds = GetColliderBounds (
				boneTransform,
				meshRenderer
			);

			//Get orientation
			Vector3 nextPosition = boneTransform.GetChild(0)?boneTransform.GetChild(0).localPosition:bodyBounds.center;
			Vector3 direction = boneTransform.localPosition - nextPosition;
			direction = new Vector3 (Mathf.Abs (direction.x), Mathf.Abs (direction.y), Mathf.Abs (direction.z));
			int ColliderDirection = 0; // assume x as default direction
			float capsuleHeight = GetHighest(bodyBounds.size);
			float capsuleRadius = GetLowest(bodyBounds.size)/2;

			if (direction.y > direction.x && direction.y > direction.z) {
				ColliderDirection = 1; // y is the direction
				capsuleHeight = bodyBounds.size.y;
				capsuleRadius = bodyBounds.size.x / 2;
			} else if (direction.z > direction.y && direction.z > direction.x) {
				ColliderDirection = 2; // z is the direction
				capsuleHeight = bodyBounds.size.z;
				capsuleRadius = bodyBounds.size.y / 2;
			}

			bodypartCollider.radius = capsuleRadius;
			bodypartCollider.height = capsuleHeight;
			bodypartCollider.center = bodyBounds.center;
			bodypartCollider.direction = ColliderDirection; // 0=X,1=Y,2=Z

			return bodypartCollider;
		}
	}
}
#endif