using System.Collections;
using UnityEngine;
using UnityEngine.Events;

public class GhostWomen_Run : MonoBehaviour
{
    [SerializeField]
    SkinnedMeshRenderer render;

    [SerializeField] Transform destination;

    [SerializeField] AudioSource source;

    [SerializeField]
    AudioClip crying;

    [SerializeField]
    AudioClip scream;

    [SerializeField]
    private bool isMoving;

    Animator animator;

    public GameObject DecalAttach;
    public GameObject[] DecalFX;
    public GameObject[] DecalSub;

    public Light DirLight;

    public UnityEvent eventTrigger;

    public bool hasTrigger;

    private void Awake()
    {
        animator = GetComponent<Animator>();
    }

    private void Start()
    {
        DirLight = GameObject.FindGameObjectWithTag("Light").GetComponent<Light>();
    }
    public void MoveTrigger()
    {
        transform.gameObject.SetActive(true);
        source.clip = crying;
        source.loop = true;
        animator.SetBool("Idle",false);
        source.Play();
        animator.SetBool("Empty", true);
        EventManager.TriggerEvent("HeartBeatSound", true);
    }

    private void Update()
    {
        if (isMoving)
        {
            transform.position = Vector3.MoveTowards(transform.position, destination.position, Time.deltaTime * 2.5f);

            if (Vector3.Distance(transform.position, destination.position) <= 0.1f)
            {
                isMoving = false;
                render.enabled = false;
                source.Stop();
                eventTrigger?.Invoke();
                transform.gameObject.SetActive(false);
                for(int n = 0; n < 5; n++)
                {
                    SpawnDecals(new Vector3(transform.position.x + Random.Range(-0.5f,0.5f),transform.position.y + Random.Range(-0.5f, 0.5f), transform.position.z + Random.Range(-0.5f, 0.5f)));

                }
                EventManager.TriggerEvent("HeartBeatSound", false);

                //Trigger Event
            }
        }


    }
    private void OnTriggerEnter(Collider col)
    {
        if(col.CompareTag("Player") && !hasTrigger)
        {
            hasTrigger = true;
            isMoving = true;
            animator.SetBool("Run", true);
            animator.SetBool("Empty", false);
            source.Stop();
            source.loop = false;
            source.clip = scream;
            source.Play();
        }
    }

    public Vector3 direction;
    int effectIdx;
    int activeBloods;

    public void SpawnDecals(Vector3 pos)
    {
        var randRotation = new Vector3(0, Random.value * 360f, 0);
        float angle = Mathf.Atan2(pos.normalized.x, pos.normalized.z) * Mathf.Rad2Deg + 180;

        var effectIdx = Random.Range(0, DecalFX.Length);
        if (effectIdx == DecalFX.Length) effectIdx = 0;

        var instance = Instantiate(DecalFX[effectIdx], pos, Quaternion.Euler(0, angle + 90, 0));
        effectIdx++;
        activeBloods++;
        var settings = instance.GetComponent<BFX_BloodSettings>();
        //settings.FreezeDecalDisappearance = InfiniteDecal;
        settings.LightIntensityMultiplier = DirLight.intensity;

        var nearestBone = GetNearestObject(transform.root, pos);
        if (nearestBone != null)
        {
            var attachBloodInstance = Instantiate(DecalAttach);
            var bloodT = attachBloodInstance.transform;
            bloodT.position = pos;
            bloodT.localRotation = Quaternion.identity;
            bloodT.localScale = Vector3.one * Random.Range(0.75f, 1.2f);
            bloodT.LookAt(pos + pos.normalized, direction);
            bloodT.Rotate(90, 0, 0);
            bloodT.transform.parent = nearestBone;
            //Destroy(attachBloodInstance, 20);
        }
    }

    Transform GetNearestObject(Transform hit, Vector3 hitPos)
    {
        var closestPos = 100f;
        Transform closestBone = null;
        var childs = hit.GetComponentsInChildren<Transform>();

        foreach (var child in childs)
        {
            var dist = Vector3.Distance(child.position, hitPos);
            if (dist < closestPos)
            {
                closestPos = dist;
                closestBone = child;
            }
        }

        var distRoot = Vector3.Distance(hit.position, hitPos);
        if (distRoot < closestPos)
        {
            closestPos = distRoot;
            closestBone = hit;
        }
        return closestBone;
    }

    public float CalculateAngle(Vector3 from, Vector3 to)
    {
        return Quaternion.FromToRotation(Vector3.up, to - from).eulerAngles.z;
    }
}
