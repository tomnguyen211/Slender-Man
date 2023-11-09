using System.Collections;
using Unity.Collections;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
[DefaultExecutionOrder(-1)]
public class FPSCharacterController : MonoBehaviour, IDamage
{
    [Header("Input Settings")]
    [SerializeField] private string inputAxis_MoveHorizontal = "Horizontal";
    [SerializeField] private string inputAxis_MoveVertical = "Vertical";
    [SerializeField] private string inputAxis_MouseX = "Mouse X";
    [SerializeField] private string inputAxis_MouseY = "Mouse Y";

    [Header("Movement Settings")]
    [SerializeField, Min(0f)] private float moveSpeed_Walk = 2.2f;
    [SerializeField, Min(0f)] private float moveSpeed_Run = 4.0f;

    [Header("Camera Settings")]
    [SerializeField, Min(0f)] private float cameraHeight = 1.7f;
    [SerializeField] private float cameraMouseSensitivity = 1f;
    [SerializeField] private float cameraMinPitch = 0f;
    [SerializeField] private float cameraMaxPitch = 0f;
    [SerializeField] private Transform cameraTransform = null;

    [SerializeField]
    private bool runInputHeld = false;

    private bool manaIEnumeratorRunning = false;
    IEnumerator manaIEnumerator;

    private float cameraPitch;
    private float cameraYaw;

    private Vector2 movementInput = Vector2.zero;
    private Vector2 inputMouseDelta = Vector2.zero;

    private CharacterController characterController = null;
    private FPSHandsController handController = null;

    #region Health, Manar
    [SerializeField]
    private float maxHealth;
    [ReadOnly]
    public float currentHealth;
    [SerializeField]
    private float maxMana;
    [ReadOnly]
    public float currentMana;
    [SerializeField]
    ScreenDamage ScreenDamage;
    [ReadOnly]
    GameObject Attacker;
    #endregion

    private void Awake()
    {
        TryGetComponent(out characterController);
        TryGetComponent(out handController);

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        if (cameraTransform != null)
        {
            Vector3 cameraEuler = cameraTransform.rotation.eulerAngles;
            cameraPitch = cameraEuler.x;
            cameraYaw = cameraEuler.y;
        }
    }

    private void Start()
    {
        ScreenDamage.maxHealth = ScreenDamage.CurrentHealth = currentHealth = maxHealth;
        currentMana = maxMana;
        handController.currentBattery = handController.batteryMax;
        GameManager.Instance.CharacterBar.Init(maxHealth, maxMana, handController.batteryMax);
    }

    private void Update()
    {
        if (cameraTransform == null)
        {
            Debug.LogError($"{GetType().Name}.Update(): cameraTransform reference is null - exiting early & disabling component", gameObject);
            this.enabled = false;
            return;
        }

        UpdateInput();
        UpdateTransform();
        UpdateCameraRotation();

    }

    private void LateUpdate()
    {
        if (cameraTransform == null)
        {
            Debug.LogError($"{GetType().Name}.LateUpdate(): cameraTransform reference is null - exiting early & disabling component", gameObject);
            this.enabled = false;
            return;
        }

        UpdateCameraPosition();
        Mana();
    }

    private void UpdateInput()
    {
        runInputHeld = Input.GetKey(KeyCode.LeftShift);

        movementInput = new Vector2(Input.GetAxis(inputAxis_MoveHorizontal), Input.GetAxis(inputAxis_MoveVertical));
        movementInput = Vector2.ClampMagnitude(movementInput, 1.0f);

        inputMouseDelta = new Vector2(Input.GetAxis(inputAxis_MouseX), Input.GetAxis(inputAxis_MouseY));
    }

    private void UpdateCameraRotation()
    {
        cameraYaw += inputMouseDelta.x * cameraMouseSensitivity;
        cameraPitch += -inputMouseDelta.y * cameraMouseSensitivity;
        cameraPitch = Mathf.Clamp(cameraPitch, cameraMinPitch, cameraMaxPitch);

        if (cameraYaw < -180) cameraYaw += 360f;
        if (cameraYaw > 180f) cameraYaw -= 360f;

        if (cameraPitch < -180f) cameraPitch += 360f;
        if (cameraPitch > 180f) cameraPitch -= 360f;

        cameraTransform.rotation = Quaternion.Euler(cameraPitch, cameraYaw, 0f);
    }

    private void UpdateCameraPosition()
    {
        cameraTransform.position = transform.position + cameraHeight * transform.up;
    }

    private void UpdateTransform()
    {
        Vector3 cameraHorizontalForward = cameraTransform.forward;
        cameraHorizontalForward.y = 0;
        cameraHorizontalForward.Normalize();

        if (cameraHorizontalForward != Vector3.zero)
            transform.forward = cameraHorizontalForward;

        float moveSpeed = 0;

        if (currentMana > 0 && runInputHeld)
            moveSpeed = moveSpeed_Run;
        else
            moveSpeed = moveSpeed_Walk;


        //float moveSpeed = runInputHeld ? moveSpeed_Run : moveSpeed_Walk;

        Vector3 moveVector = Time.deltaTime * moveSpeed * (movementInput.x * transform.right + movementInput.y * transform.forward);
        moveVector.y = Time.deltaTime * Physics.gravity.y;

        characterController.Move(moveVector);
    }

    public bool IsRunning()
    {
        if (characterController.isGrounded == false)
            return false;

        Vector3 velocity = characterController.velocity;
        velocity.y = 0f;
        return runInputHeld && velocity.sqrMagnitude > 0.1f && currentMana > 0;
    }

    public bool IsWalking()
    {
        if (characterController.isGrounded == false)
            return false;
        Vector3 velocity = characterController.velocity;
        return velocity.sqrMagnitude > 0.1f && !runInputHeld;

    }

    public float GetMoveVelocityMagnitude()
    {
        if (characterController.isGrounded == false)
            return 0f;

        var velocity = characterController.velocity;
        velocity.y = 0f;
        return velocity.magnitude;
    }

    public void Damage(float damage, GameObject attacker)
    {
        currentHealth -= damage;
        ScreenDamage.CurrentHealth -= damage;
        Attacker = attacker;
        GameManager.Instance.CharacterBar.TakeDamage(damage);
        if (currentHealth < 0f)
            Debug.Log("You're Dead");
    }

    public void Mana()
    {
        if(runInputHeld && !manaIEnumeratorRunning && currentMana > 0)
        {
            manaIEnumeratorRunning = true;
            manaIEnumerator = ManaChange_Deduct();
            StartCoroutine(manaIEnumerator);
        }
        else if(currentMana < maxMana && !runInputHeld && !manaIEnumeratorRunning)
        {
            manaIEnumeratorRunning = true;
            manaIEnumerator = ManaChange_Add();
            StartCoroutine(manaIEnumerator);
        }
    }

    IEnumerator ManaChange_Add()
    {
        /* float time = 1;
         while (time > 0)
         {
             time -= Time.deltaTime;
             if (manaIEnumeratorRunning)
             {
                 StopCoroutine(manaIEnumerator);
                 yield break;
             }
             yield return null;
         }

         while (!manaIEnumeratorRunning && currentMana <= maxMana)
         {
             currentMana += Time.deltaTime * 2;
             GameManager.Instance.CharacterBar.se
             yield return null;
         }
         manaIEnumeratorRunning = false;
         StopCoroutine(manaIEnumerator);*/

        float time = 1;
        while (time > 0)
        {
            time -= Time.deltaTime;
            if (runInputHeld)
            {
                manaIEnumeratorRunning = false;
                StopCoroutine(manaIEnumerator);
                yield break;
            }
            yield return null;
        }

        time = 0.05f;

        while (!runInputHeld && currentMana < maxMana)
        {
            time -= Time.smoothDeltaTime;

            if(time < 0f)
            {
                currentMana += 1;
                GameManager.Instance.CharacterBar.RefreshMana(1, 1);
                time = 0.05f;
            }
            yield return null;
        }
        manaIEnumeratorRunning = false;
        StopCoroutine(manaIEnumerator);

    }

    IEnumerator ManaChange_Deduct()
    {
        /* while (manaIEnumeratorRunning && currentMana > 0)
         {
             currentMana -= Time.deltaTime;
             yield return null;
         }        
         StopCoroutine(manaIEnumerator);*/
        float time = 0.1f;

        while (runInputHeld && currentMana > 0)
        {
            time -= Time.smoothDeltaTime;

            if (time < 0f)
            {
                currentMana -= 1;
                GameManager.Instance.CharacterBar.UseMana(1, 1);
                time = 0.1f;
            }
            yield return null;
        }
        manaIEnumeratorRunning = false;
        StopCoroutine(manaIEnumerator);
    }

    public float GetHealth => currentHealth;
    public float GetMaxHealth => maxHealth;

    public float GetFirstAbilityBar => currentMana;
    public float GetFirstAbilityBarMax => maxMana;

   /* public float GetSecondAbilityBar => Stats_Manager.specialAbilityBarCount_2;
    public float GetSeocondManaAbilityMax => Stats_Manager.SpecialAbilityBar_2.BaseValue;*/

    
}