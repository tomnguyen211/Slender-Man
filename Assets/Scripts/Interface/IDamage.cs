using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDamage 
{
    public void Damage(float damage, GameObject attacker) { }

    public void Damage(float damage,RaycastHit ray, GameObject attacker) { }

    public float GetHealth => GetHealth;
    public float GetMaxHealth => GetMaxHealth;

    public float GetFirstAbilityBar => GetFirstAbilityBar;
    public float GetFirstAbilityBarMax => GetFirstAbilityBarMax;


    public float GetSecondAbilityBar => GetSecondAbilityBar;
    public float GetSeocondManaAbilityMax => GetSeocondManaAbilityMax;

}
