using System.Collections.Generic;
using UnityEngine;

public class PlayerBase : MonoBehaviour
{
    public float horizontalInput;
    public float verticalInput;

    #region State Variables
    public PlayerStateMachine StateMachine { get; private set; }
    [SerializeField]
    public PlayerData playerData;
    #endregion

    #region States
    public PlayerIdleState PlayerIdleState { get; set; }
    public PlayerMoveState PlayerMoveState { get; set; }
    public PlayerInAirState PlayerInAirState { get; set; }
    public PlayerLandState PlayerLandState { get; set; }

    #endregion

    #region Components
    public Animator Anim;
    public Rigidbody RB { get; private set; }

    public CharacterController CharacterController { get; private set; }
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
    List<Collider> colliders;
    protected bool Checkpoint;
    public Vector3 CurrentVelocity { get; private set; }
    public Vector3 CurrentForceVelocity;

    private Vector3 workspace;
    [SerializeField]
    Transform orientation;
    [SerializeField] protected Transform ShootPoint;
    public Player_Input_Manager InputHandler { get; private set; }
    #endregion

    #region Unity Callback Function

    public virtual void Awake()
    {
        StateMachine = new PlayerStateMachine();

        PlayerIdleState = new PlayerIdleState(this, StateMachine, playerData, "Idle");
        PlayerMoveState = new PlayerMoveState(this, StateMachine, playerData, "Move");
        PlayerInAirState = new PlayerInAirState(this, StateMachine, playerData, "inAir");
        PlayerLandState = new PlayerLandState(this, StateMachine, playerData, "Fall_Landed");

        colliders = new List<Collider>();

    }

    public virtual void Start()
    {
        StateMachine.Initialize(PlayerIdleState);

        RB = GetComponent<Rigidbody>();
        RB.constraints = RigidbodyConstraints.FreezeRotation;
        InputHandler = GetComponent<Player_Input_Manager>();
        CharacterController = GetComponent<CharacterController>();
    }

    public virtual void Update()
    {
        horizontalInput = Input.GetAxisRaw("Horizontal");
        verticalInput = Input.GetAxisRaw("Vertical");

        StateMachine.CurrentState.LogicUpdate();
        CurrentVelocity = RB.velocity;
    }
    public virtual void FixedUpdate()
    {
        StateMachine.CurrentState.PhysicUpdate();

    }
    #endregion

    #region Set Functions
    public void SetVelocityZero()
    {
        RB.velocity = Vector3.zero;
        CurrentVelocity = Vector3.zero;
    }
    public void SetVelocity(float velocity, Vector3 direction, Vector3 moveVector)
    {
        CurrentVelocity = Vector3.SmoothDamp(CurrentVelocity, moveVector * velocity, ref workspace, 0.5f);
        CharacterController.Move(CurrentVelocity * Time.deltaTime);

        /*Ray groundCheckRay = new Ray(transform.position, Vector3.down);
        if(Physics.Raycast(groundCheckRay,2f))
        {
            CurrentForceVelocity.y = -2f;
        }*/
       /* workspace = orientation.forward * direction.x + orientation.right * direction.z;
        workspace = direction * velocity;
        RB.velocity = workspace;
        CurrentVelocity = workspace;*/
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
        return colliders.Count > 0;
        //return Physics.OverlapSphere(groundCheck.position, playerData.groundCheckRadius, playerData.whatisGround).Length > 0;
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
    #region Collision

    private void OnCollisionEnter(Collision collision)
    {
        colliders.Add(collision.collider);
    }
    private void OnCollisionExit(Collision collision)
    {
        colliders.Remove(collision.collider);
    }
    public bool CollisionManager(LayerMask layer)
    {
        for(int n = 0; n < colliders.Count;n++)
        {
            if (colliders[n].gameObject.layer == layer.value)
                return true;
        }
        return false;
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
}

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


       /* if (jumpInput && player.PlayerJumpStage_Scorpion.CanJump())
        {
            stateMachine.ChangeState(_player.PlayerJumpStage_Scorpion);
        }*/
        if (!isGrounded)
        {
            player.PlayerInAirState.StartCoyoteTime();
            stateMachine.ChangeState(player.PlayerInAirState);
        }
    }

    public override void PhysicUpdate()
    {
        base.PhysicUpdate();
    }
}
public class PlayerInAirState : PlayerState
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
        zInput = player.InputHandler.NormInputZ;

        jumpInput = player.InputHandler.JumpInput;
        jumpInputStop = player.InputHandler.JumpInputStop;
        grabInput = player.InputHandler.GrabInput;
        abilityInput = player.InputHandler.AbilityInput;

        //CheckGround_SFX();
        CheckJumpMultiplier();

        Debug.Log(isGrounded);
        Debug.Log(player.CurrentVelocity.y);

        if (isGrounded && player.CurrentVelocity.y < 0.01f)
        {
            stateMachine.ChangeState(player.PlayerLandState);
        }
        /*else if (jumpInput && player.jump.CanJump())
        {
            stateMachine.ChangeState(_player.PlayerJumpStage_Scorpion);
        }*/
        else
        {

            /*for (int i = 0; i < player.Anim.Length; i++)
            {
                _player.Anim[i].SetFloat("yVelocity", _player.CurrentVelocity.y);
                _player.Anim[i].SetFloat("xVelocity", Mathf.Abs(_player.CurrentVelocity.x));
            }*/
        }
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
public class PlayerAbilityState_Scorpion : PlayerState
{
    protected bool isAbilityDone;

    private bool isGrounded;

    public PlayerAbilityState_Scorpion(PlayerBase player, PlayerStateMachine stateMachine, PlayerData playerData, string animBoolName) : base(player, stateMachine, playerData, animBoolName)
    {
    }

    public PlayerAbilityState_Scorpion(PlayerBase player, PlayerStateMachine stateMachine, PlayerData playerData, string animBoolName, bool playAnim) : base(player, stateMachine, playerData, animBoolName, playAnim)
    {
    }

    public override void DoCheck()
    {
        base.DoCheck();

        isGrounded = player.CheckIfGrounded();
    }

    public override void Enter()
    {
        base.Enter();

        isAbilityDone = false;
    }

    public override void Exit()
    {
        base.Exit();
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();

        if (isAbilityDone)
        {
            /*if (isGrounded && player.CurrentVelocity.y < 0.01f)
            {
                stateMachine.ChangeState(_player.PlayerIdleState_Scorpion);
            }
            else
            {
                stateMachine.ChangeState(_player.PlayerInAirState_Scorpion);
            }*/
        }
    }

    public override void PhysicUpdate()
    {
        base.PhysicUpdate();
    }
}
#endregion

#region SubState

public class PlayerIdleState : Player_GroundState
{

    public PlayerIdleState(PlayerBase player, PlayerStateMachine stateMachine, PlayerData playerData, string animBoolName) : base(player, stateMachine, playerData, animBoolName)
    {
    }

    public override void DoCheck()
    {
        base.DoCheck();
    }

    public override void Enter()
    {
        base.Enter();
        //player.SetVelocity(0,Vector3.zero);
    }

    public override void Exit()
    {
        player.RB.drag = 0;
        base.Exit();
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();
        if (isGrounded && Mathf.Abs(player.RB.velocity.x) > 1f && player.CollisionManager(player.playerData.whatisGround))
            player.RB.drag = 20;
        else if (isGrounded && Mathf.Abs(player.RB.velocity.x) > 0.1f && player.CollisionManager(player.playerData.whatisGround))
            player.RB.drag = 10;
        else
            player.RB.drag = 0;

        Debug.Log("Xinput: " + xInput);
        Debug.Log("Zinput: " + zInput);

        if ((xInput != 0 || zInput != 0) && !isExitingState)
        {
            stateMachine.ChangeState(player.PlayerMoveState);
        }
    }

    public override void PhysicUpdate()
    {
        base.PhysicUpdate();
    }
}
public class PlayerMoveState : Player_GroundState
{
    public PlayerMoveState(PlayerBase player, PlayerStateMachine stateMachine, PlayerData playerData, string animBoolName) : base(player, stateMachine, playerData, animBoolName)
    {

    }

    public override void DoCheck()
    {
        base.DoCheck();
    }

    public override void Enter()
    {
        base.Enter();
    }

    public override void Exit()
    {
        base.Exit();
        player.RB.drag = 0;

    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();

        Vector3 PlayerInput = new Vector3 { x = player.InputHandler.NormInputX, y = 0f, z = player.InputHandler.NormInputZ };
        Vector3 MoveVector = player.transform.TransformDirection(PlayerInput);

        player.SetVelocity(5, PlayerInput, MoveVector);

        //player.SetVelocity(5, new Vector3(player.horizontalInput, 0, PlayerInput));


        RaycastHit2D rayGround = Physics2D.Raycast(player.transform.position, Vector2.down, 1, player.playerData.whatisGround);

        if (rayGround)
        {
            float angle = Vector2.Angle(rayGround.normal, Vector2.up);
            if (isGrounded && Mathf.Abs(player.RB.velocity.x) > 0.1f && player.CollisionManager(player.playerData.whatisGround) && angle != 0)
                player.RB.drag = 5;
            else
                player.RB.drag = 0;
        }
        else
            player.RB.drag = 0;

        if (xInput == 0f && !isExitingState)
        {
            stateMachine.ChangeState(player.PlayerIdleState);
        }
    }

    public override void PhysicUpdate()
    {
        base.PhysicUpdate();
    }
}

public class PlayerLandState : Player_GroundState
{
    public PlayerLandState(PlayerBase player, PlayerStateMachine stateMachine, PlayerData playerData, string animBoolName) : base(player, stateMachine, playerData, animBoolName) { }

    public override void Enter()
    {
        base.Enter();
    }

    public override void Exit()
    {
        base.Exit();
        player.RB.drag = 0;
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();

        if (!isExitingState)
        {
            if (isGrounded && Mathf.Abs(player.RB.velocity.x) > 1f && player.CollisionManager(player.playerData.whatisGround))
                player.RB.drag = 20;
            else if (isGrounded && Mathf.Abs(player.RB.velocity.x) > 0.1f && player.CollisionManager(player.playerData.whatisGround))
                player.RB.drag = 10;
            else
                player.RB.drag = 0;

            if (xInput != 0)
            {
                stateMachine.ChangeState(player.PlayerMoveState);
            }
            else if (isAnimationFinished)
            {
                stateMachine.ChangeState(player.PlayerIdleState);
            }
        }
    }
}
#endregion
