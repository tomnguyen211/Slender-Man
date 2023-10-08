using System.Collections;
using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

public class IdleState : AI_State
{
    protected D_IdleState stateData;

    private bool setIdleTime;
    public bool isIdleTimeOver;

    protected float idleTime;

    public IdleState(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_IdleState stateData) : base(entity, stateMachine, animBoolName)
    {
        this.stateData = stateData;
    }

    public override void Enter()
    {
        base.Enter();

       /* if (!entity.CheckIfKnockback)
            entity.SetVelocityZero();*/

        isIdleTimeOver = false;

        if (setIdleTime)
        {
            setIdleTime = false;
        }
        else if (entity.DetectionCheck)
        {
            idleTime = stateData.idleTime;
        }
        else
        {
            SetRandomIdleTime();
        }
    }

    public override void Exit()
    {
        base.Exit();

    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();

        if (Time.time > startTime + idleTime)
        {
            isIdleTimeOver = true;
        }
    }

    public override void PhysicUpdate()
    {
        base.PhysicUpdate();
    }

    protected void SetRandomIdleTime()
    {
        idleTime = Random.Range(stateData.minIdleTime, stateData.maxIdleTime);
    }
    public void SetIdleTime(float time)
    {
        idleTime = time;
        setIdleTime = true;
    }
}
