using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[CreateAssetMenu(fileName = "newCharacterData", menuName = "Data/Character Data/Entity Data")]

public class D_Entity : ScriptableObject
{
    public float healthCount = 100;
    [Range(0f, 1f)]
    public float stunRes = 0;

    public float wallCheckDistance = 0.5f;
    public float groundCheckDistance = 0.5f;
    public float characterCheckDistance = 0.5f;

    public LayerMask whatIsGround;
    public LayerMask character;
    public LayerMask armor;
    public LayerMask miscellaneous;

    public float radiusAfterDetection = 6;
    public float radiusDetection = 4;
    [Range(0, 360)]
    public float angleDetection;

    public float detectionTimer = 30;
}
