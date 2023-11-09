using UnityEngine;
using System.Collections;
using Unity.Collections;

public class PickupItem_Highlight : MonoBehaviour
{
    [SerializeField]
    MeshRenderer mesh;
    [SerializeField]
    SkinnedMeshRenderer meshSkin;
    Material mat;
    [SerializeField,ReadOnly]
    LayerMask armor;
    private bool glowUp;
    IEnumerator CourRunning;

    [SerializeField]
    bool SpriteShaderEnable;

    GameObject Player;

    public bool hasInteract;

    [SerializeField]
    private bool isSpawn;
    [SerializeField]
    GameObject[] spawnObject;
    [SerializeField]
    Transform spawnPos;

    private void Start()
    {
        if(mesh != null)
            mat = mesh.transform.GetComponent<MeshRenderer>().material;
        else if(meshSkin != null)
            mat = meshSkin.transform.GetComponent<SkinnedMeshRenderer>().material;

        glowUp = true;

        Player = GameObject.FindGameObjectWithTag("Player");
    }

    private void Update()
    {
        if(CourRunning == null && !hasInteract)
        {
            if(Vector3.Distance(transform.position,Player.transform.position) <= 10)
            {
                if (glowUp)
                {
                    CourRunning = GlowUp();
                    StartCoroutine(CourRunning);
                    glowUp = false;
                }
                else
                {

                    CourRunning = GlowDown();
                    StartCoroutine(CourRunning);
                    glowUp = true;
                }
            }
        }
        /*Collider[] rangeChecks = Physics.OverlapSphere(transform.position, 10, armor);
        if (rangeChecks.Length != 0 && CourRunning == null)
        {
            for (int i = 0; i < rangeChecks.Length; i++)
            {
                Transform target = rangeChecks[i].transform;
                Debug.Log(target.tag);
                if(target.CompareTag("Player"))
                {
                    if(glowUp)
                    {
                        CourRunning = GlowUp();
                        StartCoroutine(CourRunning);
                        glowUp = false;
                    }
                    else
                    {

                        CourRunning = GlowDown();
                        StartCoroutine(CourRunning);
                        glowUp = true;
                    }
                }
                
            }
        }*/
    }

    public void Interact()
    {
        hasInteract = true;
        if (SpriteShaderEnable)
        {          
            mat.SetFloat("_StrongTintFade", 0f);
            CourRunning = null;
        }
        else
        {
            mat.SetFloat("_Emission_Strength", 0f);
            CourRunning = null;
        }

        if(isSpawn)
        {
            for(int n = 0; n < spawnObject.Length;n++)
            {
                Instantiate(spawnObject[n], spawnPos.position, spawnObject[n].transform.rotation);
            }
        }
    }

    IEnumerator GlowUp()
    {
        if(SpriteShaderEnable)
        {
            float timer = 0;
            float oldVal = mat.GetFloat("_StrongTintFade");
            while (mat.GetFloat("_StrongTintFade") < 0.8f)
            {
                timer += Time.deltaTime;
                mat.SetFloat("_StrongTintFade", Mathf.Lerp(oldVal, 0.8f, timer / 2));
                yield return null;
            }
            mat.SetFloat("_StrongTintFade", 0.8f);
            CourRunning = null;
        }
        else
        {
            float timer = 0;
            float oldVal = mat.GetFloat("_Emission_Strength");
            while (mat.GetFloat("_Emission_Strength") < 0.1f)
            {
                timer += Time.deltaTime;
                mat.SetFloat("_Emission_Strength", Mathf.Lerp(oldVal, 0.1f, timer / 2));
                yield return null;
            }
            mat.SetFloat("_Emission_Strength", 0.1f);
            CourRunning = null;
        }
    }
    IEnumerator GlowDown()
    {
        if (SpriteShaderEnable)
        {
            float timer = 0;
            float oldVal = mat.GetFloat("_StrongTintFade");
            while (mat.GetFloat("_StrongTintFade") > 0)
            {
                timer += Time.deltaTime;
                mat.SetFloat("_StrongTintFade", Mathf.Lerp(oldVal, 0f, timer / 2));
                yield return null;
            }
            mat.SetFloat("_StrongTintFade", 0f);
            CourRunning = null;
        }
        else
        {
            float timer = 0;
            float oldVal = mat.GetFloat("_Emission_Strength");
            while (mat.GetFloat("_Emission_Strength") > 0)
            {
                timer += Time.deltaTime;
                mat.SetFloat("_Emission_Strength", Mathf.Lerp(oldVal, 0f, timer / 2));
                yield return null;
            }
            mat.SetFloat("_Emission_Strength", 0f);
            CourRunning = null;
        }
    }
}
