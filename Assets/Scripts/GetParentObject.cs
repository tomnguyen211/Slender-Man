using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetParentObject : MonoBehaviour, IDamage
{
    public GameObject parent;

    public void Damage(float damage, GameObject attacker)
    {
        if (parent.TryGetComponent<IDamage>(out IDamage component))
        {
            component.Damage(damage, attacker);
        }
    }

    public void Damage(float damage, RaycastHit ray, GameObject attacker)
    {
        if (parent.TryGetComponent<IDamage>(out IDamage component))
        {
            component.Damage(damage,ray, attacker);
        }
    }


}
