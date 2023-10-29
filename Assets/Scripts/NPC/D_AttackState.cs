using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "newCharacterData", menuName = "Data/Character Data/Attack Data")]
public class D_AttackState : ScriptableObject
{
    public bool intialAbilityEnable = true;

    public float coolDownTime = 10;

    public float minDistance = 0;
    public float maxDistance = 2;

    public float velocity = 1;

    public float duration = 1;

}
