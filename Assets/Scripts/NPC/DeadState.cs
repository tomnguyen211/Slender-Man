using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeadState : AI_State
{
    protected D_DeadState stateData;

    protected float deadTime;

    public DeadState(Entity entity, FiniteStateMachine stateMachine, string animBoolName, bool playAnim, D_DeadState stateData) : base(entity, stateMachine, animBoolName, playAnim)
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

        deadTime = stateData.deadTime;
    }

    public override void Exit()
    {
        base.Exit();
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();
    }

    public override void PhysicUpdate()
    {
        base.PhysicUpdate();
    }
}
