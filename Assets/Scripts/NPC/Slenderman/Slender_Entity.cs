using DG.Tweening;
using System.Collections;
using UnityEngine;
using UnityEngine.TextCore.Text;

public class Slender_Entity : Entity, IDamage
{
    public bool isAggresive;

    public bool Idle;

    public bool Walk;

    public bool Run;

    public bool Scream;

    private bool isDamage;

    private bool moveTriggerLocation;

    private bool floatingTriggerLocation;
    private Vector3 floatPoint;


    [SerializeField]
    SphereCollider sphereCol;

    [SerializeField]
    SkinnedMeshRenderer bodySkin;
    [SerializeField]
    SkinnedMeshRenderer tentacleSkin;



    Slender_Idle Slender_Idle { get; set; }
    Slender_Walk Slender_Walk { get; set; }
    Slender_Run Slender_Run { get; set; }
    Scream_State Scream_State { get; set; }
    Slender_Dead Slender_Dead { get; set; }

    [SerializeField]
    SlenderWeapon SlenderWeapon;

    [SerializeField]
    AudioSource LaughSound;
    [SerializeField]
    AudioClip[] laughClip;

    public override void Awake()
    {
        base.Awake();

        Slender_Idle = new Slender_Idle(this, stateMachine, "Idle", this);
        Slender_Walk = new Slender_Walk(this, stateMachine, "Walk", this);
        Slender_Run = new Slender_Run(this, stateMachine, "Run", this);
        Scream_State = new Scream_State(this, stateMachine, "Roar", this);
        Slender_Dead = new Slender_Dead(this, stateMachine, "Idle", this);

        
    }

    public void TriggerState(string state)
    {
        switch(state)
        {
                case "Idle":
                stateMachine.ChangeState(Slender_Idle);
                break;
                case "Walk":
                stateMachine.ChangeState(Slender_Walk);
                break;
                case "Run":
                stateMachine.ChangeState(Slender_Run);
                break;
                case "Scream":
                stateMachine.ChangeState(Scream_State);
                break;
                case "Dead":
                stateMachine.ChangeState(Slender_Dead);
                break;
        }
    }


    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.collider.CompareTag("Player"))
            Debug.Log("HITTTT");
    }

    public override void Start()
    {
        base.Start();

        if (Idle)
        {
            stateMachine.Initialize(Slender_Idle);
        }
        else if (Walk)
        {
            stateMachine.Initialize(Slender_Walk);
        }
        else if (Run)
        {
            stateMachine.Initialize(Slender_Run);
        }
        else if (Scream)
        {
            stateMachine.Initialize(Scream_State);
        }
        else
            stateMachine.Initialize(Slender_Idle);


        seeker.pathCallback += OnPathComplete;
        //MovementManager.isMoving += IsMoving;

        if(isAggresive)
        {
            LaughSound.clip = laughClip[Random.Range(0, laughClip.Length)];
            LaughSound.Play();
        }

    }

    private void OnDisable()
    {
        seeker.pathCallback -= OnPathComplete;
        //MovementManager.isMoving -= IsMoving;

    }

    public override void Update()
    {
        base.Update();

        if(moveTriggerLocation)
        {
            Debug.Log("Passed2");
            Vector3 dir;
            Move(0.6f, out dir);
        }

        if(floatingTriggerLocation)
        {
            transform.position = Vector3.MoveTowards(transform.position, floatPoint, Time.deltaTime * 0.5f);
        }
    }

    public override void FixedUpdate()
    {
        base.FixedUpdate();
    }

    public override void MainHealthSet(float amount)
    {
        base.MainHealthSet(amount);
        
        if(!isDamage)
        {
            current_Health -= amount;
            Debug.Log("Health: " + current_Health);
            if (current_Health <= 0 && !CheckPoint)
            {
                CheckPoint = true;
                //stateMachine.ChangeState(Slender_Dead);
                characterController.enabled = false;
                //rb.useGravity = true;
                //AdjustAllLayer("Dead");
                //AdjustAllTag("Dead");
                //CancelInvoke();
                //StopAllCoroutines();
                Fading();
            }
            isDamage = true;
            StartCoroutine(Danmage_Reset());
        }
    }

    #region Events

    public void SetRadius(float radius)
    {
        sphereCol.radius = radius;
    }
    public void Fading()
    {
        //StopAllCoroutines();
        bodySkin.materials[0].DOFloat(0, "_FullGlowDissolveFade", 3);
        bodySkin.materials[1].DOFloat(0, "_FullGlowDissolveFade", 3);
        bodySkin.materials[2].DOFloat(0, "_FullGlowDissolveFade", 3);
        tentacleSkin.material.DOFloat(0, "_FullGlowDissolveFade", 3);
        SlenderWeapon.Disable_Damage();
    }

    public void MoveToDestination(Vector3 position)
    {
        UpdatePath_Des(position);
        moveTriggerLocation = true;
    }

    public void FlatingDestination(Vector3 position)
    {
        floatingTriggerLocation = true;
        floatPoint = position;
    }

    public void StopMoveToDestination()
    {
        moveTriggerLocation = false;
        seeker.CancelCurrentPathRequest();
        seeker.StopAllCoroutines();
    }

    public void DisaleObject(float time)
    {
        StartCoroutine(DisableTime(time));
    }

    private IEnumerator DisableTime(float time)
    {
        yield return new WaitForSeconds(time);
        gameObject.SetActive(false);
        SlenderWeapon.Disable_Damage();
    }

    public

    #endregion

    IEnumerator Danmage_Reset()
    {
        yield return new WaitForSeconds(0.5f);
        isDamage = false;
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
        angle = Mathf.Abs(angle);
        if (angle > 90)
            transform.rotation = Quaternion.RotateTowards(transform.rotation, rot, 300 * Time.deltaTime);
        else
            transform.rotation = Quaternion.RotateTowards(transform.rotation, rot, 150 * Time.deltaTime);
        characterController.SimpleMove(velocity);
    }

    public override void TriggerDetection()
    {
        base.TriggerDetection();
        stateMachine.ChangeState(Slender_Idle);
    }

    public void Damage(float damage, GameObject attacker)
    {
        if (enemy == null)
            enemy = attacker;

        Debug.Log("SlenderHealth: ");

        MainHealthSet(damage);
        //SpawnDecal.SpawnDecals(ray);
    }
    private bool IsMoving()
    {
/*        if (stateMachine.CurrentState.animBoolName == Beast_Move.animBoolName || stateMachine.CurrentState.animBoolName == Beast_Patrol.animBoolName)
            return true;*/
        return false;
    }
}

public class Slender_Idle : AI_State
{
    Slender_Entity character;
    public Slender_Idle(Entity entity, FiniteStateMachine stateMachine, string animBoolName, Slender_Entity character) : base(entity, stateMachine, animBoolName)
    {
        this.character = character;
    }
}

public class Slender_Walk : AI_State
{
    Slender_Entity character;

    public Slender_Walk(Entity entity, FiniteStateMachine stateMachine, string animBoolName, Slender_Entity character) : base(entity, stateMachine, animBoolName)
    {
        this.character = character;
    }
}

public class Slender_Run : AI_State
{
    Slender_Entity character;

    public Slender_Run(Entity entity, FiniteStateMachine stateMachine, string animBoolName, Slender_Entity character) : base(entity, stateMachine, animBoolName)
    {
        this.character = character;
    }
}

public class Scream_State : AI_State
{
    Slender_Entity character;

    public Scream_State(Entity entity, FiniteStateMachine stateMachine, string animBoolName, Slender_Entity character) : base(entity, stateMachine, animBoolName)
    {
        this.character = character;
    }
}

public class Slender_Dead : AI_State
{
    Slender_Entity character;

    public Slender_Dead(Entity entity, FiniteStateMachine stateMachine, string animBoolName, Slender_Entity character) : base(entity, stateMachine, animBoolName)
    {
        this.character = character;
    }
}
