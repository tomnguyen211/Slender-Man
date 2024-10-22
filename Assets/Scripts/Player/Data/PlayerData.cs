using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "newPlayerData", menuName = "Data/Player Data/Base Data")]

public class PlayerData : ScriptableObject
{
    [Header("Health")]
    public float healthCount = 100;

    [Header("Move State")]
    public float movementVelocity = 10;

    [Header("Jump State")]
    public float jumpVelocity = 5;

    [Header("In Air State")]
    public float coyoteTime = 0.2f;
    public float variableJumpHeightMultiplier = 0.5f;


    [Header("Check Variables")]
    public float groundCheckRadius = 0.3f;
    public float wallCheckDistance = 0.5f;
    public float ceilingCheckRadius = 0.2f;

    [Header("Others")]
    public float disBetweenAfterImages = 0.5f;
    public float drag = 5f;
    public float standColliderHeight = 0.9f;

    public LayerMask whatisGround;
    public LayerMask character;
    public LayerMask protection;
    public LayerMask armor;
    public LayerMask projectile;
}
