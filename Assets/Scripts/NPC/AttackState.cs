using System.Collections;
using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

public class AttackState : AI_State
{
    public D_AttackState stateData;

    public bool isAbilityEnable;
    protected bool initialAbilityEnable;

    public float lastAbilityTime;

    public AttackState(Entity entity, FiniteStateMachine stateMachine, string animBoolName, D_AttackState stateData) : base(entity, stateMachine, animBoolName)
    {
        this.stateData = stateData;
        isAbilityEnable = stateData.intialAbilityEnable;
        lastAbilityTime = Time.time;
    }

    public override void AnimationFinishTrigger()
    {
        base.AnimationFinishTrigger();
    }

    public override void AnimationTrigger()
    {
        base.AnimationTrigger();
    }

    public override void Enter()
    {
        base.Enter();
        isAbilityEnable = false;
        initialAbilityEnable = false;
    }

    public override void Exit()
    {
        base.Exit();

        lastAbilityTime = Time.time;
    }

    public override void LogicUpdate()
    {
        base.LogicUpdate();
    }

    public override void PhysicUpdate()
    {
        base.PhysicUpdate();
    }

    public virtual bool CheckIfCanUseAbility()
    {
        return (isAbilityEnable || (Time.time >= lastAbilityTime + stateData.coolDownTime && !initialAbilityEnable) || initialAbilityEnable) /*&& !entity.CheckIfKnockback*/;
    }

    public bool CheckIfDistance()
    {
        return entity.IsBetween(Vector2.Distance(entity.rayCenter.transform.position, entity.enemy.transform.position), stateData.minDistance, stateData.maxDistance);
    }

    public void ResetAbilityAttack() => isAbilityEnable = true;
}
