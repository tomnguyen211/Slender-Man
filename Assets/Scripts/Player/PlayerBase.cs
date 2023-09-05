using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerBase : Entity
{

    #region State Variables
    public PlayerStateMachine StateMachine { get; private set; }
    [SerializeField]
    public PlayerData playerData;
    #endregion

    #region Components
    public Animator[] Anim;
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
    #endregion

    #region Unity Callback Function

    public virtual void Awake()
    {
        StateMachine = new PlayerStateMachine();
    }

    public virtual void Start()
    {
        RB = GetComponent<Rigidbody>();
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
}
