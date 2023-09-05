using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using static UnityEditor.Experimental.GraphView.GraphView;

public class PlayerBase : MonoBehaviour
{

    #region State Variables
    public PlayerStateMachine StateMachine { get; private set; }
    [SerializeField]
    public PlayerData playerData;
    #endregion

    #region Components
    public Animator Anim;
    public Rigidbody RB { get; private set; }
    #endregion

    #region Check Transforms
    [SerializeField]
    private Transform groundCheck;
    [SerializeField]
    private Transform wallCheck;
    [SerializeField]
    private Transform ledgeCheck;
    [SerializeField]
    private Transform ceilingCheck;
    #endregion

    #region Other Variables
    protected bool Checkpoint;
    public Vector3 CurrentVelocity { get; private set; }
    private Vector3 workspace;
    [SerializeField] protected Transform ShootPoint;
    public Player_Input_Manager InputHandler { get; private set; }

    #endregion

    #region Unity Callback Function

    public virtual void Awake()
    {
        StateMachine = new PlayerStateMachine();
    }

    public virtual void Start()
    {
        RB = GetComponent<Rigidbody>();
        InputHandler = GetComponent<Player_Input_Manager>();
    }

    public virtual void Update()
    {
        CurrentVelocity = RB.velocity;
    }
    public virtual void FixedUpdate()
    {
    }
    #endregion

    #region Set Functions
    public void SetVelocityZero()
    {
        RB.velocity = Vector3.zero;
        CurrentVelocity = Vector3.zero;
    }
    public void SetVelocity(float velocity, Vector3 direction)
    {
        workspace = direction * velocity;
        RB.velocity = workspace;
        CurrentVelocity = workspace;
    }
    public void SetVelocityX(float velocity)
    {
        workspace.Set(velocity, CurrentVelocity.y, CurrentVelocity.z);
        RB.velocity = workspace;
        CurrentVelocity = workspace;
    }
    public void SetVelocityY(float velocity)
    {
        workspace.Set(CurrentVelocity.x, velocity, CurrentVelocity.z);
        RB.velocity = workspace;
        CurrentVelocity = workspace;
    }
    public void SetVelocityZ(float velocity)
    {
        workspace.Set(CurrentVelocity.x, CurrentVelocity.y, velocity);
        RB.velocity = workspace;
        CurrentVelocity = workspace;
    }
    public void SetVelocity(float velocity, Vector3 angle, int direction)
    {
        angle.Normalize();
        workspace.Set(angle.x * velocity * direction, angle.y * velocity, angle.z * velocity * direction);
        RB.velocity = workspace;
        CurrentVelocity = workspace;
    }
    #endregion
    #region Get Functions
    #endregion
    #region Check Functions

    public bool CheckIfGrounded()
    {
        return Physics.OverlapSphere(groundCheck.position, playerData.groundCheckRadius, playerData.whatisGround).Length > 0;
    }
    public bool CheckForCeiling()
    {
        return Physics.OverlapSphere(ceilingCheck.position, playerData.groundCheckRadius, playerData.whatisGround).Length > 0;
    }

    public bool CheckIfTouchingWall()
    {
        return Physics.Raycast(wallCheck.position, Vector3.forward, playerData.wallCheckDistance, playerData.whatisGround);
    }
    public bool CheckIfTouchingLedge()
    {
        return Physics.Raycast(ledgeCheck.position, Vector3.forward, playerData.wallCheckDistance, playerData.whatisGround);
    }
    public bool CheckIfTouchingWallBack()
    {
        return Physics.Raycast(wallCheck.position, -Vector3.forward, playerData.wallCheckDistance, playerData.whatisGround);
    }

    public bool CheckIfTouchingCeiling()
    {
        return Physics.OverlapSphere(new Vector3(transform.position.x, transform.position.y, transform.position.z), playerData.ceilingCheckRadius, playerData.whatisGround).Length > 0;
    }

    #endregion

    #region Other Functions
    public virtual bool ProbabilityCheck(float val)
    {
        if (val == 0)
            return false;
        else if (val == -1)
            return true;
        else
            return (Random.Range(0, 100f) <= val);

    }
    public virtual bool IsBetween(float testValue, float bound1, float bound2)
    {
        if (bound1 > bound2)
            return testValue >= bound2 && testValue <= bound1;
        return testValue >= bound1 && testValue <= bound2;
    }
    public virtual void AdjustAllTag(string tagName)
    {
        transform.tag = tagName;
        Transform[] childrenObj = gameObject.GetComponentsInChildren<Transform>();
        for (int n = 0; n < childrenObj.Length; n++)
        {
            childrenObj[n].tag = tagName;
        }
    }

    public virtual void AdjustAllLayer(string layerName)
    {
        transform.gameObject.layer = LayerMask.NameToLayer(layerName);
        Transform[] childrenObj = gameObject.GetComponentsInChildren<Transform>();
        for (int n = 0; n < childrenObj.Length; n++)
        {
            childrenObj[n].gameObject.layer = LayerMask.NameToLayer(layerName);
        }
    }
    #endregion
    #region Health
   /* public virtual float Get_Health()
    {
        return Stats_Manager.healthCount;
    }*/
    public bool Get_Chechpoint() => Checkpoint;
    public virtual void MainHealthSet(float amount)
    {

    }
    #endregion

    #region SuperState
    public class Player_GroundState : PlayerState
    {
        protected int xInput;
        protected int yInput;
        protected int zInput;

        protected bool isTouchingCeiling;

        private bool jumpInput;
        private bool grabInput;
        protected bool isGrounded;
        private bool isTouchingWall;
        private bool isTouchingLedge;

        public Player_GroundState(PlayerBase player, PlayerStateMachine stateMachine, PlayerData playerData, string animBoolName) : base(player, stateMachine, playerData, animBoolName)
        {
        }

        public override void DoCheck()
        {
            base.DoCheck();
            isGrounded = player.CheckIfGrounded();
            isTouchingWall = player.CheckIfTouchingWall();
            isTouchingLedge = player.CheckIfTouchingLedge();
            isTouchingCeiling = player.CheckForCeiling();
        }

        public override void Enter()
        {
            base.Enter();
        }

        public override void Exit()
        {
            base.Exit();
        }

        public override void LogicUpdate()
        {
            base.LogicUpdate();

            xInput = player.InputHandler.NormInputX;
            yInput = player.InputHandler.NormInputY;
            zInput = player.InputHandler.NormInputY;
            jumpInput = player.InputHandler.JumpInput;
            grabInput = player.InputHandler.GrabInput;

        }

        public override void PhysicUpdate()
        {
            base.PhysicUpdate();
        }
    }

    public class PlayerInAirState: PlayerState
    {
        //Input
        private int xInput;
        private int yInput;
        private int zInput;
        private bool jumpInput;
        private bool jumpInputStop;
        private bool grabInput;
        private bool abilityInput;

        //Check
        private bool isGrounded;
        private bool isTouchingWall;
        private bool isTouchingWallBack;
        private bool oldIsTouchingWall;
        private bool oldIsTouchingWallBack;
        private bool isTouchingLedge;
        protected bool isTouchingCeiling;

        private bool coyoteTime;
        private bool wallJumpCoyoteTime;
        private bool isJumping;

        // Miscs
        private bool isCheckGround;

        public PlayerInAirState(PlayerBase player, PlayerStateMachine stateMachine, PlayerData playerData, string animBoolName) : base(player, stateMachine, playerData, animBoolName)
        {
        }

        public override void DoCheck()
        {
            base.DoCheck();

            oldIsTouchingWall = isTouchingWall;
            oldIsTouchingWallBack = isTouchingWallBack;

            isGrounded = player.CheckIfGrounded();
            isTouchingWall = player.CheckIfTouchingWall();
            isTouchingWallBack = player.CheckIfTouchingWallBack();
            isTouchingLedge = player.CheckIfTouchingLedge();
            isTouchingCeiling = player.CheckForCeiling();
        }

        public override void Enter()
        {
            base.Enter();
            isCheckGround = false;
        }

        public override void Exit()
        {
            base.Exit();

            oldIsTouchingWall = false;
            oldIsTouchingWallBack = false;
            isTouchingWall = false;
            isTouchingWallBack = false;
        }

        public override void LogicUpdate()
        {
            base.LogicUpdate();

            CheckCoyoteTime();

            xInput = player.InputHandler.NormInputX;
            yInput = player.InputHandler.NormInputY;
            zInput = player.InputHandler.NormInputY;

            jumpInput = player.InputHandler.JumpInput;
            jumpInputStop = player.InputHandler.JumpInputStop;
            grabInput = player.InputHandler.GrabInput;
            abilityInput = player.InputHandler.AbilityInput;

            //CheckGround_SFX();

            CheckJumpMultiplier();

            /* if (_player.InputHandler.AttackInputs[(int)CombatInputs.third] && _player.PlayerThrowing_Wolf.CheckIfCanThrow())
             {
                 stateMachine.ChangeState(_player.PlayerThrowing_Wolf);
             }
             else if (_player.InputHandler.AbilityInput && _player.InputHandler.AttackInputs[(int)CombatInputs.secondary] && _player.ThrowShieldState.CheckIfCanThrow())
             {
                 stateMachine.ChangeState(_player.ThrowShieldState);
             }*/
            /*if (_player.InputHandler.AttackInputs[(int)CombatInputs.primary] && yInput > 0 && _player.PlayerSlashUp_Scorpion.CheckIfCanSlashUp())
            {
                stateMachine.ChangeState(_player.PlayerSlashUp_Scorpion);
            }
            else if (abilityInput && _player.InputHandler.AttackInputs[(int)CombatInputs.primary] && _player.PlayerSlamDown_Scorpion.CheckIfSlamDown())
            {
                stateMachine.ChangeState(_player.PlayerSlamDown_Scorpion);
            }
            else if (_player.InputHandler.AttackInputs[(int)CombatInputs.primary])
            {
                stateMachine.ChangeState(_player.PlayerAttackStage_Scorpion);
            }
            else if (isGrounded && _player.CurrentVelocity.y < 0.01f)
            {
                stateMachine.ChangeState(_player.PlayerLandState_Scorpion);
            }
            else if (isTouchingWall && !isTouchingLedge && !isGrounded && !CheckForSpace(_player.DetermineCornerPosition()) && xInput != 0)
            {
                stateMachine.ChangeState(_player.PlayerLedgeClimbState_Scorpion);
            }
            else if (jumpInput && (isTouchingWall || isTouchingWallBack || wallJumpCoyoteTime))
            {
                StopWallJumpCoyoteTime();
                isTouchingWall = _player.CheckIfTouchingWall();
                _player.PlayerWallJumpState_Scorpion.DetermineWallJumpDirection(isTouchingWall);
                stateMachine.ChangeState(_player.PlayerWallJumpState_Scorpion);
            }
            else if (jumpInput && _player.PlayerJumpStage_Scorpion.CanJump())
            {
                stateMachine.ChangeState(_player.PlayerJumpStage_Scorpion);
            }
            else if (isTouchingWall && grabInput && isTouchingLedge)
            {
                stateMachine.ChangeState(_player.PlayerWallGrabState_Scorpion);
            }
            else if (isTouchingWall && xInput == player.FacingDirection && _player.CurrentVelocity.y <= 0)
            {
                stateMachine.ChangeState(_player.PlayerWallSlideState_Scorpion);
            }
            else if (dashInput && _player.PlayerDashState_Scorpion.CheckIfCanDash())
            {
                stateMachine.ChangeState(_player.PlayerDashState_Scorpion);
            }
            else
            {
                _player.CheckIfShouldFlip(xInput);

                if (!_player.CheckIfKnockback)
                    _player.SetVelocityX(_player.armor_manager.moveSpeed * xInput);

                for (int i = 0; i < player.Anim.Length; i++)
                {
                    _player.Anim[i].SetFloat("yVelocity", _player.CurrentVelocity.y);
                    _player.Anim[i].SetFloat("xVelocity", Mathf.Abs(_player.CurrentVelocity.x));
                }
            }*/
        }

        private void CheckJumpMultiplier()
        {
            if (isJumping)
            {
                if (jumpInputStop)
                {
                    player.SetVelocityY(player.CurrentVelocity.y * playerData.variableJumpHeightMultiplier);
                    isJumping = false;
                }
                else if (player.CurrentVelocity.y <= 0)
                {
                    isJumping = false;
                }
            }
        }

        public override void PhysicUpdate()
        {
            base.PhysicUpdate();
            player.RB.drag = 0;
        }

        private void CheckCoyoteTime()
        {
            if (coyoteTime && Time.time > startTime + playerData.coyoteTime)
            {
                coyoteTime = false;
                //player.PlayerJumpStage_Scorpion.DecreaseAmountOfJumpLeft();
            }
        }

        public void StartCoyoteTime() => coyoteTime = true;

        public void SetIsJumping() => isJumping = true;

        private bool CheckForSpace(Vector3 cornerPosition)
        {
            return Physics2D.Raycast(cornerPosition + (Vector3.up * 0.1f) + (Vector3.forward * 0.015f), Vector2.up, playerData.standColliderHeight, playerData.whatisGround);
        }


      /*  private void CheckGround_SFX()
        {
            RaycastHit2D rayGround = Physics2D.Raycast(_player.transform.position, Vector2.down, 1f, _player.playerData.whatisGround);
            if (!isCheckGround && rayGround && _player.CurrentVelocity.y < -1)
            {
                _player.Movement_Manager.FallingVelocity.Invoke(_player.CurrentVelocity.y);
                isCheckGround = true;
            }
        }*/

    }
    #endregion
}
