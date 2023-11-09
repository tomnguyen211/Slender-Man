using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PatrolState : AI_State
{
    protected D_PatrolState stateData;

    protected float patrolSpeed;

    protected bool patrolArrived;
    protected float patrolTimer;

    protected Vector3 patrolNewDestination;
    protected Vector3 patrolPreviousDestination;


    protected bool frameDelay;
    protected float timer = 0.5f;
    protected bool checkAgain;

    protected float moveTimer;
    protected bool isMoveReset;

    public PatrolState(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_PatrolState stateData) : base(entity, stateMachine, animBoolName)
    {
        this.stateData = stateData;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
    }

    public override void AnimationTrigger()
    {
        base.AnimationTrigger();
    }

    public override void DoCheck()
    {
        base.DoCheck();
    }

    public override void Enter()
    {
        base.Enter();

        patrolArrived = false;
        patrolTimer = Random.Range(stateData.minPatrolTimer, stateData.maxPatrolTimer);

        frameDelay = false;
        checkAgain = false;
        timer = 0.5f;

        moveTimer = stateData.moveTimer;

    }

    public override void Exit()
    {
        base.Exit();

        patrolArrived = true;
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();

        if (Time.time > startTime + moveTimer)
        {
            isMoveReset = true;
        }

        NavAgentDelay();

    }

    public override void PhysicUpdate()
    {
        base.PhysicUpdate();
    }

    protected void NavAgentDelay()
    {
        if (!checkAgain && frameDelay && timer <= 0)
        {
            frameDelay = false;
            checkAgain = true;
            timer = 0.5f;
        }

        if (checkAgain && timer <= 0)
        {
            checkAgain = false;
            timer = 0.5f;
        }
        else if (timer > 0)
            timer -= Time.deltaTime;
    }
}
