using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.Antlr3.Runtime.Misc;
using UnityEngine;
using UnityEngine.Events;

public class Entity : MonoBehaviour
{
    public PlayerStateMachine stateMachine;
    public D_Entity entityData;

    [Header("GENERAL SETUP")]
    public Rigidbody rb;
    public Animator anim;
    public CharacterController characterController;

    [Header("DETECTION")]
    public bool CanSeePlayer;
    protected float TargetFindTimerReset = 10;
    public bool DetectionCheck;
    public float DetectionTimer { get; set; }
    public float RadiusDetection;
    public float RadiusAfterDetection;
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
        stateMachine = new PlayerStateMachine();

        Initialization();
    }


    public virtual void Start()
    {
        TriggerDetected += TriggerDetection;
    }

    public virtual void Update()
    {
        ResetFindTarget();
        DetectionReset();
        Detection(); ;


        stateMachine.CurrentState.LogicUpdate();
    }

    public virtual void FixedUpdate()
    {
        stateMachine.CurrentState.PhysicUpdate();
    }


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
        return Physics2D.OverlapCircle(groundCheck.position, entityData.groundCheckRadius, entityData.whatIsGround);
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
        /*Collider2D[] rangeChecks = Physics2D.OverlapCircleAll(transform.position, RadiusDetection, entityData.armor | entityData.protection);

        if (rangeChecks.Length != 0)
        {
            for (int i = 0; i < rangeChecks.Length; i++)
            {
                Transform target = rangeChecks[i].transform;
                Vector3 directionToTarget = (target.position - rayCenter.transform.position).normalized;
                if (Vector3.Angle(rayCenter.transform.right, directionToTarget) < entityData.angleDetection / 2)
                {
                    float distanceToTarget = Vector3.Distance(rayCenter.transform.position, target.position);

                    if (!Physics2D.Raycast(rayCenter.transform.position, directionToTarget, distanceToTarget, entityData.whatIsGround))
                    {

                        for (int n = 0; n < enemyList.Count; n++)
                        {

                            if (target.CompareTag((string)enemyList[n]))
                            {
                                NoTargetFound = false;
                                CanSeePlayer = true;
                                DetectionCheck = true;
                                DetectionTimer = entityData.detectionTimer;
                                if (enemy == null)
                                {
                                    if (((1 << target.gameObject.layer) & entityData.armor) != 0)
                                        enemy = target.GetComponent<Armor_Manager>().parentObject;
                                    else
                                        enemy = target.GetComponent<Protection_Manager>().parentObject;
                                }
                                enemy_pools.Add(enemy);
                                InvokeRepeating(nameof(FieldOfViewDetect), 1, 1);
                                TriggerDetected.Invoke();

                                return;
                            }
                        }
                    }
                }
            }
        }*/
    }
    public virtual void FieldOfViewDetect()
    {
       /* List<GameObject> temp_pools = new List<GameObject>();

        // STAGE 1 : CHECK AND DELETE //
        for (int m = 0; m < enemy_pools.Count; m++)
        {
            if (enemy_pools[m].Equals(null))
            {
                enemy_pools.RemoveAt(m);
            }
            else if (!enemyList.Contains(enemy_pools[m].tag))
            {
                enemy_pools.RemoveAt(m);
            }
            else if (enemy_pools[m].CompareTag("Dead"))
            {
                enemy_pools.RemoveAt(m);
            }
            else
            {
                temp_pools.Add(enemy_pools[m]);
            }
        }

        // STAGE 2 : SEARCH FOR ENEMIES // 
        Collider2D[] rangeChecks = Physics2D.OverlapCircleAll(rayCenter.transform.position, RadiusAfterDetection, entityData.armor | entityData.protection);
        if (rangeChecks.Length != 0)
        {
            for (int i = 0; i < rangeChecks.Length; i++)
            {
                Transform target = rangeChecks[i].transform;
                Vector3 directionToTarget = (target.position - rayCenter.transform.position).normalized;
                if (Vector3.Angle(rayCenter.transform.right, directionToTarget) < 180)
                {
                    float distanceToTarget = Vector3.Distance(rayCenter.transform.position, target.position);

                    if (!Physics2D.Raycast(rayCenter.transform.position, directionToTarget, distanceToTarget, entityData.whatIsGround))
                    {
                        for (int n = 0; n < enemyList.Count; n++) // Check Tag
                        {
                            if (target.CompareTag((string)enemyList[n]))
                            {
                                if (((1 << target.gameObject.layer) & entityData.armor) != 0)
                                {
                                    if (!enemy_pools.Contains(target.GetComponent<Armor_Manager>().parentObject) && target.gameObject.layer != LayerMask.NameToLayer("Invisible"))
                                    {
                                        enemy_pools.Add(target.GetComponent<Armor_Manager>().parentObject);
                                        CanSeePlayer = true;
                                        break;
                                    }
                                    else
                                    {
                                        temp_pools.Remove(target.GetComponent<Armor_Manager>().parentObject);
                                        break;
                                    }
                                }
                                else
                                {
                                    if (!enemy_pools.Contains(target.GetComponent<Protection_Manager>().parentObject) && target.gameObject.layer != LayerMask.NameToLayer("Invisible"))
                                    {
                                        enemy_pools.Add(target.GetComponent<Protection_Manager>().parentObject);
                                        CanSeePlayer = true;
                                        break;
                                    }
                                    else
                                    {
                                        temp_pools.Remove(target.GetComponent<Protection_Manager>().parentObject);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        for (int n = 0; n < enemyList.Count; n++) // Check Tag
                        {
                            if (target.CompareTag((string)enemyList[n]))
                            {

                                if (((1 << target.gameObject.layer) & entityData.armor) != 0)
                                {
                                    if (enemy_pools.Contains(target.GetComponent<Armor_Manager>().parentObject))
                                    {
                                        temp_pools.Remove(target.GetComponent<Armor_Manager>().parentObject);
                                        break;
                                    }
                                }
                                else
                                {
                                    if (enemy_pools.Contains(target.GetComponent<Protection_Manager>().parentObject))
                                    {
                                        temp_pools.Remove(target.GetComponent<Protection_Manager>().parentObject);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        // STAGE 3 : REMOVE ENEMY THAT NO LONGER FOUND EXCEPT CURRENT ENEMY // 
        for (int n = 0; n < temp_pools.Count; n++)
        {
            for (int i = 0; i < enemy_pools.Count; i++)
            {
                if (temp_pools[n] == enemy_pools[i])
                {
                    enemy_pools.RemoveAt(i);
                    break;
                }
            }
        }


        // STAGE 4: ACTIVATE IF ENEMY IS NULL
        if (enemy_pools.Count > 0 && NoTargetFound)
        {
            enemy = FindClosestEnemy();
        }*/
    }
   
    public virtual void CheckAimDirection()
    {
        /*if (enemy == null)
        {
            CanSeePlayer = false;
            return;
        }

        Vector2 dir = (enemy.transform.position - rayCenter.transform.position).normalized;
        RaycastHit2D[] hitInfo = Physics2D.RaycastAll(rayCenter.transform.position, dir, RadiusAfterDetection, entityData.armor | entityData.protection);
        if (hitInfo.Length >= 1)
        {
            for (int i = 0; i < hitInfo.Length; i++)
            {
                RaycastHit2D hit = hitInfo[i];
                //GameObject a = hit.transform.GetComponent<RootObject>().parentObject;
                GameObject a = hit.transform.gameObject;
                Debug.DrawLine(rayCenter.transform.position, hit.point, Color.red);

                if (a.layer != LayerMask.NameToLayer("Invisible"))
                {
                    for (int n = 0; n < enemyList.Count; n++)
                    {
                        if (a.CompareTag((string)enemyList[n]))
                        {
                            CanSeePlayer = true;
                            return;
                        }
                    }
                }
                else
                    CanSeePlayer = false;

                if (i == hitInfo.Length - 1)
                {
                    CanSeePlayer = false;
                    return;
                }
            }
        }
        else
        {
            CanSeePlayer = false;
        }*/
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

                CancelInvoke(nameof(FieldOfViewDetect));
            }
            else
                DetectionTimer -= Time.deltaTime;
        }
    }

    public virtual void ResetFindTarget()
    {
        if (DetectionCheck)
        {
            if (TargetFindTimerReset <= 0)
            {
                TargetFindTimerReset = 10;
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
