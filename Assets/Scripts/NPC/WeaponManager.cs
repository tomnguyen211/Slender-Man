using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Events;

public class WeaponManager : MonoBehaviour
{

    [HideInInspector]
    public List<GameObject> damaged_Object;
    [HideInInspector]
    public List<GameObject> area_damaged_Object;

    // Damage Enable
    public bool damage_Enable;

    //Weapon Damage MASTER
    public float weapon_Damage_MASTER;

    //Weapon Damage
    [ReadOnly]
    public float weapon_Damage;

    /** 6 Tiers
     * Tier 1: 5%   - Low
     * Tier 2: 15%  - Medium
     * Tier 3: 30%  - High
     * Tier 4: 50%  - Very High
     * Tier 5: 90&  - Extreme
     * Tier 6::-1%  - Guarantee
     */
    [SerializeField]
    public float fireChance_MASTER;
    [ReadOnly]
    public float fireChance;
    [SerializeField]
    public float electricChance_MASTER;
    [ReadOnly]
    public float electricChance;
    [SerializeField]
    public float iceChance_MASTER;
    [ReadOnly]
    public float iceChance;
    [SerializeField]
    public float poisonChance_MASTER;
    [ReadOnly]
    public float poisonChance;

    // Elemental Damage MASTER
    [SerializeField]
    public float fireDam_MASTER;
    [SerializeField]
    public float electricDam_MASTER;
    [SerializeField]
    public float iceDam_MASTER;
    [SerializeField]
    public float poisonDam_MASTER;

    // Elemental Damage
    [SerializeField, ReadOnly]
    public float fireDam;
    [SerializeField, ReadOnly]
    public float electricDam;
    [SerializeField, ReadOnly]
    public float iceDam;
    [SerializeField, ReadOnly]
    public float poisonDam;

    [SerializeField]
    LayerMask armor;

    public GameObject parentObject;

    //Pierce Controller
    [HideInInspector]
    public bool hasCollided;
    [SerializeField]
    public int pierceThrough;
    [SerializeField, ReadOnly]
    private int pierceCount;
    public bool unlimited_pierce;

    // Exclude self
    public bool exclude_Self = true;
    // Area Damage
    [Header("DAMAGE OVER TIME")]
    public bool area_damage;
    [ReadOnly]
    public bool transfer_manager;
    public float areaDamage_tick;
    public float areaDamage_delayTimer;
    public float areaDamage_endTimer;
    public UnityAction areaDamage_activate;


    [HideInInspector]
    public Collider collision_Collider;
    [HideInInspector]
    public Vector3 collisionPos;
    [HideInInspector]
    public float collisionDir;
    [HideInInspector]
    public UnityAction collisionEffect_Trigger;

    // Success //
    public UnityAction action_trigger_success;
    // Fail //
    public UnityAction action_trigger_fail;

    private void Awake()
    {
        Initialization();
        damaged_Object = new List<GameObject>();
        area_damaged_Object = new List<GameObject>();
        areaDamage_activate += Area_Damage_Trigger;
    }

    private void Update()
    {

        if (transfer_manager && area_damage)
        {
            areaDamage_activate.Invoke();
        }
        /*if (!transfer_manager)
        {
            if (areaDamage_Safeguard && area_damage)
            {
                areaDamage_activate.Invoke();
            }
*//*            if (area_damage && !areaDamage_Safeguard)
                Area_Damage_Controller();*//*
        }*/

    }



    public void Initialization()
    {
        weapon_Damage = weapon_Damage_MASTER;
        fireDam = fireDam_MASTER;
        fireChance = fireChance_MASTER;
        electricDam = electricDam_MASTER;
        electricChance = electricChance_MASTER;
        iceDam = iceDam_MASTER;
        iceChance = iceChance_MASTER;
        poisonDam = poisonDam_MASTER;
        poisonChance = poisonChance_MASTER;      
    }

    /** Check Pierce Count */
    public void PierceController()
    {
        if (hasCollided)
            hasCollided = false;

        // Reset Pierce Count;
        pierceCount = 0;
    }

    private bool ProbabilityCheck(float val)
    {
        if (val == 0)
            return false;
        else if (val == -1)
            return true;
        else
        {
            return (Random.Range(0, 100f) <= val);
        }
    }
    private bool Check_Duplicate_Object(GameObject obj)
    {
        for (int n = 0; n < damaged_Object.Count; n++)
        {
            if (damaged_Object[n].Equals(null))
            {
                damaged_Object.RemoveAt(n);
                continue;
            }

            if (damaged_Object[n].Equals(obj))
            {
                return false;
            }
        }
        return true;
    }

    private void OnTriggerEnter(Collider col)
    {
        collisionPos = col.ClosestPoint(transform.position);

        if (pierceCount > pierceThrough && hasCollided == false && !unlimited_pierce)
        {
            pierceCount = 0;
            hasCollided = true;
        }

        if ((!hasCollided || unlimited_pierce) && damage_Enable && !area_damage)
        {
            if (((1 << col.gameObject.layer) & armor) != 0 && col.gameObject.CompareTag("Player"))
            {
                if (Check_Duplicate_Object(col.GetComponent<GetParentObject>().parent))
                {
                    damaged_Object.Add(col.GetComponent<GetParentObject>().parent);
                    Colliding_Manager_Armor(col);
                }
            }
        }
        else if ((!hasCollided || unlimited_pierce) && area_damage && damage_Enable)
        {
            if (((1 << col.gameObject.layer) & armor) != 0)
            {
                if (Check_Duplicate_ObjectArea(col.GetComponent<GetParentObject>().gameObject))
                {
                    area_damaged_Object.Add(col.GetComponent<GetParentObject>().gameObject);
                }
            }         
        }

    }

    private void OnTriggerStay(Collider col)
    {
        if (area_damage && damage_Enable)
        {
            // PierceCount
            if (pierceCount > pierceThrough && hasCollided == false)
            {
                pierceCount = 0;
                hasCollided = true;

            }

            if (!hasCollided || unlimited_pierce)
            {
                if (((1 << col.gameObject.layer) & armor) != 0)
                {
                    if (Check_Duplicate_ObjectArea(col.GetComponent<GetParentObject>().gameObject))
                    {
                        area_damaged_Object.Add(col.GetComponent<GetParentObject>().gameObject);                       
                    }
                }                
            }
        }
    }

    private void OnTriggerExit(Collider col)
    {
        if (area_damage)
        {
            if (((1 << col.gameObject.layer) & armor) != 0)
            {
                if (area_damaged_Object.Contains(col.GetComponent<GetParentObject>().gameObject))
                {
                    area_damaged_Object.Remove(col.GetComponent<GetParentObject>().gameObject);
                }
            }
        }
    }

 

    private void Colliding_Manager_Armor(Collider col)
    {
        //Collider Object
        collision_Collider = col;
        // Effect Direction
        collisionDir = col.transform.position.x - transform.position.x;

        if (col.TryGetComponent<IDamage>(out IDamage damage))
        {
            damage.Damage(weapon_Damage,parentObject);
        }

        pierceCount++;
        if (pierceCount > pierceThrough && hasCollided == false && !unlimited_pierce)
        {
            pierceCount = 0;
            hasCollided = true;

        }
        // Effect Trigger
        collisionEffect_Trigger?.Invoke();
        
    }

    private void Area_Damage_Controller()
    {
        if (area_damaged_Object != null && area_damaged_Object.Count > 0)
        {
            for (int n = 0; n < area_damaged_Object.Count; n++)
            {
                if (area_damaged_Object[n] != null)
                {
                    Debug.Log("Name: " + area_damaged_Object[n].name);
                    if (Check_Duplicate_Object(area_damaged_Object[n].GetComponent<GetParentObject>().gameObject))
                    {
                        damaged_Object.Add(area_damaged_Object[n].GetComponent<GetParentObject>().gameObject);
                        if (((1 << area_damaged_Object[n].layer) & armor) != 0)
                        {
                            collisionPos = area_damaged_Object[n].GetComponent<Collider>().ClosestPoint(transform.position);
                            Colliding_Manager_Armor(area_damaged_Object[n].GetComponent<Collider>());
                        }
                    }
                }
                else
                    area_damaged_Object.RemoveAt(n);


            }
        }


    }

    private bool Check_Duplicate_ObjectArea(GameObject obj) // COLLIDER OBJECT
    {
        for (int n = 0; n < area_damaged_Object.Count; n++)
        {
            if (area_damaged_Object[n].Equals(null))
            {
                area_damaged_Object.RemoveAt(n);
                continue;
            }

            if (area_damaged_Object[n].Equals(obj))
            {
                return false;
            }
        }
        return true;
    }
    private void Area_Damage_Trigger()
    {
        StartCoroutine(Area_Damage(areaDamage_tick, areaDamage_delayTimer, areaDamage_endTimer));
        transfer_manager = false;
    }
    IEnumerator Area_Damage(float tick, float delay, float endTime)
    {
        float count = tick;
        while (true)
        {
            // Timer
            endTime -= Time.deltaTime;
            if (delay > 0)
                delay -= Time.deltaTime;
            else
            {
                count -= Time.deltaTime;
                if (count <= 0)
                {
                    Area_Damage_Controller();
                    area_damaged_Object.Clear();
                    count = tick;
                }
            }
            if (endTime <= 0)
            {
                damage_Enable = false;
                yield break;
            }
            yield return null;
        }
    }
}
