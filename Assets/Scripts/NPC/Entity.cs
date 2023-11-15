using Pathfinding;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Events;

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
    public bool isActive = true;
    public bool isReturning = false;

    [Header("GENERAL SETUP")]
    public Rigidbody rb;
    public Animator anim;
    [HideInInspector]
    public CharacterController characterController;
    public Transform rayCenter;
    [SerializeField]
    WeaponManager[] weaponManagers;

    [Header("DETECTION")]
    [ReadOnly]
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

    public UnityAction DetectionTrigger;

    #region Check Transforms
    [SerializeField]
    private Transform groundCheck;
    [SerializeField]
    private Transform wallCheck;
    #endregion
    protected UnityAction TriggerDetected { get; set; }

    #region Health
    protected float max_Health;
    [SerializeField]
    protected float current_Health;
    [HideInInspector]
    public bool CheckPoint;
    public SpawnDecal SpawnDecal;
    [ReadOnly]
    public bool beingStun;
    #endregion

    public AudioManager AudioManager;
    public MovementManager MovementManager;

    public virtual void Initialization()
    {
        DetectionTimer = entityData.detectionTimer;
        RadiusDetection = entityData.radiusDetection;
        RadiusAfterDetection = entityData.radiusAfterDetection;

        current_Health = max_Health = entityData.healthCount;
    }

    public virtual void Awake()
    {
        stateMachine = new FiniteStateMachine();
        seeker = GetComponent<Seeker>();
        characterController = GetComponent<CharacterController>();
        MovementManager = GetComponent<MovementManager>();
        Initialization();
    }


    public virtual void Start()
    {
        TriggerDetected += TriggerDetection;
    }

    public virtual void Update()
    {
        if(isActive)
            ResetFindTarget();
        //ResetFindTarget();
        /* DetectionReset();
         Detection();*/
        stateMachine.CurrentState.LogicUpdate();
    }

    public virtual void FixedUpdate()
    {
        if(isActive)
        {
            DetectionReset();
            Detection();
        }
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
        else
            Debug.Log("Error");
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
        for (int n = 0; n < weaponManagers.Length; n++)
        {
            weaponManagers[n].damaged_Object.Clear();
            weaponManagers[n].PierceController();
        }
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

    public float AngleDir(Vector3 fwd, Vector3 targetDir, Vector3 up)
    {
        Vector3 perp = Vector3.Cross(fwd, targetDir);
        float dir = Vector3.Dot(perp, up);

        if (dir > 0f)
        {
            return 1f;
        }
        else if (dir < 0f)
        {
            return -1f;
        }
        else
        {
            return 0f;
        }
    }

    #endregion

    #region Detection Functions
    public virtual void FieldOfViewCheck()
    {
        Collider[] rangeChecks = Physics.OverlapSphere(rayCenter.position, RadiusDetection, entityData.armor);


        if (rangeChecks.Length != 0)
        {
            for (int i = 0; i < rangeChecks.Length; i++)
            {
                Transform target = rangeChecks[i].transform;
                Vector3 directionToTarget = (target.position - rayCenter.position).normalized;

                if (Vector3.Angle(rayCenter.forward, directionToTarget) < entityData.angleDetection / 2)
                {
                    float distanceToTarget = Vector3.Distance(rayCenter.position, target.position);
                    if (!Physics.Raycast(rayCenter.position, directionToTarget, distanceToTarget, entityData.block) && target.CompareTag("Player"))
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
            DetectionCheck = false;
            return;
        }

        Vector3 dir = (enemy.transform.position - rayCenter.position).normalized;


        RaycastHit[] hitInfo = Physics.RaycastAll(rayCenter.position, dir, RadiusAfterDetection, entityData.armor);

        if (hitInfo.Length > 0)
        {
            resetFindTargetEnable = false;
            TargetFindTimerReset = 2;
            for (int i = 0; i < hitInfo.Length; i++)
            {
                RaycastHit hit = hitInfo[i];
                GameObject a = hit.transform.gameObject;

                Debug.DrawLine(rayCenter.position, hit.point, Color.green);

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
            Debug.DrawRay(rayCenter.position, dir * RadiusAfterDetection, Color.red);
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

    public bool StunLogic(float damage)
    {
        float chance = 0;

        if(damage > current_Health)
            chance = (1 - entityData.stunRes) * 100;
        else
            chance = (Mathf.Abs(damage / current_Health) - entityData.stunRes) * 100;


        if(chance < 0)
            return false;

        if (ProbabilityCheck(chance))
            return true;
        return false;
    }
    #endregion

    #region Audio
    public virtual void Audio(string sound)
    {

    }

    public virtual void DestroyObject()
    {
        Destroy(gameObject);
    }
    #endregion


}
