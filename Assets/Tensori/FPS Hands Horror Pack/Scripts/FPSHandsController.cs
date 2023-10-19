using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Events;

namespace Tensori.FPSHandsHorrorPack
{
    public class FPSHandsController : MonoBehaviour
    {
        public bool IsAttacking => attackCoroutine != null;
        public bool IsReloading => reloadCoroutine != null;

        [Tooltip("Current active item asset")]
        [SerializeField] private FPSItem heldItem = null;

        [Header("Input Settings")]
        [SerializeField] private KeyCode aimKey = KeyCode.Mouse1;
        [SerializeField] private KeyCode shootKey = KeyCode.Mouse0;
        [SerializeField] private KeyCode reloadKey = KeyCode.R;
        public bool IsAiming = false;

        [Header("Animator Settings")]
        [Tooltip("Name of the animator parameter that is used to control the playback position of animation states from the hands' animator component.")]
        [SerializeField] private string handsAnimatorTimeParameter = "AnimationTime";

        [Header("Object References")]
        [SerializeField] private FPSCharacterController fpsCharacterController = null;
        [SerializeField] private Transform handsParentTransform = null;
        [SerializeField] private Transform handsTransform = null;
        [SerializeField] private Animator handsAnimator = null;

        [Header("Events")]
        public UnityEvent<string> OnAnimationEvent = new UnityEvent<string>();

        private int currentAttackAnimationIndex = 0;

        private Vector2 movementBouncePositionOffset = Vector2.zero;

        private Vector3 handsPositionOffset = Vector3.zero;
        private Vector3 handsPositionVelocity = Vector3.zero;
        private Vector3 handsEulerOffset = Vector3.zero;
        private Vector3 handsEulerVelocity = Vector3.zero;

        private string currentHandsAnimationState = null;
        private string currentItemAnimationState = null;

        private FPSItem heldItemPreviousFrame = null;
        private Transform heldItemTransform = null;
        private Animator heldItemAnimator = null;
        private FPSItem.ItemPose currentHandsPose = null;
        private Coroutine attackCoroutine = null;
        private Coroutine reloadCoroutine = null;
        private List<Transform> handsChildTransforms = new List<Transform>();
        private List<int> triggeredAnimationEvents = new List<int>();

        private void LateUpdate()
        {
            validateHeldItem();
            updateInput();
            updateHandsPose();
            updateMovementBounce(deltaTime: Time.deltaTime);
            updateHandsPosition();

            if (IsAttacking || IsReloading || currentHandsPose == null)
                return;

            playHandsAnimation(currentHandsPose.HandsAnimationStateName, currentHandsPose.AnimationStateBlendTime);
            playItemAnimation(currentHandsPose.ItemAnimationStateName, currentHandsPose.AnimationStateBlendTime);
        }

        private void validateHeldItem()
        {
            if (heldItemPreviousFrame == heldItem)
                return;

            stopActiveCoroutines();

            if (heldItemTransform != null)
                Destroy(heldItemTransform.gameObject);

            heldItemTransform = null;
            heldItemAnimator = null;
            currentHandsAnimationState = null;
            currentItemAnimationState = null;

            heldItemPreviousFrame = heldItem;

            if (heldItem == null || heldItem.ItemPrefab == null)
                return;

            GameObject spawnedItem = Instantiate(heldItem.ItemPrefab, parent: null);
            heldItemTransform = spawnedItem.transform;
            heldItemAnimator = heldItemTransform.GetComponentInChildren<Animator>(includeInactive: true);

            if (heldItemAnimator == null)
                Debug.LogWarning($"{GetType().Name}.validateHeldItem(): spawned item object '{heldItemTransform.name}' doesn't have an animator component", spawnedItem);

            Transform handsPivotBoneTransform = getHandsBoneTransform(heldItem.HandsPivotBoneTransformName);

            if (handsPivotBoneTransform != null)
                heldItemTransform.SetParent(handsPivotBoneTransform, false);
            else
                Debug.LogWarning($"{GetType().Name}.validateHeldItem(): hands pivot bone not found with name {heldItem.HandsPivotBoneTransformName}", gameObject);
        }

        private void updateInput()
        {
            if (heldItem == null)
                return;

            if (heldItem.AttackAnimations.Count > 0 && Input.GetKeyDown(shootKey))
            {
                stopActiveCoroutines();

                attackCoroutine = StartCoroutine(coroutine_updateAttackAnimation(currentAttackAnimationIndex));

                currentAttackAnimationIndex++;

                if (currentAttackAnimationIndex >= heldItem.AttackAnimations.Count)
                    currentAttackAnimationIndex = 0;
            }

            if (Input.GetKeyDown(reloadKey))
            {
                stopActiveCoroutines();

                currentAttackAnimationIndex = 0;

                reloadCoroutine = StartCoroutine(coroutine_updateAnimatedPose(heldItem.ReloadPose));
            }

            if (Input.GetKeyDown(aimKey))
                IsAiming = true;
            if (Input.GetKeyUp(aimKey))
                IsAiming = false;
        }

        private void stopActiveCoroutines()
        {
            if (attackCoroutine != null)
            {
                StopCoroutine(attackCoroutine);
                attackCoroutine = null;
            }

            if (reloadCoroutine != null)
            {
                StopCoroutine(reloadCoroutine);
                reloadCoroutine = null;
            }
        }

        private void updateHandsPose()
        {
            if (IsReloading)
                return;

            currentHandsPose = null;

            if (heldItem == null)
                return;

            currentHandsPose = IsAiming ? heldItem.AimPose : heldItem.IdlePose;

            if (IsAttacking)
                return;

            if (fpsCharacterController != null && fpsCharacterController.IsRunning())
                currentHandsPose = heldItem.RunPose;
        }

        private void updateMovementBounce(float deltaTime)
        {
            if (fpsCharacterController == null || heldItem == null || currentHandsPose == null)
                return;

            float sine = Mathf.Sin(Time.time * currentHandsPose.MovementBounceSpeed);
            float cos = Mathf.Cos(Time.time * 0.5f * currentHandsPose.MovementBounceSpeed);

            float moveVelocityMagnitude = fpsCharacterController.GetMoveVelocityMagnitude();
            moveVelocityMagnitude = Mathf.Min(moveVelocityMagnitude, heldItem.MovementBounceVelocityLimit);
            moveVelocityMagnitude = moveVelocityMagnitude / heldItem.MovementBounceVelocityLimit;

            movementBouncePositionOffset += moveVelocityMagnitude * new Vector2(
                deltaTime * ((0.5f - cos) * 2f) * currentHandsPose.MovementBounceStrength_Horizontal,
                deltaTime * sine * currentHandsPose.MovementBounceStrength_Vertical);

            Vector2 dampingForce =
                (heldItem.MovementBounceSpringStiffness * -movementBouncePositionOffset) - 
                (heldItem.MovementBounceSpringDamping * deltaTime * movementBouncePositionOffset);

            movementBouncePositionOffset += deltaTime * dampingForce;
        }

        private void updateHandsPosition()
        {
            if (handsTransform == null)
            {
                Debug.LogWarning($"{GetType().Name}.updateHandsPosition(): handsTransform == null - exiting early", gameObject);
                return;
            }

            if (handsParentTransform == null)
            {
                Debug.LogWarning($"{GetType().Name}.updateHandsPosition(): handsParentTransform == null - exiting early", gameObject);
                return;
            }

            if (currentHandsPose != null)
            {
                handsPositionOffset = Vector3.SmoothDamp(
                    current: handsPositionOffset,
                    target: currentHandsPose.PositionOffset,
                    currentVelocity: ref handsPositionVelocity,
                    smoothTime: currentHandsPose.TransformSmoothDampTime,
                    maxSpeed: float.MaxValue,
                    deltaTime: Time.deltaTime);

                handsEulerOffset = Vector3.SmoothDamp(
                    current: handsEulerOffset,
                    target: currentHandsPose.EulerOffset,
                    currentVelocity: ref handsEulerVelocity,
                    smoothTime: currentHandsPose.TransformSmoothDampTime,
                    maxSpeed: float.MaxValue,
                    deltaTime: Time.deltaTime);
            }
            else
            {
                handsPositionOffset = Vector3.zero;
                handsEulerOffset = Vector3.zero;
            }

            Vector3 targetPosition = handsParentTransform.position + handsParentTransform.TransformVector(handsPositionOffset + (Vector3)movementBouncePositionOffset);
            Quaternion targetRotation = handsParentTransform.rotation * Quaternion.Euler(handsEulerOffset);

            handsTransform.SetPositionAndRotation(targetPosition, targetRotation);
        }

        private Transform getHandsBoneTransform(string boneName)
        {
            handsTransform.GetComponentsInChildren(includeInactive: true, handsChildTransforms);

            Transform resultBone = null;

            for (int i = 0; i < handsChildTransforms.Count; i++)
            {
                if (handsChildTransforms[i].name == boneName)
                {
                    resultBone =  handsChildTransforms[i];
                    break;
                }
            }

            handsChildTransforms.Clear();

            return resultBone;
        }

        private void playHandsAnimation(string animationStateName, float blendTime)
        {
            if (handsAnimator == null)
                return;

            if (animationStateName == currentHandsAnimationState)
                return;

            currentHandsAnimationState = animationStateName;

            if (handsAnimator.HasState(layerIndex: 0, Animator.StringToHash(animationStateName)))
                handsAnimator.CrossFadeInFixedTime(animationStateName, fixedTransitionDuration: blendTime, layer: 0);
            else
                Debug.LogWarning($"{GetType().Name}.playHandsAnimation(): hands animator does not have state '{animationStateName}'");
        }

        private void playItemAnimation(string animationStateName, float blendTime)
        {
            if (heldItemAnimator == null)
                return;

            if (animationStateName == currentItemAnimationState)
                return;

            currentItemAnimationState = animationStateName;

            if (heldItemAnimator.HasState(layerIndex: 0, Animator.StringToHash(animationStateName)))
                heldItemAnimator.CrossFadeInFixedTime(animationStateName, fixedTransitionDuration: blendTime, layer: 0);
            else
                Debug.LogWarning($"{GetType().Name}.playItemAnimation(): item animator does not have state '{animationStateName}'");
        }

        private IEnumerator coroutine_updateAttackAnimation(int attackAnimationIndex)
        {
            var attackAnimSettings = heldItem.AttackAnimations[attackAnimationIndex];

            triggeredAnimationEvents.Clear();

            playHandsAnimation(attackAnimSettings.HandsAnimatorAttackStateName, attackAnimSettings.AttackAnimationBlendTime);
            playItemAnimation(attackAnimSettings.ItemAnimatorAttackStateName, attackAnimSettings.AttackAnimationBlendTime);

            float timer = 0f;

            while (timer < attackAnimSettings.AttackAnimationLength)
            {
                if (heldItem == null)
                    break;

                timer += Time.deltaTime;
                float animationTime = timer / attackAnimSettings.AttackAnimationLength;

                handsAnimator.SetFloat(handsAnimatorTimeParameter, animationTime);

                if (heldItemAnimator != null)
                    heldItemAnimator.SetFloat(heldItem.ItemAnimatorTimeParameter, animationTime);

                for (int i = 0; i < attackAnimSettings.AnimationEvents.Count; i++)
                {
                    if (triggeredAnimationEvents.Contains(i))
                        continue;

                    var animationEvent = attackAnimSettings.AnimationEvents[i];

                    if (animationTime < animationEvent.EventPosition)
                        continue;

                    triggeredAnimationEvents.Add(i);
                    OnAnimationEvent?.Invoke(animationEvent.EventMessage);
                }

                yield return null;
            }

            currentAttackAnimationIndex = 0;

            attackCoroutine = null;
        }

        private IEnumerator coroutine_updateAnimatedPose(FPSItem.AnimatedItemPose animatedPose)
        {
            currentHandsPose = animatedPose;

            triggeredAnimationEvents.Clear();

            playHandsAnimation(animatedPose.HandsAnimationStateName, animatedPose.AnimationStateBlendTime);
            playItemAnimation(animatedPose.ItemAnimationStateName, animatedPose.AnimationStateBlendTime);

            float timer = 0f;

            while (timer < animatedPose.AnimationLength)
            {
                if (heldItem == null)
                    break;

                timer += Time.deltaTime;
                float animationTime = timer / animatedPose.AnimationLength;

                handsAnimator.SetFloat(handsAnimatorTimeParameter, animationTime);

                if (heldItemAnimator != null)
                    heldItemAnimator.SetFloat(heldItem.ItemAnimatorTimeParameter, animationTime);

                for (int i = 0; i < animatedPose.AnimationEvents.Count; i++)
                {
                    if (triggeredAnimationEvents.Contains(i))
                        continue;

                    var animationEvent = animatedPose.AnimationEvents[i];

                    if (animationTime < animationEvent.EventPosition)
                        continue;

                    triggeredAnimationEvents.Add(i);
                    OnAnimationEvent?.Invoke(animationEvent.EventMessage);
                }

                yield return null;
            }

            reloadCoroutine = null;
        }

        public void SetHeldItem(FPSItem item)
        {
            heldItem = item;
        }

        public void DebugLogAnimationEvent(string animationEvent)
        {
            Debug.Log($"{GetType().Name}.DebugLogAnimationEvent(): {animationEvent}");
        }
    }
}