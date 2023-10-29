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

    public bool playAnim;

    public AI_State(Entity entity, FiniteStateMachine stateMachine, string animBoolName)
    {
        this.entity = entity;
        this.stateMachine = stateMachine;
        this.animBoolName = animBoolName;
        playAnim = true;
    }

    public AI_State(Entity entity, FiniteStateMachine stateMachine, string animBoolName, bool playAnim)
    {
        this.entity = entity;
        this.stateMachine = stateMachine;
        this.animBoolName = animBoolName;
        this.playAnim = playAnim;
    }

    public virtual void Enter()
    {
        DoCheck();

        startTime = Time.time;

        if(playAnim)
            entity.anim.SetBool(animBoolName, true);

        isAnimationFinished = false;
        isExitingState = false;

        Debug.Log("Entity Name: " + entity.name + " State: " + animBoolName);
    }

    public virtual void Exit()
    {
        if(playAnim)
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
