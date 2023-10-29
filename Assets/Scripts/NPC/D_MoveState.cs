using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "newCharacterData", menuName = "Data/Character Data/Move Data")]

public class D_MoveState : ScriptableObject
{
    public float movingSpeed = 3;
    public float moveTimer = 1;

    public Move_Threshold[] move_Thresholds;
}

[System.Serializable]
public struct Move_Threshold
{
    public string thresholdName;
    public float thresholdMin;
    public float thresholdMax;
}

