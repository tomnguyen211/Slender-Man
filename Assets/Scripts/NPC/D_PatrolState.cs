using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "newCharacterData", menuName = "Data/Character Data/Patrol Data")]

public class D_PatrolState : ScriptableObject
{
    public float minPatrolTimer = 5;
    public float maxPatrolTimer = 5;

    [Range(0f, 1f)]
    public float patrolSpeedModifier = 0.8f;

    public float moveTimer = 1;
}
