using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetParentObject : MonoBehaviour, IDamage
{
    public GameObject parent;

    public void Damage(float damage)
    {
        if (parent.TryGetComponent<IDamage>(out IDamage component))
        {
            component.Damage(damage);
        }
    }

    public void Damage(float damage, RaycastHit ray)
    {
        if (parent.TryGetComponent<IDamage>(out IDamage component))
        {
            component.Damage(damage,ray);
        }
    }


}
