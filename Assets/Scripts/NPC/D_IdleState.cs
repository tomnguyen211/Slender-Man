using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "newCharacterData", menuName = "Data/Character Data/Idle Data")]
public class D_IdleState : ScriptableObject
{
    public float minIdleTime;
    public float maxIdleTime;

    public float idleTime;
}
