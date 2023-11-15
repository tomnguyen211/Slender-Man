using UnityEditor.Experimental.GraphView;
using UnityEngine;

public class Beast_Entity : Entity, IDamage, IDetect
{
    public Beast_Idle Beast_Idle { get; private set; }
    public Beast_Move Beast_Move { get; private set; }


    public Beast_Attack Beast_Attack { get; private set; }
    public Beast_Dead Beast_Dead { get; private set; }
    public Beast_Patrol Beast_Patrol { get; private set; }
    public Beast_Damage Beast_Damage { get; private set; }
    public Beast_Shout Beast_Shout { get; private set; }

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

        Beast_Idle = new Beast_Idle(this, stateMachine, "Idle", D_IdleState, this);
        Beast_Move = new Beast_Move(this, stateMachine, "Move",D_MoveState, this);
        Beast_Attack = new Beast_Attack(this,stateMachine,"Attack",D_AttackState, this);
        Beast_Patrol = new Beast_Patrol(this,stateMachine,"Move",D_PatrolState, this);  
        Beast_Dead = new Beast_Dead(this,stateMachine,"Dead", false,D_DeadState, this);;
        Beast_Damage = new Beast_Damage(this, stateMachine, "Damage", false ,this);
        Beast_Shout = new Beast_Shout(this, stateMachine, "Shout", this);

    }    

    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.collider.CompareTag("Player"))
            Debug.Log("HITTTT");
    }

    public override void Start()
    {
        base.Start();

        stateMachine.Initialize(Beast_Idle);

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
            stateMachine.ChangeState(Beast_Damage);
            TriggerDetection();
        }

        current_Health -= amount;
        if (current_Health <= 0 && !CheckPoint)
        {
            CheckPoint = true;
            stateMachine.ChangeState(Beast_Dead);
            characterController.enabled = false;
            rb.useGravity = true;
            //AdjustAllLayer("Dead");
            //AdjustAllTag("Dead");
            CancelInvoke();
            StopAllCoroutines();
        }
        else if(!beingStun && current_Health > 0 && StunLogic(amount) && !CheckPoint && !Beast_Shout.hasShout)
        {
            stateMachine.ChangeState(Beast_Damage);
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

            /*float leftRight = AngleDir(transform.forward, enemyDir, transform.up);

            if(leftRight == 1)
                anim.SetFloat("xDir", angle);
            else if(leftRight == -1)
                anim.SetFloat("xDir", -angle);
            else
                anim.SetFloat("xDir", 0);*/



        }
        Debug.Log(angle);


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
        stateMachine.ChangeState(Beast_Shout);
        Beast_Idle.isIdleTimeOver = true;
    }

    public void Damage(float damage,RaycastHit ray, GameObject attacker)
    {
        if (enemy == null)
            enemy = attacker;
        MainHealthSet(damage);
        SpawnDecal.SpawnDecals(ray);
    }

    private void DisableDetection()
    {
        Beast_Shout.hasShout = false;
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
        Beast_Idle.PresetIdle();
        stateMachine.ChangeState(Beast_Idle);
        if (!disablePatrol)
            isReturning = true;
        enemy = null;

    }

    private bool IsMoving()
    {
     if (stateMachine.CurrentState.animBoolName == Beast_Move.animBoolName || stateMachine.CurrentState.animBoolName == Beast_Patrol.animBoolName)
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
                switch (Random.Range(1, 3))
                {
                    case 1:
                        AudioManager.Play("Dead_V1");
                        break;
                    case 2:
                        AudioManager.Play("Dead_V2");
                        break;
                }
                break;
            case "Idle":
                AudioManager.Play("Idle");
                break;
            case "Roar":
                switch (Random.Range(1, 3))
                {
                    case 1:
                        AudioManager.Play("Growl_V1");
                        break;
                    case 2:
                        AudioManager.Play("Growl_V2");
                        break;
                }
                break;
        }
    }
}

public class Beast_Idle : IdleState
{
    Beast_Entity character;
    public Beast_Idle(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_IdleState stateData, Beast_Entity character) : base(entity, stateMachine, animBoolName, stateData)
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
        character.rb.constraints = RigidbodyConstraints.FreezeAll;

    }

    public override void Exit()
    {
        base.Exit();
        character.rb.constraints = RigidbodyConstraints.None;

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

                    if (character.Beast_Attack.CheckIfDistance() && character.Beast_Attack.CheckIfCanUseAbility())
                    {
                        Debug.Log(Vector3.Distance(character.rayCenter.position, character.enemy.transform.position));
                        stateMachine.ChangeState(character.Beast_Attack);
                    }
                    else if (character.Beast_Move.CheckIfCanMove())
                    {
                        Debug.Log(Vector3.Distance(character.transform.position, character.enemy.transform.position));
                        character.Beast_Move.PresetMove();
                        stateMachine.ChangeState(character.Beast_Move);
                    }
                }
                else
                {
                    return;
                }
            }
            else if (!character.disablePatrol && character.isActive)
            {
                stateMachine.ChangeState(character.Beast_Patrol);
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
            if(character.ProbabilityCheck(50))
                character.anim.SetInteger("Type", 1);
            else
                character.anim.SetInteger("Type", 2);
        }

    }
}

public class Beast_Move : MoveState
{
    Beast_Entity character;
    private Vector3 direction;
    int moveType;
    int soundCount = 0;
    public Beast_Move(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_MoveState stateData, Beast_Entity character) : base(entity, stateMachine, animBoolName, stateData)
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

                if (character.DetectionCheck)
                {
                    soundCount++;
                    if (soundCount > 10)
                    {
                        soundCount = 0;
                        character.Audio("Roar");
                    }
                }
            }
            if(moveType == 1)
                character.Move(stateData.movingSpeed * 0.5f,out direction);
            else
                character.Move(stateData.movingSpeed, out direction);

            if (!character.CanSeePlayer)
            {
                character.Beast_Idle.PresetIdle();
                stateMachine.ChangeState(character.Beast_Idle);
            }
            else if (character.Beast_Attack.CheckIfDistance() && character.Beast_Attack.CheckIfCanUseAbility())
            {
                Debug.Log(Vector3.Distance(character.rayCenter.position, character.enemy.transform.position));
                stateMachine.ChangeState(character.Beast_Attack);
            }
            else if (character.IsBetween(Vector3.Distance(character.transform.position, character.enemy.transform.position), stateData.move_Thresholds[0].thresholdMin, stateData.move_Thresholds[0].thresholdMax))
            {
                Debug.Log(Vector3.Distance(character.transform.position, character.enemy.transform.position));
                character.Beast_Idle.PresetIdle();
                stateMachine.ChangeState(character.Beast_Idle);
            }
        }
    }

    public void PresetMove()
    {
        if(!character.DetectionCheck)
        {
            character.anim.SetInteger("Type", 1);

        }
        else
        {
            if(Vector3.Distance(character.rayCenter.position,character.enemy.transform.position) >= 6f)
                character.anim.SetInteger("Type", 2);
            else
                character.anim.SetInteger("Type", 1);


        }
    }

    public void PresetMove(int type)
    {

        switch(type)
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

public class Beast_Patrol : PatrolState
{
    Beast_Entity character;
    Vector3 direction;
    public Beast_Patrol(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_PatrolState stateData, Beast_Entity character) : base(entity, stateMachine, animBoolName, stateData)
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
                character.Beast_Idle.PresetIdle();
                stateMachine.ChangeState(character.Beast_Idle);

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
                character.Beast_Idle.PresetIdle();
                stateMachine.ChangeState(character.Beast_Idle);

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
                character.Beast_Idle.PresetIdle();
                stateMachine.ChangeState(character.Beast_Idle);

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
            character.Beast_Idle.PresetIdle();
            stateMachine.ChangeState(character.Beast_Idle);
        }
    }
    public void PresetMPatrol()
    {
        character.anim.SetInteger("Type", 3);
    }
}
public class Beast_Attack : AttackState
{
    Beast_Entity character;
    public Beast_Attack(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_AttackState stateData, Beast_Entity character) : base(entity, stateMachine, animBoolName, stateData)
    {
        this.character = character;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
        stateMachine.ChangeState(character.Beast_Idle);
    }

    public override void Enter()
    {
        base.Enter();

        character.Audio("Attack");
        character.rb.constraints = RigidbodyConstraints.FreezeAll;


    }

    public override void Exit()
    {
        base.Exit();
        character.rb.constraints = RigidbodyConstraints.None;

    }
}
public class Beast_Dead : DeadState
{
    Beast_Entity character;

    public Beast_Dead(Entity entity, FiniteStateMachine stateMachine, string animBoolName, bool playAnim, D_DeadState stateData, Beast_Entity character) : base(entity, stateMachine, animBoolName, playAnim, stateData)
    {
        this.character = character;
    }

    public override void Enter()
    {
        base.Enter();
        character.anim.SetTrigger(animBoolName);
        deadTime = stateData.deadTime;
        character.seeker.CancelCurrentPathRequest();
        character.rb.constraints = RigidbodyConstraints.FreezeAll;

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
public class Beast_Damage : AI_State
{
    Beast_Entity character;

    public Beast_Damage(Entity entity, FiniteStateMachine stateMachine, string animBoolName, bool playAnim, Beast_Entity character) : base(entity, stateMachine, animBoolName, playAnim)
    {
        this.character = character;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
        if(character.Beast_Shout.hasShout)
            stateMachine.ChangeState(character.Beast_Idle);
        else
            stateMachine.ChangeState(character.Beast_Shout);
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

public class Beast_Shout : AI_State
{
    Beast_Entity character;
    public bool hasShout;
    private Vector3 target;
    public Beast_Shout(Entity entity, FiniteStateMachine stateMachine, string animBoolName, Beast_Entity character) : base(entity, stateMachine, animBoolName)
    {
        this.character = character;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
        hasShout = true;
        stateMachine.ChangeState(character.Beast_Idle);
    }

    public override void Enter()
    {
        base.Enter();
        target = character.enemy.transform.position;

        character.Audio("Roar");

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
