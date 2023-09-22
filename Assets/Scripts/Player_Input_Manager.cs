using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

public enum CombatInputs
{
    primary,
    secondary,
    third,
}

public class Player_Input_Manager : MonoBehaviour
{
    private PlayerInput playerInput;
    private Camera cam;
    [HideInInspector]
    public PlayerBase player;

    public Vector3 RawMovementInput { get; private set; }
    public Vector3 RawDashDirectionInput { get; private set; }
    public Vector3Int DashDirectionInput { get; private set; }
    public Vector3 RawAimDirectionInput { get; private set; }
    public Vector3Int AimDirectionInput { get; private set; }
    public Vector3 RawDodgeDirectionInput { get; private set; }

    public int NormInputX { get; private set; }
    public int NormInputY { get; private set; }
    public int NormInputZ { get; private set; }

    public bool JumpInput { get; private set; }
    public bool JumpInputStop { get; private set; }
    public bool GrabInput { get; private set; }
    public bool AbilityInput { get; private set; }
    public bool AbilityInputStop { get; private set; }

    public bool[] AttackInputs { get; private set; }

    [SerializeField]
    private float inputHoldTime = 0.2f;

    private float jumpInputStartTime;
    private float abilityInputStartTime;

    private void Start()
    {
        player = GetComponent<PlayerBase>();
        playerInput = GetComponent<PlayerInput>();
        cam = Camera.main;

        int count = Enum.GetValues(typeof(CombatInputs)).Length;
        AttackInputs = new bool[count];

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void Update()
    {
        CheckJumpInputHoldTime();
        CheckAbilityInputHoldTime();
    }


    #region Direction and Logic Input
    public void OnPrimaryAttackInput(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            AttackInputs[(int)CombatInputs.primary] = true;
        }

        if (context.canceled)
        {
            AttackInputs[((int)CombatInputs.primary)] = false;
        }
    }

    public void OnSecondaryAttackInput(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            AttackInputs[(int)CombatInputs.secondary] = true;
        }

        if (context.canceled)
        {
            AttackInputs[((int)CombatInputs.secondary)] = false;
        }
    }

    public void OnThirdAttackInput(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            AttackInputs[(int)CombatInputs.third] = true;
        }

        if (context.canceled)
        {
            AttackInputs[((int)CombatInputs.third)] = false;
        }
    }
    public void OnMoveInput(InputAction.CallbackContext context)
    {
        RawMovementInput = context.ReadValue<Vector3>();

        NormInputX = Mathf.RoundToInt(RawMovementInput.x);
        NormInputY = Mathf.RoundToInt(RawMovementInput.y);
        NormInputZ = Mathf.RoundToInt(RawMovementInput.z);

    }

    public void OnJumpInput(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            JumpInput = true;
            JumpInputStop = false;
            jumpInputStartTime = Time.time;
        }

        if (context.canceled)
        {
            JumpInputStop = true;
        }
    }

    public void OnGrabInput(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            GrabInput = true;
        }

        if (context.canceled)
        {
            GrabInput = false;
        }
    }

    public void OnAbilityInput(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            AbilityInput = true;
            AbilityInputStop = false;
        }
        else if (context.canceled)
        {
            AbilityInput = false;
            AbilityInputStop = true;

        }
    }
    #endregion

    #region Consume Input
    public void UseJumpInput() => JumpInput = false;
    public void UseAbilityInput() => AbilityInput = false;
    #endregion

    #region Check Input Hold Time
    private void CheckJumpInputHoldTime()
    {
        if (Time.time >= jumpInputStartTime + inputHoldTime)
        {
            JumpInput = false;
        }
    }
    private void CheckAbilityInputHoldTime()
    {
        if (AbilityInputStop)
        {
            if (Time.time >= abilityInputStartTime + inputHoldTime)
            {
                AbilityInput = false;
                AbilityInputStop = false;
            }
        }
    }
    #endregion

}
