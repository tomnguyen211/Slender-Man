using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlenderWeapon : MonoBehaviour
{
    public bool damageEnable;

    public bool isInflictDamage;

    [SerializeField]
    GameObject parentObject;

    [SerializeField]
    LayerMask playerLayer;

    private GameObject currentPlayer;


    private void OnTriggerStay(Collider col)
    {
        if(damageEnable)
        {
            if(((1 << col.gameObject.layer) & playerLayer) != 0 && col.CompareTag("Player") && !isInflictDamage)
            {
                if(col.TryGetComponent<IDamage>(out IDamage component))
                {
                    currentPlayer = col.gameObject;
                    component.Glitch_Damage_Enable(parentObject, false);
                    isInflictDamage = true;
                }
            }
        }
    }

    private void OnTriggerExit(Collider col)
    {
        if (((1 << col.gameObject.layer) & playerLayer) != 0 && col.CompareTag("Player") && isInflictDamage)
        {
            if (col.TryGetComponent<IDamage>(out IDamage component))
            {
                component.Glitch_Damage_Disable(parentObject, false);
                isInflictDamage = false;
            }
        }
    }

    public void Disable_Damage()
    {
        if(currentPlayer != null)
        {
            if (currentPlayer.TryGetComponent<IDamage>(out IDamage component))
            {
                component.Glitch_Damage_Disable(parentObject, false);
                isInflictDamage = false;
            }
        }
        damageEnable = false;
    }
}
