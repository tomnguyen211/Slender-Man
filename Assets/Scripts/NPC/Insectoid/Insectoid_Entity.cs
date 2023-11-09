using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Insectoid_Entity : Entity, IDamage, IDetect
{
    public Insectoid_Idle Insectoid_Idle { get;private set; }
    public Insectoid_Move Insectoid_Move { get; private set; }
    public Insectoid_Patrol Insectoid_Patrol { get; private set; }
    public Insectoid_Attack Insectoid_Attack { get; private set; }
    public Insectoid_Dead Insectoid_Dead { get; private set; }  
    public Insectoid_Damage Insectoid_Damage {get; private set; }

    public D_IdleState D_IdleState;
    public D_MoveState D_MoveState;
    public D_AttackState D_AttackState;
    public D_DeadState D_DeadState;
    public D_PatrolState D_PatrolState;

    public bool disablePatrol;

    public bool customPatrolEnable;
    public Transform[] patrolPoint;

    public bool customPatrolEnableRadius;
    public Transform patrolPointRadius;
    public float radiusPatrol;

    public override void Awake()
    {
        base.Awake();

        Insectoid_Idle = new Insectoid_Idle(this, stateMachine, "Idle", D_IdleState, this);
        Insectoid_Move = new Insectoid_Move(this, stateMachine, "Chase", D_MoveState, this);
        Insectoid_Patrol = new Insectoid_Patrol(this, stateMachine, "Move", D_PatrolState, this);
        Insectoid_Attack = new Insectoid_Attack(this, stateMachine, "Attack", D_AttackState, this);
        Insectoid_Dead = new Insectoid_Dead(this, stateMachine, "Dead", false, D_DeadState, this); ;
        Insectoid_Damage = new Insectoid_Damage(this, stateMachine, "Damage", false, this);

        stateMachine.Initialize(Insectoid_Idle);
    }
    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.collider.CompareTag("Player"))
            Debug.Log("HITTTT");
    }

    public override void Start()
    {
        base.Start();
        seeker.pathCallback += OnPathComplete;
    }

    private void OnDisable()
    {
        seeker.pathCallback -= OnPathComplete;
    }

    public override void Update()
    {
        base.Update();
    }

    public override void FixedUpdate()
    {
        base.FixedUpdate();
    }

    public override void MainHealthSet(float amount)
    {
        base.MainHealthSet(amount);
        if (!DetectionCheck)
        {
            DetectionCheck = true;
            DetectionTimer = entityData.detectionTimer;
            stateMachine.ChangeState(Insectoid_Damage);
            TriggerDetection();
        }

        current_Health -= amount;
        if (current_Health <= 0 && !CheckPoint)
        {
            CheckPoint = true;
            stateMachine.ChangeState(Insectoid_Dead);
            characterController.enabled = false;
            rb.useGravity = true;
            //AdjustAllLayer("Dead");
            //AdjustAllTag("Dead");
            CancelInvoke();
            StopAllCoroutines();
        }
    }

    public void UpdatePath_Des(Vector3 des)
    {

        if (des == null)
            CancelInvoke(nameof(UpdatePath_Des));
        else if (seeker.IsDone())
        {
            seeker.StartPath(transform.position, des, OnPathComplete);
        }
    }
    public void Move(float speed, out Vector3 dir)
    {
        if (path == null)
        {
            // We have no path to follow yet, so don't do anything
            dir = Vector3.zero;
            return;
        }

        // Check in a loop if we are close enough to the current waypoint to switch to the next one.
        // We do this in a loop because many waypoints might be close to each other and we may reach
        // several of them in the same frame.
        reachedEndOfPath = false;
        // The distance to the next waypoint in the path
        float distanceToWaypoint;
        while (true)
        {
            // If you want maximum performance you can check the squared distance instead to get rid of a
            // square root calculation. But that is outside the scope of this tutorial.
            distanceToWaypoint = Vector3.Distance(transform.position, path.vectorPath[currentWaypoint]);
            if (distanceToWaypoint < nextWaypointDistance)
            {
                // Check if there is another waypoint or if we have reached the end of the path
                if (currentWaypoint + 1 < path.vectorPath.Count)
                {
                    currentWaypoint++;
                }
                else
                {
                    // Set a status variable to indicate that the agent has reached the end of the path.
                    // You can use this to trigger some special code if your game requires that.
                    reachedEndOfPath = true;
                    Debug.Log("ReachEnd");
                    break;
                }
            }
            else
            {
                break;
            }
        }

        // Slow down smoothly upon approaching the end of the path
        // This value will smoothly go from 1 to 0 as the agent approaches the last waypoint in the path.
        var speedFactor = reachedEndOfPath ? Mathf.Sqrt(distanceToWaypoint / nextWaypointDistance) : 1f;

        // Direction to the next waypoint
        // Normalize it so that it has a length of 1 world unit
        dir = (path.vectorPath[currentWaypoint] - transform.position).normalized;
        // Multiply the direction by our desired speed to get a velocity
        Vector3 velocity = speed * speedFactor * dir;

        Quaternion rot = Quaternion.LookRotation(dir, Vector3.up);

        /* float newRotX = Mathf.Clamp(rot.x,)*/

        float angle = 0;

        if (enemy != null)
        {
            Vector3 enemyDir = enemy.transform.position - transform.position;
            angle = Vector3.Angle(enemyDir, transform.forward);

            float leftRight = AngleDir(transform.forward, enemyDir, transform.up);

            if (leftRight == 1)
                anim.SetFloat("xDir", angle);
            else if (leftRight == -1)
                anim.SetFloat("xDir", -angle);
            else
                anim.SetFloat("xDir", 0);

        }

        angle = Mathf.Abs(angle);
        if (angle > 90)
            transform.rotation = Quaternion.RotateTowards(transform.rotation, rot, 300 * Time.deltaTime);
        else
            transform.rotation = Quaternion.RotateTowards(transform.rotation, rot, 150 * Time.deltaTime);

        /* if(transform.eulerAngles.x > 25)
         {
             transform.eulerAngles = new Vector3(24,transform.eulerAngles.y, transform.eulerAngles.z);
         }

         if (transform.eulerAngles.x < -25)
         {
             transform.eulerAngles = new Vector3(-24, transform.eulerAngles.y, transform.eulerAngles.z);
         }

         if (transform.eulerAngles.z < -15)
         {
             transform.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y, -14);
         }

         if (transform.eulerAngles.z > 15)
         {
             transform.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y, 14);
         }*/

        characterController.SimpleMove(velocity);
    }

    public override void TriggerDetection()
    {
        base.TriggerDetection();
        stateMachine.ChangeState(Insectoid_Idle);
        Insectoid_Idle.isIdleTimeOver = true;
    }

    public void Damage(float damage, RaycastHit ray, GameObject attacker)
    {
        if (enemy == null)
            enemy = attacker;
        MainHealthSet(damage);
        SpawnDecal.SpawnDecals(ray);
    }

    public void EnableDetect()
    {
        isReturning = false;
        isActive = true;
    }
    public void DisableDetect()
    {
        DetectionCheck = false;
        CanSeePlayer = false;
        Insectoid_Idle.PresetIdle();
        stateMachine.ChangeState(Insectoid_Idle);
        if (!disablePatrol)
            isReturning = true;
        enemy = null;

    }

}
public class Insectoid_Idle : IdleState
{
    Insectoid_Entity character;
    public Insectoid_Idle(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_IdleState stateData, Insectoid_Entity character) : base(entity, stateMachine, animBoolName, stateData)
    {
        this.character = character;
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
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();

        if (!isExitingState && isIdleTimeOver /*&& character.CheckIfGrounded*/)
        {
            if (character.DetectionCheck)
            {
                if (character.CanSeePlayer)
                {

                    if (character.Insectoid_Attack.CheckIfDistance() && character.Insectoid_Attack.CheckIfCanUseAbility())
                    {
                        Debug.Log(Vector3.Distance(character.rayCenter.position, character.enemy.transform.position));
                        stateMachine.ChangeState(character.Insectoid_Attack);
                    }
                    else if (character.Insectoid_Move.CheckIfCanMove())
                    {
                        Debug.Log(Vector3.Distance(character.transform.position, character.enemy.transform.position));
                        stateMachine.ChangeState(character.Insectoid_Move);
                    }
                }
                else
                {
                    return;
                }
            }
            else if (!character.disablePatrol && character.isActive)
            {
                stateMachine.ChangeState(character.Insectoid_Patrol);
            }
            else
            {
                isIdleTimeOver = false;
                SetRandomIdleTime();
            }
        }
    }

    public void PresetIdle()
    {
        if (character.DetectionCheck)
            character.anim.SetInteger("Type", 2);
        else
        {
            character.anim.SetInteger("Type", 1);
        }
    }
}

public class Insectoid_Move : MoveState
{
    Insectoid_Entity character;
    private Vector3 direction;
    int moveType;
    public Insectoid_Move(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_MoveState stateData, Insectoid_Entity character) : base(entity, stateMachine, animBoolName, stateData)
    {
        this.character = character;
    }

    public override void Enter()
    {
        base.Enter();
        character.UpdatePath_Enemy();

    }

    public override void Exit()
    {
        base.Exit();
        Quaternion rot = Quaternion.LookRotation(direction, Vector3.up);
        Debug.Log("X: " + rot.x + " Y: " + rot.y + " Z: " + rot.z);
        character.transform.rotation = Quaternion.LookRotation(direction);
        character.transform.eulerAngles = new Vector3(0, character.transform.eulerAngles.y, 0);
        character.seeker.CancelCurrentPathRequest();
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();
        if (!isExitingState)
        {
            if (isMoveReset)
            {
                character.UpdatePath_Enemy();
                isMoveReset = false;
                startTime = Time.time;
            }
            if (moveType == 1)
                character.Move(stateData.movingSpeed * 0.5f, out direction);
            else
                character.Move(stateData.movingSpeed, out direction);

            if (!character.CanSeePlayer)
            {
                character.Insectoid_Idle.PresetIdle();
                stateMachine.ChangeState(character.Insectoid_Idle);
            }
            else if (character.Insectoid_Attack.CheckIfDistance() && character.Insectoid_Attack.CheckIfCanUseAbility())
            {
                stateMachine.ChangeState(character.Insectoid_Attack);
            }
            else if (character.IsBetween(Vector3.Distance(character.transform.position, character.enemy.transform.position), stateData.move_Thresholds[0].thresholdMin, stateData.move_Thresholds[0].thresholdMax))
            {
                character.Insectoid_Idle.PresetIdle();
                stateMachine.ChangeState(character.Insectoid_Idle);
            }
        }
    }

    public void PresetMove()
    {
        if (!character.DetectionCheck)
        {
            character.anim.SetInteger("Type", 1);

        }
        else
        {
            if (Vector3.Distance(character.rayCenter.position, character.enemy.transform.position) >= 6f)
                character.anim.SetInteger("Type", 2);
            else
                character.anim.SetInteger("Type", 1);


        }
    }

    public void PresetMove(int type)
    {

        switch (type)
        {
            case 1:
                character.anim.SetInteger("Type", 1);
                break;
            case 2:
                character.anim.SetInteger("Type", 2);
                break;
        }

        moveType = type;
    }
    public bool CheckIfCanMove()
    {
        return !character.IsBetween(Vector3.Distance(character.rayCenter.position, character.enemy.transform.position), stateData.move_Thresholds[0].thresholdMin, stateData.move_Thresholds[0].thresholdMax);
    }
}

public class Insectoid_Patrol : PatrolState
{
    Insectoid_Entity character;
    Vector3 direction;
    public Insectoid_Patrol(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_PatrolState stateData, Insectoid_Entity character) : base(entity, stateMachine, animBoolName, stateData)
    {
        this.character = character;
    }

    public override void Enter()
    {
        base.Enter();
        if (character.customPatrolEnable)
        {
            if (!character.CheckIfGround() || character.CheckIfTouchingWall() || !character.CheckIfTouchingLedge())
            {
                patrolNewDestination = character.patrolPoint[Random.Range(0, character.patrolPoint.Length)].position;
                character.UpdatePath_Des(patrolNewDestination);
            }
            else
            {
                character.Insectoid_Idle.PresetIdle();
                stateMachine.ChangeState(character.Insectoid_Idle);

            }
        }
        else if (character.customPatrolEnableRadius)
        {
            if (!character.CheckIfGround() || character.CheckIfTouchingWall() || !character.CheckIfTouchingLedge())
            {
                patrolNewDestination = new Vector3(character.patrolPointRadius.position.x + Random.Range(Random.Range(0, character.radiusPatrol), Random.Range(0, -character.radiusPatrol)), character.patrolPointRadius.position.y, character.patrolPointRadius.position.z + Random.Range(Random.Range(0, character.radiusPatrol), Random.Range(0, -character.radiusPatrol)));
                character.UpdatePath_Des(patrolNewDestination);
            }
            else
            {
                character.Insectoid_Idle.PresetIdle();
                stateMachine.ChangeState(character.Insectoid_Idle);

            }
        }
        else
        {
            if (!character.CheckIfGround() || character.CheckIfTouchingWall() || !character.CheckIfTouchingLedge())
            {
                patrolNewDestination = new Vector3(character.transform.position.x + Random.Range(Random.Range(5, 25), Random.Range(-5, -25)), character.transform.position.y, character.transform.position.z + Random.Range(Random.Range(5, 25), Random.Range(-5, -25)));
                character.UpdatePath_Des(patrolNewDestination);
            }
            else
            {
                character.Insectoid_Idle.PresetIdle();
                stateMachine.ChangeState(character.Insectoid_Idle);

            }
        }
    }

    public override void Exit()
    {
        base.Exit();
        Quaternion rot = Quaternion.LookRotation(direction, Vector3.up);
        Debug.Log("X: " + rot.x + " Y: " + rot.y + " Z: " + rot.z);
        character.transform.rotation = Quaternion.LookRotation(direction);
        character.transform.eulerAngles = new Vector3(0, character.transform.eulerAngles.y, 0);
        character.seeker.CancelCurrentPathRequest();
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();
        character.Move(character.D_MoveState.movingSpeed * character.D_PatrolState.patrolSpeedModifier, out direction);
        if (Vector2.Distance(character.transform.position, patrolNewDestination) <= 1f || character.reachedEndOfPath)
        {
            character.Insectoid_Idle.PresetIdle();
            stateMachine.ChangeState(character.Insectoid_Idle);
        }
    }
}
public class Insectoid_Attack : AttackState
{
    Insectoid_Entity character;
    public Insectoid_Attack(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_AttackState stateData, Insectoid_Entity character) : base(entity, stateMachine, animBoolName, stateData)
    {
        this.character = character;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
        character.Insectoid_Idle.PresetIdle();
        stateMachine.ChangeState(character.Insectoid_Idle);
    }
}
public class Insectoid_Dead : DeadState
{
    Insectoid_Entity character;

    public Insectoid_Dead(Entity entity, FiniteStateMachine stateMachine, string animBoolName, bool playAnim, D_DeadState stateData, Insectoid_Entity character) : base(entity, stateMachine, animBoolName, playAnim, stateData)
    {
        this.character = character;
    }

    public override void Enter()
    {
        base.Enter();
        character.anim.SetTrigger(animBoolName);
        deadTime = stateData.deadTime;
        character.seeker.CancelCurrentPathRequest();
    }

    public override void Exit()
    {
        base.Exit();
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();
        if (deadTime <= 0)
            character.DestroyObject();
        else
            deadTime -= Time.deltaTime;
    }
}
public class Insectoid_Damage : AI_State
{
    Insectoid_Entity character;

    public Insectoid_Damage(Entity entity, FiniteStateMachine stateMachine, string animBoolName, bool playAnim, Insectoid_Entity character) : base(entity, stateMachine, animBoolName, playAnim)
    {
        this.character = character;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
        character.Insectoid_Idle.PresetIdle();
        stateMachine.ChangeState(character.Insectoid_Idle);
    }

    public override void Enter()
    {
        base.Enter();
        character.anim.SetTrigger(animBoolName);
        character.seeker.CancelCurrentPathRequest();
        character.beingStun = true;
    }

    public override void Exit()
    {
        base.Exit();
        character.beingStun = false;
    }
}
