using System.Collections;
using System.Collections.Generic;
using Unity.Entities.UniversalDelegates;
using UnityEngine;

public class PlayerState
{
    protected PlayerBase player;
    protected PlayerStateMachine stateMachine;
    protected PlayerData playerData;

    protected bool isAnimationFinished;
    protected bool isExitingState;

    protected float startTime;

    protected string animBoolName;
    protected bool playAnim;
    protected string previous_animBoolName;

    public PlayerState(PlayerBase player, PlayerStateMachine stateMachine, PlayerData playerData, string animBoolName)
    {
        this.player = player;
        this.stateMachine = stateMachine;
        this.playerData = playerData;
        this.animBoolName = animBoolName;
        this.playAnim = true;
    }

    public PlayerState(PlayerBase player, PlayerStateMachine stateMachine, PlayerData playerData, string animBoolName, bool playAnim)
    {
        this.player = player;
        this.stateMachine = stateMachine;
        this.playerData = playerData;
        this.animBoolName = animBoolName;
        this.playAnim = playAnim;
    }
    public virtual void Enter()
    {
        DoCheck();

        stateMachine.CurrentState.previous_animBoolName = stateMachine.PreviousState.animBoolName;

        if (playAnim)
        {
            /*for (int i = 0; i < player.Anim.Length; i++)
                player.Anim[i].SetBool(animBoolName, true);*/
            player.Anim.SetBool(animBoolName, true);

        }
        else
        {

            /*for (int i = 0; i < player.Anim.Length; i++)
                player.Anim[i].SetBool(animBoolName, false);*/
            player.Anim.SetBool(animBoolName, false);
        }

        startTime = Time.time;

        Debug.Log(animBoolName);

        isAnimationFinished = false;
        isExitingState = false;
    }

    public virtual void Exit()
    {
        /* if(playAnim)
         {

             for (int i = 0; i < player.Anim.Length; i++)
                 player.Anim[i].SetBool(animBoolName, false);
             //player.Anim.SetBool(animBoolName, false);
         }*/
        /*for (int i = 0; i < player.Anim.Length; i++)
            player.Anim[i].SetBool(animBoolName, false);*/

        player.Anim.SetBool(animBoolName, false);
        isExitingState = true;
    }

    public virtual void LogicUpdate()
    {

    }

    public virtual void PhysicUpdate()
    {
        DoCheck();
    }

    public virtual void DoCheck() { }


    public virtual void AnimationTrigger() { }

    public virtual void AnimationFinishTrigger() => isAnimationFinished = true;

    public virtual void AnimationFlipTrigger() { }

    public virtual void AnimationMovementTrigger() { }

    public virtual void AnimationWhoopSoundTrigger() { }
}
