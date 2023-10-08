using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AI_State : MonoBehaviour
{
    protected FiniteStateMachine stateMachine;
    protected Entity entity;

    protected bool isAnimationFinished;
    protected bool isExitingState;

    protected float startTime;

    public string animBoolName;

    public AI_State(Entity entity, FiniteStateMachine stateMachine, string animBoolName)
    {
        this.entity = entity;
        this.stateMachine = stateMachine;
        this.animBoolName = animBoolName;
    }

    public virtual void Enter()
    {
        DoCheck();

        startTime = Time.time;
        entity.anim.SetBool(animBoolName, true);

        isAnimationFinished = false;
        isExitingState = false;

        Debug.Log("Entity Name: " + entity.name + " State: " + animBoolName);
    }

    public virtual void Exit()
    {

        entity.anim.SetBool(animBoolName, false);

        isExitingState = true;

    }

    public virtual void LogicUpdate() { }

    public virtual void PhysicUpdate() { DoCheck(); }

    public virtual void DoCheck() { }

    public virtual void AnimationTrigger() { }

    public virtual void AnimationFinishTrigger() => isAnimationFinished = true;

    public virtual void AnimationVFXTrigger() { }
}
