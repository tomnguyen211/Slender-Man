using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Vendigo_Entity : Entity, IDamage, IDetect
{
   public Vendigo_Entity_Idle Vendigo_Entity_Idle { get; set; }
    public Vendigo_Move Vendigo_Move { get; set; }
    public Vendigo_Patrol Vendigo_Patrol { get; set; }
    public Vendigo_Attack Vendigo_Attack { get; set; }
    public Vendigo_Dead Vendigo_Dead { get; set; }
    public Vendigo_Damage Vendigo_Damage { get; set; }
    public Vendigo_Shout Vendigo_Shout { get; set; }

    public D_AttackState D_AttackState;
    public D_IdleState D_IdleState;
    public D_DeadState D_DeadState;
    public D_PatrolState D_PatrolState;
    public D_MoveState D_MoveState;

    public bool disablePatrol;

    public bool customPatrolEnable;
    public Transform[] patrolPoint;

    public bool customPatrolEnableRadius;
    public Transform patrolPointRadius;
    public float radiusPatrol;

    public override void Awake()
    {
        base.Awake();

        Vendigo_Entity_Idle = new Vendigo_Entity_Idle(this, stateMachine, "Idle", D_IdleState, this);
        Vendigo_Move = new Vendigo_Move(this, stateMachine, "Move", D_MoveState, this);
        Vendigo_Attack = new Vendigo_Attack(this, stateMachine, "Attack", D_AttackState, this);
        Vendigo_Patrol = new Vendigo_Patrol(this, stateMachine, "Move", D_PatrolState, this);
        Vendigo_Dead = new Vendigo_Dead(this, stateMachine, "Dead", false, D_DeadState, this); ;
        Vendigo_Damage = new Vendigo_Damage(this, stateMachine, "Damage", false, this);
        Vendigo_Shout = new Vendigo_Shout(this, stateMachine, "Shout", this);

    }
    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.collider.CompareTag("Player"))
            Debug.Log("HITTTT");
    }

    public override void Start()
    {
        base.Start();

        stateMachine.Initialize(Vendigo_Entity_Idle);

        seeker.pathCallback += OnPathComplete;
        DetectionTrigger += DisableDetection;
        MovementManager.isMoving += IsMoving;

    }

    private void OnDisable()
    {
        seeker.pathCallback -= OnPathComplete;
        DetectionTrigger -= DisableDetection;
        MovementManager.isMoving -= IsMoving;

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
            stateMachine.ChangeState(Vendigo_Damage);
            TriggerDetection();
        }

        current_Health -= amount;
        if (current_Health <= 0 && !CheckPoint)
        {
            CheckPoint = true;
            stateMachine.ChangeState(Vendigo_Dead);
            characterController.enabled = false;
            rb.useGravity = true;
            //AdjustAllLayer("Dead");
            //AdjustAllTag("Dead");
            CancelInvoke();
            StopAllCoroutines();
        }
        else if (!beingStun && current_Health > 0 && StunLogic(amount) && !CheckPoint && !Vendigo_Shout.hasShout)
        {
            stateMachine.ChangeState(Vendigo_Damage);
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
        dir.Set(dir.x, 0, dir.z);

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
        stateMachine.ChangeState(Vendigo_Shout);
        Vendigo_Entity_Idle.isIdleTimeOver = true;
    }

    public void Damage(float damage, RaycastHit ray, GameObject attacker)
    {
        if (enemy == null)
            enemy = attacker;
        MainHealthSet(damage);
        SpawnDecal.SpawnDecals(ray);
    }

    private void DisableDetection()
    {
        Vendigo_Shout.hasShout = false;
    }

    public void EnableDetect()
    {
        isReturning = false;
        isActive = true;
    }
    public void DisableDetect()
    {
        DisableDetection();
        DetectionCheck = false;
        CanSeePlayer = false;
        Vendigo_Entity_Idle.PresetIdle();
        stateMachine.ChangeState(Vendigo_Entity_Idle);
        if (!disablePatrol)
            isReturning = true;
        enemy = null;

    }

    private bool IsMoving()
    {
        if (stateMachine.CurrentState.animBoolName == Vendigo_Move.animBoolName || stateMachine.CurrentState.animBoolName == Vendigo_Patrol.animBoolName)
            return true;
        return false;
    }

    public override void Audio(string sound)
    {
        switch (sound)
        {
            case "Attack":
                switch (Random.Range(1, 6))
                {
                    case 1:
                        AudioManager.Play("Attack_V1");
                        break;
                    case 2:
                        AudioManager.Play("Attack_V2");
                        break;
                    case 3:
                        AudioManager.Play("Attack_V3");
                        break;
                    case 4:
                        AudioManager.Play("Attack_V4");
                        break;
                    case 5:
                        AudioManager.Play("Attack_V5");
                        break;
                }
                break;
            case "Dead":
                AudioManager.Play("Dead");
                break;
            case "Idle":
                switch (Random.Range(1, 3))
                {
                    case 1:
                        AudioManager.Play("Idle_V1");
                        break;
                    case 2:
                        AudioManager.Play("Idle_V2");
                        break;
                }
                break;
            case "Roar":
                AudioManager.Play("Roar");
                break;
        }
    }
}
public class Vendigo_Entity_Idle : IdleState
{
    Vendigo_Entity character;
    public Vendigo_Entity_Idle(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_IdleState stateData, Vendigo_Entity character) : base(entity, stateMachine, animBoolName, stateData)
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
        if (!character.DetectionCheck)
        {
            character.Audio("Idle");
        }

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

                    if (character.Vendigo_Attack.CheckIfDistance() && character.Vendigo_Attack.CheckIfCanUseAbility())
                    {
                        character.Vendigo_Attack.PresetAttack();
                        stateMachine.ChangeState(character.Vendigo_Attack);
                    }
                    else if (character.Vendigo_Move.CheckIfCanMove())
                    {
                        stateMachine.ChangeState(character.Vendigo_Move);
                    }
                }
                else
                {
                    return;
                }
            }
            else if (!character.disablePatrol && character.isActive)
            {
                character.Vendigo_Patrol.PresetPatrol();
                stateMachine.ChangeState(character.Vendigo_Patrol);
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
            character.anim.SetInteger("Type", 3);
        else
        {
            if (character.ProbabilityCheck(50))
                character.anim.SetInteger("Type", 1);
            else
                character.anim.SetInteger("Type", 2);
        }

    }
}

public class Vendigo_Move : MoveState
{
    Vendigo_Entity character;
    private Vector3 direction;
    int moveType;
    int soundCount = 0;
    public Vendigo_Move(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_MoveState stateData, Vendigo_Entity character) : base(entity, stateMachine, animBoolName, stateData)
    {
        this.character = character;
    }

    public override void Enter()
    {
        base.Enter();
        character.UpdatePath_Enemy();
        if (character.DetectionCheck)
            character.Audio("Idle");

    }

    public override void Exit()
    {
        base.Exit();
        Quaternion rot = Quaternion.LookRotation(direction, Vector3.up);
        Debug.Log("X: " + rot.x + " Y: " + rot.y + " Z: " + rot.z);
        character.transform.rotation = Quaternion.LookRotation(direction);
        character.transform.eulerAngles = new Vector3(0, character.transform.eulerAngles.y, 0);
        character.seeker.CancelCurrentPathRequest();
        character.seeker.StopAllCoroutines();
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
                if (soundCount > 10)
                {
                    soundCount = 0;
                    character.Audio("Idle");
                }
            }
            if (moveType == 1)
                character.Move(stateData.movingSpeed * 0.5f, out direction);
            else
                character.Move(stateData.movingSpeed, out direction);

            if (!character.CanSeePlayer)
            {
                character.Vendigo_Entity_Idle.PresetIdle();
                stateMachine.ChangeState(character.Vendigo_Entity_Idle);
            }
            else if (character.Vendigo_Attack.CheckIfDistance() && character.Vendigo_Attack.CheckIfCanUseAbility())
            {
                character.Vendigo_Attack.PresetAttack();
                stateMachine.ChangeState(character.Vendigo_Attack);
            }
            else if (character.IsBetween(Vector3.Distance(character.transform.position, character.enemy.transform.position), stateData.move_Thresholds[0].thresholdMin, stateData.move_Thresholds[0].thresholdMax))
            {
                character.Vendigo_Entity_Idle.PresetIdle();
                stateMachine.ChangeState(character.Vendigo_Entity_Idle);
            }
        }
    }


    public bool CheckIfCanMove()
    {
        return !character.IsBetween(Vector3.Distance(character.rayCenter.position, character.enemy.transform.position), stateData.move_Thresholds[0].thresholdMin, stateData.move_Thresholds[0].thresholdMax);
    }
}

public class Vendigo_Patrol : PatrolState
{
    Vendigo_Entity character;
    Vector3 direction;
    public Vendigo_Patrol(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_PatrolState stateData, Vendigo_Entity character) : base(entity, stateMachine, animBoolName, stateData)
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
                character.Vendigo_Entity_Idle.PresetIdle();
                stateMachine.ChangeState(character.Vendigo_Entity_Idle);

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
                character.Vendigo_Entity_Idle.PresetIdle();
                stateMachine.ChangeState(character.Vendigo_Entity_Idle);

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
                character.Vendigo_Entity_Idle.PresetIdle();
                stateMachine.ChangeState(character.Vendigo_Entity_Idle);

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
        character.seeker.StopAllCoroutines();
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();
        character.Move(character.D_MoveState.movingSpeed * character.D_PatrolState.patrolSpeedModifier, out direction);
        if (Vector3.Distance(character.transform.position, patrolNewDestination) <= 1f || character.reachedEndOfPath)
        {
            character.Vendigo_Entity_Idle.PresetIdle();
            stateMachine.ChangeState(character.Vendigo_Entity_Idle);
        }
    }

    public void PresetPatrol()
    {

        int random = Random.Range(1, 3);
        switch (random)
        {
            case 1:
                character.anim.SetInteger("Type", 1);
                break;
            case 2:
                character.anim.SetInteger("Type", 2);
                break;
        }
    }
}
public class Vendigo_Attack : AttackState
{
    Vendigo_Entity character;
    public Vendigo_Attack(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_AttackState stateData, Vendigo_Entity character) : base(entity, stateMachine, animBoolName, stateData)
    {
        this.character = character;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
        character.Vendigo_Entity_Idle.PresetIdle();
        stateMachine.ChangeState(character.Vendigo_Entity_Idle);
    }

    public override void Enter()
    {
        base.Enter();
        character.Audio("Attack");
    }

    public void PresetAttack()
    {

        int random = Random.Range(1, 5);
        switch (random)
        {
            case 1:
                character.anim.SetInteger("Type", 1);
                break;
            case 2:
                character.anim.SetInteger("Type", 2);
                break;
            case 3:
                character.anim.SetInteger("Type", 3);
                break;
            case 4:
                character.anim.SetInteger("Type", 4);
                break;
        }
    }
}
public class Vendigo_Dead : DeadState
{
    Vendigo_Entity character;

    public Vendigo_Dead(Entity entity, FiniteStateMachine stateMachine, string animBoolName, bool playAnim, D_DeadState stateData, Vendigo_Entity character) : base(entity, stateMachine, animBoolName, playAnim, stateData)
    {
        this.character = character;
    }

    public override void Enter()
    {
        base.Enter();
        character.anim.SetTrigger(animBoolName);
        deadTime = stateData.deadTime;
        character.seeker.CancelCurrentPathRequest();
        character.Audio("Dead");
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
public class Vendigo_Damage : AI_State
{
    Vendigo_Entity character;

    public Vendigo_Damage(Entity entity, FiniteStateMachine stateMachine, string animBoolName, bool playAnim, Vendigo_Entity character) : base(entity, stateMachine, animBoolName, playAnim)
    {
        this.character = character;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
        character.Vendigo_Entity_Idle.PresetIdle();
        stateMachine.ChangeState(character.Vendigo_Entity_Idle);
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
public class Vendigo_Shout : AI_State
{
    Vendigo_Entity character;
    public bool hasShout;
    private Vector3 target;
    public Vendigo_Shout(Entity entity, FiniteStateMachine stateMachine, string animBoolName, Vendigo_Entity character) : base(entity, stateMachine, animBoolName)
    {
        this.character = character;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
        hasShout = true;
        character.Vendigo_Entity_Idle.PresetIdle();
        stateMachine.ChangeState(character.Vendigo_Entity_Idle);
        character.Audio("Roar");
    }

    public override void Enter()
    {
        base.Enter();
        target = character.enemy.transform.position;
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();

        Vector3 dir = (target - character.transform.position).normalized;
        dir.Set(dir.x, 0, dir.z);

        Quaternion rot = Quaternion.LookRotation(dir, Vector3.up);

        float angle = Mathf.Abs(Vector3.Angle(dir, character.transform.forward));

        if (angle > 90)
            character.transform.rotation = Quaternion.RotateTowards(character.transform.rotation, rot, 800 * Time.deltaTime);
        else
            character.transform.rotation = Quaternion.RotateTowards(character.transform.rotation, rot, 600 * Time.deltaTime);
    }
}
