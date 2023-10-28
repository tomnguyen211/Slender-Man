using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDamage 
{
    public void Damage(float damage, GameObject attacker) { }

    public void Damage(float damage,RaycastHit ray, GameObject attacker) { }

}
