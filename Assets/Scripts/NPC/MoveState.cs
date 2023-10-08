using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveState : AI_State
{
    protected D_MoveState stateData;

    public MoveState(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_MoveState stateData) : base(entity, stateMachine, animBoolName)
    {
        this.stateData = stateData;
    }

    protected float moveTimer;
    protected bool isMoveReset;

    public override void Enter()
    {
        base.Enter();

        isMoveReset = false;
        moveTimer = stateData.moveTimer;
    }

    public override void Exit()
    {
        base.Exit();
        isMoveReset = false;
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();

        if (Time.time > startTime + moveTimer)
        {
            isMoveReset = true;
        }
    }

    public override void PhysicUpdate()
    {
        base.PhysicUpdate();
    }
   
}
