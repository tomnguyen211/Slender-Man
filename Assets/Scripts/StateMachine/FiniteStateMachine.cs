using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FiniteStateMachine
{
    public AI_State CurrentState { get; private set; }

    public AI_State PreviousState { get; private set; }

    public void Initialize(AI_State startingState)
    {
        CurrentState = startingState;
        PreviousState = startingState;
        CurrentState.Enter();
    }

    public void ChangeState(AI_State newState)
    {
        PreviousState = CurrentState;
        CurrentState.Exit();
        CurrentState = newState;
        CurrentState.Enter();
    }
}
