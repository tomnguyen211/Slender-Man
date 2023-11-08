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

    private void Start()
    {
        if(mesh != null)
            mat = mesh.transform.GetComponent<MeshRenderer>().material;
        else if(meshSkin != null)
            mat = meshSkin.transform.GetComponent<SkinnedMeshRenderer>().material;

        glowUp = true;
    }

    private void Update()
    {
        Collider[] rangeChecks = Physics.OverlapSphere(transform.position, 30, armor);
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
                        Debug.Log("Passed_1");

                    }
                    else
                    {

                        CourRunning = GlowDown();
                        StartCoroutine(CourRunning);
                        glowUp = true;
                        Debug.Log("Passed_2");


                    }
                }
                
            }
        }
    }

    IEnumerator GlowUp()
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
    IEnumerator GlowDown()
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
