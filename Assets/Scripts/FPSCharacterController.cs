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

    private bool runInputHeld = false;

    private float cameraPitch;
    private float cameraYaw;

    private Vector2 movementInput = Vector2.zero;
    private Vector2 inputMouseDelta = Vector2.zero;

    private CharacterController characterController = null;

    #region Health
    [SerializeField]
    private float maxHealth;
    [ReadOnly]
    public float currentHealth;
    #endregion

    private void Awake()
    {
        TryGetComponent(out characterController);

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
        currentHealth = maxHealth;
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

        float moveSpeed = runInputHeld ? moveSpeed_Run : moveSpeed_Walk;

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
        return runInputHeld && velocity.sqrMagnitude > 0.1f;
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

    public void Damage(float damage)
    {
        currentHealth -= damage;
        if (currentHealth < 0f)
            Debug.Log("You're Dead");
    }


}