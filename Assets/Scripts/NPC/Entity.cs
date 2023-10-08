using Pathfinding;
using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using Unity.VisualScripting.Antlr3.Runtime.Misc;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem.XR;

public class Entity : MonoBehaviour
{
    public FiniteStateMachine stateMachine;
    public D_Entity entityData;

    [HideInInspector]
    public Seeker seeker;
    [HideInInspector]
    public Path path;
    public float nextWaypointDistance = 3;
    protected int currentWaypoint = 0;
    [ReadOnly]
    public bool reachedEndOfPath;

    [Header("GENERAL SETUP")]
    public Rigidbody rb;
    public Animator anim;
    [HideInInspector]
    public CharacterController characterController;

    [Header("DETECTION")]
    [HideInInspector]
    public GameObject enemy;
    [ReadOnly]
    public bool CanSeePlayer;
    protected float TargetFindTimerReset = 2;
    private bool resetFindTargetEnable;
    [ReadOnly]
    public bool DetectionCheck;
    public float DetectionTimer { get; set; }
    [HideInInspector]
    public float RadiusDetection;
    [HideInInspector]
    public float RadiusAfterDetection;
    [ReadOnly]
    public bool NoTargetFound;

    #region Check Transforms
    [SerializeField]
    private Transform groundCheck;
    [SerializeField]
    private Transform wallCheck;
    #endregion
    protected UnityAction TriggerDetected { get; set; }

    public virtual void Initialization()
    {
        DetectionTimer = entityData.detectionTimer;
        RadiusDetection = entityData.radiusDetection;
        RadiusAfterDetection = entityData.radiusAfterDetection;
    }

    public virtual void Awake()
    {
        stateMachine = new FiniteStateMachine();

        Initialization();
    }


    public virtual void Start()
    {
        TriggerDetected += TriggerDetection;
        seeker = GetComponent<Seeker>();
        characterController = GetComponent<CharacterController>();
    }

    public virtual void Update()
    {
        ResetFindTarget();
        //ResetFindTarget();
        /* DetectionReset();
         Detection();*/
        stateMachine.CurrentState.LogicUpdate();
    }

    public virtual void FixedUpdate()
    {
        DetectionReset();
        Detection();
        stateMachine.CurrentState.PhysicUpdate();
    }

    #region Pathfinding
    public void UpdatePath_Enemy()
    {
        if (enemy == null)
            CancelInvoke(nameof(UpdatePath_Enemy));
        else if (seeker.IsDone())
        {
            seeker.StartPath(transform.position, enemy.transform.position, OnPathComplete);
        }
    }
    public void OnPathComplete(Path p)
    {
        if (!p.error)
        {
            path = p;
            currentWaypoint = 0;
        }
    }
    #endregion


    #region Set Functions

    public void SetVelocity(float velocity, Vector2 direction)
    {
        /*workspace = direction * velocity;
        rb.velocity = workspace;
        CurrentVelocity = workspace;*/
    }
   
    #endregion

    #region Check Functions

    public bool CheckIfGround()
    {
        return Physics.Raycast(groundCheck.position,Vector3.down ,entityData.groundCheckDistance, entityData.whatIsGround);
    }

    public bool CheckIfTouchingWall()
    {
        return Physics.Raycast(groundCheck.position, transform.forward, entityData.wallCheckDistance, entityData.whatIsGround);
    }

    public bool CheckIfTouchingLedge()
    {
        return !Physics.Raycast(groundCheck.position, Vector3.down, entityData.groundCheckDistance, entityData.whatIsGround);

    }

    #endregion


    public bool CheckIfTouchCharacer
    {
        get => Physics2D.Raycast(wallCheck.position, Vector3.forward, entityData.characterCheckDistance, entityData.character);
    }


    #region Events Trigger
    // EVENTS //
    public virtual void Reset_Weapon_Atk()
    {
        /*for (int n = 0; n < weapon_manager.Length; n++)
        {
            weapon_manager[n].damaged_Object.Clear();
            weapon_manager[n].PierceController();
        }*/
    }
    
    #endregion


    #region Animation Trigger

    public void SoundTrigger(string s) => Audio(s);

    public void AnimationTrigger() => stateMachine.CurrentState.AnimationTrigger();

    public void AnimationFinishTrigger() => stateMachine.CurrentState.AnimationFinishTrigger();

    #endregion

    #region Other Functions
    /** RESET */

    /** MISC */
    public virtual void AdjustAllTag(string tagName)
    {
        transform.tag = "Dead";
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
   
    public virtual void DestroyObject(GameObject obj)
    {
        Destroy(obj);
    }
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

    #endregion

    #region Detection Functions
    public virtual void FieldOfViewCheck()
    {
        Collider[] rangeChecks = Physics.OverlapSphere(transform.position, RadiusDetection, entityData.character);


        if (rangeChecks.Length != 0)
        {
            for (int i = 0; i < rangeChecks.Length; i++)
            {
                Transform target = rangeChecks[i].transform;
                Vector3 directionToTarget = (target.position - transform.position).normalized;

                if (Vector3.Angle(transform.forward, directionToTarget) < entityData.angleDetection / 2)
                {
                    float distanceToTarget = Vector3.Distance(transform.position, target.position);
                    if (!Physics.Raycast(transform.position, directionToTarget, distanceToTarget, entityData.whatIsGround) && target.CompareTag("Player"))
                    {
                        NoTargetFound = false;
                        CanSeePlayer = true;
                        DetectionCheck = true;
                        DetectionTimer = entityData.detectionTimer;
                        enemy = target.gameObject;
                        TriggerDetected.Invoke();
                    }
                }
            }
        }
    }
  
   
    public virtual void CheckAimDirection()
    {
        if (enemy == null)
        {
            CanSeePlayer = false;
            return;
        }

        Vector3 dir = (enemy.transform.position - transform.position).normalized;

        RaycastHit[] hitInfo = Physics.RaycastAll(transform.position, dir, RadiusAfterDetection, entityData.character);

        if (hitInfo.Length > 0)
        {
            resetFindTargetEnable = false;
            TargetFindTimerReset = 2;
            for (int i = 0; i < hitInfo.Length; i++)
            {
                RaycastHit hit = hitInfo[i];
                GameObject a = hit.transform.gameObject;

                Debug.DrawLine(transform.position, hit.point, Color.red);

                if (a.CompareTag("Player"))
                {
                    CanSeePlayer = true;
                    return;
                }

                if (i == hitInfo.Length - 1)
                {
                    CanSeePlayer = false;
                    return;
                }
            }
        }
        else
        {
            resetFindTargetEnable = true;
        }
    }

    public virtual void Detection()
    {
        if (DetectionCheck)
            CheckAimDirection();
        else if (!DetectionCheck)
            FieldOfViewCheck();
    }



    public virtual void TriggerDetection() { }
    #endregion

    #region Timer


    public virtual void DetectionReset()
    {
        if (DetectionCheck && !CanSeePlayer)
        {
            if (DetectionTimer <= 0)
            {
                DetectionCheck = false;
                DetectionTimer = entityData.detectionTimer;
            }
            else
                DetectionTimer -= Time.deltaTime;
        }
    }

    public virtual void ResetFindTarget()
    {
        if (resetFindTargetEnable)
        {
            if (TargetFindTimerReset <= 0)
            {
                Debug.Log("Here");
                TargetFindTimerReset = 2;
                CanSeePlayer = false;
                resetFindTargetEnable = false;
            }
            else
                TargetFindTimerReset -= Time.deltaTime;
        }
    }

    #endregion

    #region Health

    //public float Get_Health() => healthCount;

    public virtual void MainHealthSet(float amount)
    {
       
    }   
    #endregion

    #region Audio
    public virtual void Audio(string sound)
    {

    }
    #endregion
}
