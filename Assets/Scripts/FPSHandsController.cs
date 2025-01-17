using System.Collections;
using System.Collections.Generic;
using Tensori.FPSHandsHorrorPack;
using UnityEngine;
using UnityEngine.Events;

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

    #region TimerCheck
    private bool resetTimerAnimationEnable = false;
    private float resetTimerAnimationCount = 1;
    #endregion

    public LayerMask armorLayer;
    public LayerMask groundLayer;

    #region Shooting
    [SerializeField] Transform bulletPoint;
    [SerializeField] Transform bulletCasing;

    [SerializeField] GameObject _crosshairGameObject;
    CrosshairController _crosshair;
    private int shootMaxCount = 0;
    float randX = 0;
    float randY = 0;


    #endregion


    private void Start()
    {
        _crosshair = _crosshairGameObject.GetComponent<CrosshairController>();
    }


    private void LateUpdate()
    {
        ValidateHeldItem();
        AdjustBulletPoistion();
        UpdateInput();
        UpdateHandsPose();
        UpdateMovementBounce(deltaTime: Time.deltaTime);
        UpdateHandsPosition();
        if (IsAttacking || IsReloading || currentHandsPose == null)
            return;

        PlayHandsAnimation(currentHandsPose.HandsAnimationStateName, currentHandsPose.AnimationStateBlendTime);
        PlayItemAnimation(currentHandsPose.ItemAnimationStateName, currentHandsPose.AnimationStateBlendTime);
    }

    private void AdjustBulletPoistion()
    {
        if (heldItemPreviousFrame != null)
        {
            if (IsAiming)
            {
                if (bulletCasing.localPosition == heldItemPreviousFrame.AimPose.bulletCasePos && bulletPoint.localPosition == heldItemPreviousFrame.AimPose.bulletPoint)
                    return;
                bulletPoint.localPosition = heldItemPreviousFrame.AimPose.bulletPoint;
                bulletCasing.localPosition = heldItemPreviousFrame.AimPose.bulletCasePos;
            }
            else
            {
                if (bulletCasing.localPosition == heldItemPreviousFrame.IdlePose.bulletCasePos && bulletPoint.localPosition == heldItemPreviousFrame.IdlePose.bulletPoint)
                    return;
                bulletPoint.localPosition = heldItemPreviousFrame.IdlePose.bulletPoint;
                bulletCasing.localPosition = heldItemPreviousFrame.IdlePose.bulletCasePos;
            }
        }
    }

    private void ValidateHeldItem()
    {
        if (heldItemPreviousFrame == heldItem)
            return;

        StopActiveCoroutines();

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

        Transform handsPivotBoneTransform = GetHandsBoneTransform(heldItem.HandsPivotBoneTransformName);

        if (handsPivotBoneTransform != null)
            heldItemTransform.SetParent(handsPivotBoneTransform, false);
        else
            Debug.LogWarning($"{GetType().Name}.validateHeldItem(): hands pivot bone not found with name {heldItem.HandsPivotBoneTransformName}", gameObject);

    }

    private void UpdateInput()
    {
        if (currentAttackAnimationIndex > 0 && attackCoroutine == null)
        {
            if (resetTimerAnimationCount <= 0)
                currentAttackAnimationIndex = 0;
            else
                resetTimerAnimationCount -= Time.deltaTime;
        }

        if (heldItem == null)
            return;

        if (heldItem.AttackAnimations.Count > 0 && Input.GetKeyDown(shootKey) && !resetTimerAnimationEnable) // Attacking
        {
            StopActiveCoroutines();

            resetTimerAnimationEnable = true;
            resetTimerAnimationCount = 1;

            attackCoroutine = StartCoroutine(Coroutine_updateAttackAnimation(currentAttackAnimationIndex));

            currentAttackAnimationIndex++;

            if (currentAttackAnimationIndex >= heldItem.AttackAnimations.Count)
                currentAttackAnimationIndex = 0;
        }

        if (Input.GetKeyDown(reloadKey))
        {
            StopActiveCoroutines();

            currentAttackAnimationIndex = 0;

            reloadCoroutine = StartCoroutine(Coroutine_updateAnimatedPose(heldItem.ReloadPose));
        }

        if (Input.GetKeyDown(aimKey))
            IsAiming = true;
        if (Input.GetKeyUp(aimKey))
            IsAiming = false;
    }

    private void StopActiveCoroutines()
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

    private void UpdateHandsPose()
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

    private void UpdateMovementBounce(float deltaTime)
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

    private void UpdateHandsPosition()
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

    private Transform GetHandsBoneTransform(string boneName)
    {
        handsTransform.GetComponentsInChildren(includeInactive: true, handsChildTransforms);

        Transform resultBone = null;

        for (int i = 0; i < handsChildTransforms.Count; i++)
        {
            if (handsChildTransforms[i].name == boneName)
            {
                resultBone = handsChildTransforms[i];
                break;
            }
        }

        handsChildTransforms.Clear();

        return resultBone;
    }

    private void PlayHandsAnimation(string animationStateName, float blendTime)
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

    private void PlayItemAnimation(string animationStateName, float blendTime)
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

    private IEnumerator Coroutine_updateAttackAnimation(int attackAnimationIndex)
    {
        var attackAnimSettings = heldItem.AttackAnimations[attackAnimationIndex];

        triggeredAnimationEvents.Clear();

        PlayHandsAnimation(attackAnimSettings.HandsAnimatorAttackStateName, attackAnimSettings.AttackAnimationBlendTime);
        PlayItemAnimation(attackAnimSettings.ItemAnimatorAttackStateName, attackAnimSettings.AttackAnimationBlendTime);

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

            // Timer i = 1 second //
            for (int i = 0; i < attackAnimSettings.AnimationEvents.Count; i++)
            {
                if (triggeredAnimationEvents.Contains(i))
                    continue;

                var animationEvent = attackAnimSettings.AnimationEvents[i];

                if (animationTime < animationEvent.EventPosition)
                    continue;

                triggeredAnimationEvents.Add(i);
                Debug.Log(animationEvent.EventMessage);
                OnAnimationEvent?.Invoke(animationEvent.EventMessage);
            }

            if (timer > attackAnimSettings.AttackAnimationLength * 4 / 5)
                resetTimerAnimationEnable = false;

            yield return null;
        }

        //currentAttackAnimationIndex = 0;
        resetTimerAnimationEnable = false;
        attackCoroutine = null;
    }

    private IEnumerator Coroutine_updateAnimatedPose(FPSItem.AnimatedItemPose animatedPose)
    {
        currentHandsPose = animatedPose;

        triggeredAnimationEvents.Clear();
        PlayHandsAnimation(animatedPose.HandsAnimationStateName, animatedPose.AnimationStateBlendTime);
        PlayItemAnimation(animatedPose.ItemAnimationStateName, animatedPose.AnimationStateBlendTime);

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
                Debug.Log("Passed");
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
        switch (animationEvent)
        {
            case "Bullet":
                TriggerBulletCasingAnimation();
                break;
            case "Shoot":
                TriggerAttackAnimation();
                break;
            default: break;
        }

    }


    public void TriggerBulletCasingAnimation()
    {
        GameObject cartridge = Instantiate(heldItemPreviousFrame.Stats.bulletCase, bulletCasing.transform.position, bulletCasing.rotation);
    }

    public void TriggerAttackAnimation()
    {
        if (heldItemPreviousFrame.HandsPivotBoneTransformName == "handgun")
        {
            GameObject muzzle = Instantiate(heldItemPreviousFrame.Stats.MuzzleFlash, bulletPoint.transform.position, Quaternion.identity);
            muzzle.transform.SetParent(bulletPoint);
            muzzle.transform.localEulerAngles = new Vector3(90, 90, 0);

            Vector3 shootRayOrigin = handsParentTransform.GetComponent<Camera>().ViewportToWorldPoint(new Vector3(0.5f, 0.5f, 0f));
            RaycastHit hit;

            if (_crosshair.GetState == CrossHairScale.Default)
            {
                shootMaxCount = 0;
            }

            if (fpsCharacterController.IsRunning())
            {
                randX = Random.Range(0.15f, -0.15f);
                randY = Random.Range(0.15f, -0.15f);
            }
            else if (fpsCharacterController.IsWalking())
            {
                randX = Random.Range(0.05f, -0.05f);
                randY = Random.Range(0.05f, -0.05f);
            }
            else
            {
                randX = 0;
                randY = 0;
            }

            if (_crosshair.GetState == CrossHairScale.Shoot && shootMaxCount < 5)
            {
                randX += Random.Range(0.01f, -0.01f);
                randY += Random.Range(0.01f, -0.01f);
                shootMaxCount++;
            }

            var DirectionRay = handsParentTransform.TransformDirection(randX, randY, 1);

            Debug.DrawRay(shootRayOrigin, DirectionRay * heldItemPreviousFrame.Stats.range, Color.red);

            if (Physics.Raycast(shootRayOrigin, DirectionRay, out hit, heldItemPreviousFrame.Stats.range))
            {
               
                if (hit.collider.CompareTag("Enemy"))
                {
                    Debug.Log(hit.collider.name + " is hit");

                    if (hit.collider.TryGetComponent<IDamage>(out IDamage component_1))
                    {
                        component_1.Damage(heldItemPreviousFrame.Stats.damage, hit);
                    }
                    else if (hit.collider.transform.parent != null && hit.collider.transform.parent.TryGetComponent<IDamage>(out IDamage component_2))
                    {
                        component_2.Damage(heldItemPreviousFrame.Stats.damage, hit);

                    }
                }
                else if (hit.collider.CompareTag("Ground"))
                {
                    float angle = Vector3.Angle(hit.normal, transform.up);
                    Quaternion startRot = Quaternion.LookRotation(hit.normal);
                    GameObject bulletHole = Instantiate(heldItemPreviousFrame.Stats.ImpactMark, hit.point, startRot);
                }
            }
            _crosshair.SetScale(CrossHairScale.Shoot, 1f);
        }
        else if(heldItemPreviousFrame.HandsPivotBoneTransformName == "shotgun")
        {
            GameObject muzzle = Instantiate(heldItemPreviousFrame.Stats.MuzzleFlash, bulletPoint.transform.position, Quaternion.identity);
            muzzle.transform.SetParent(bulletPoint);
            muzzle.transform.localEulerAngles = new Vector3(90, 90, 0);

            Vector3 shootRayOrigin = handsParentTransform.GetComponent<Camera>().ViewportToWorldPoint(new Vector3(0.5f, 0.5f, 0f));
            RaycastHit hit;

            if (_crosshair.GetState == CrossHairScale.Default)
            {
                shootMaxCount = 0;
            }

            if (fpsCharacterController.IsRunning())
            {
                randX = Random.Range(0.15f, -0.15f);
                randY = Random.Range(0.15f, -0.15f);
            }
            else if (fpsCharacterController.IsWalking())
            {
                randX = Random.Range(0.05f, -0.05f);
                randY = Random.Range(0.05f, -0.05f);
            }
            else
            {
                randX = 0;
                randY = 0;
            }

            if (_crosshair.GetState == CrossHairScale.Shoot && shootMaxCount < 5)
            {
                randX += Random.Range(0.01f, -0.01f);
                randY += Random.Range(0.01f, -0.01f);
                shootMaxCount++;
            }



            for(int i = 0; i < 10; i++)
            {
                var DirectionRay = handsParentTransform.TransformDirection(randX + Random.Range(-0.1f,0.1f), randY + Random.Range(-0.1f, 0.1f), 1);
                Debug.DrawRay(shootRayOrigin, DirectionRay * heldItemPreviousFrame.Stats.range, Color.red);

                if (Physics.Raycast(shootRayOrigin, DirectionRay, out hit, heldItemPreviousFrame.Stats.range))
                {
                    if (hit.collider.CompareTag("Enemy"))
                    {
                        Debug.Log(hit.collider.name + " is hit");

                        if (hit.collider.TryGetComponent<IDamage>(out IDamage component_1))
                        {
                            component_1.Damage(heldItemPreviousFrame.Stats.damage,hit);
                        }
                        else if (hit.collider.transform.parent != null && hit.collider.transform.parent.TryGetComponent<IDamage>(out IDamage component_2))
                        {
                            component_2.Damage(heldItemPreviousFrame.Stats.damage,hit);

                        }
                    }
                    else if (hit.collider.CompareTag("Ground"))
                    {
                        float angle = Vector3.Angle(hit.normal, transform.up);
                        Quaternion startRot = Quaternion.LookRotation(hit.normal);
                        GameObject bulletHole = Instantiate(heldItemPreviousFrame.Stats.ImpactMark, hit.point, startRot);
                    }
                }
            }          
           _crosshair.SetScale(CrossHairScale.Shoot, 1f);
        }
        else if (heldItemPreviousFrame.HandsPivotBoneTransformName == "fireaxe")
        {
            Debug.Log("Fire Axe");
            Vector3 shootRayOrigin = handsParentTransform.GetComponent<Camera>().ViewportToWorldPoint(new Vector3(0.5f, 0.5f, 0f));
            RaycastHit hit;

            shootMaxCount = 0;

            bulletPoint.position = shootRayOrigin + (handsParentTransform.forward * heldItemPreviousFrame.Stats.range);

             Collider[] rangeChecks = Physics.OverlapSphere(bulletPoint.position, heldItemPreviousFrame.Stats.range, armorLayer | groundLayer);

            if(rangeChecks.Length > 0)
            {
                for (int i = 0; i < rangeChecks.Length; i++)
                {
                    Transform target = rangeChecks[i].transform;
                    if (target.TryGetComponent<IDamage>(out IDamage component_1))
                    {
                        if (Physics.Raycast(shootRayOrigin, handsParentTransform.forward, out hit, heldItemPreviousFrame.Stats.range * 2))
                            component_1.Damage(heldItemPreviousFrame.Stats.damage, hit);
                        else
                            component_1.Damage(heldItemPreviousFrame.Stats.damage);
                    }
                    else if (target.parent != null && target.parent.TryGetComponent<IDamage>(out IDamage component_2))
                    {
                        if (Physics.Raycast(shootRayOrigin, handsParentTransform.forward, out hit, heldItemPreviousFrame.Stats.range * 2))
                            component_2.Damage(heldItemPreviousFrame.Stats.damage, hit);
                        else
                            component_2.Damage(heldItemPreviousFrame.Stats.damage);
                    }
                }
            }

            if (Physics.Raycast(shootRayOrigin, handsParentTransform.forward, out hit, heldItemPreviousFrame.Stats.range))
            {
                /*if (hit.collider.CompareTag("Ground"))
                {
                    float angle = Vector3.Angle(hit.normal, transform.up);
                    Quaternion startRot = Quaternion.LookRotation(hit.normal);
                    GameObject bulletHole = Instantiate(heldItemPreviousFrame.Stats.ImpactMark, hit.point, startRot);
                }*/
            }

            _crosshair.SetScale(CrossHairScale.Shoot, 1f);
        }
        else if (heldItemPreviousFrame.HandsPivotBoneTransformName == "kombat knife")
        {
            Vector3 shootRayOrigin = handsParentTransform.GetComponent<Camera>().ViewportToWorldPoint(new Vector3(0.5f, 0.5f, 0f));
            RaycastHit hit;

            shootMaxCount = 0;


            if (Physics.Raycast(shootRayOrigin, handsParentTransform.forward, out hit, heldItemPreviousFrame.Stats.range))
            {

                if (hit.collider.CompareTag("Enemy"))
                {
                    Debug.Log(hit.collider.name + " is hit");

                    if (hit.collider.TryGetComponent<IDamage>(out IDamage component_1))
                    {
                        component_1.Damage(heldItemPreviousFrame.Stats.damage, hit);
                    }
                    else if (hit.collider.transform.parent != null && hit.collider.transform.parent.TryGetComponent<IDamage>(out IDamage component_2))
                    {
                        component_2.Damage(heldItemPreviousFrame.Stats.damage, hit);

                    }
                }
                /*else if (hit.collider.CompareTag("Ground"))
                {
                    float angle = Vector3.Angle(hit.normal, transform.up);
                    Quaternion startRot = Quaternion.LookRotation(hit.normal);
                    GameObject bulletHole = Instantiate(heldItemPreviousFrame.Stats.ImpactMark, hit.point, startRot);
                }*/
            }
            _crosshair.SetScale(CrossHairScale.Shoot, 1f);
        }
        else if (heldItemPreviousFrame.HandsPivotBoneTransformName == "WeaponPivot")
        {
            Vector3 shootRayOrigin = handsParentTransform.GetComponent<Camera>().ViewportToWorldPoint(new Vector3(0.5f, 0.5f, 0f));
            RaycastHit hit;

            shootMaxCount = 0;


            if (Physics.Raycast(shootRayOrigin, handsParentTransform.forward, out hit, heldItemPreviousFrame.Stats.range))
            {

                if (hit.collider.CompareTag("Enemy"))
                {
                    Debug.Log(hit.collider.name + " is hit");

                    if (hit.collider.TryGetComponent<IDamage>(out IDamage component_1))
                    {
                        component_1.Damage(heldItemPreviousFrame.Stats.damage, hit);
                    }
                    else if (hit.collider.transform.parent != null && hit.collider.transform.parent.TryGetComponent<IDamage>(out IDamage component_2))
                    {
                        component_2.Damage(heldItemPreviousFrame.Stats.damage, hit);

                    }
                }
                /*else if (hit.collider.CompareTag("Ground"))
                {
                    float angle = Vector3.Angle(hit.normal, transform.up);
                    Quaternion startRot = Quaternion.LookRotation(hit.normal);
                    GameObject bulletHole = Instantiate(heldItemPreviousFrame.Stats.ImpactMark, hit.point, startRot);
                }*/
            }
            _crosshair.SetScale(CrossHairScale.Shoot, 1f);
        }
    }
}

