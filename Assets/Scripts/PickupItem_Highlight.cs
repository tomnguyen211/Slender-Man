using UnityEngine;
using System.Collections;

public class PickupItem_Highlight : MonoBehaviour
{
    [SerializeField]
    MeshRenderer mesh;
    [SerializeField]
    SkinnedMeshRenderer meshSkin;
    Material mat;
    LayerMask armor;
    private bool glowUp;
    IEnumerator CourRunning;

    private void Start()
    {
        if(mesh != null)
            mat = mesh.transform.GetComponent<MeshRenderer>().material;
        else if(meshSkin != null)
            mat = meshSkin.transform.GetComponent<SkinnedMeshRenderer>().material;

        armor = LayerMask.NameToLayer("Armor");
    }

    private void Update()
    {
        Collider[] rangeChecks = Physics.OverlapSphere(transform.position, 30, armor);
        if (rangeChecks.Length != 0 && CourRunning == null)
        {
            for (int i = 0; i < rangeChecks.Length; i++)
            {
                Transform target = rangeChecks[i].transform;

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
        }
    }

    IEnumerator GlowUp()
    {
        float timer = 0;
        float oldVal = mat.GetFloat("_Emission_Strength");
        while (mat.GetFloat("_Emission_Strength") < 0.7f)
        {
            timer += Time.deltaTime;
            mat.SetFloat("_Emission_Strength", Mathf.Lerp(oldVal, 0.7f, timer / 1));
            yield return null;
        }
        mat.SetFloat("_Emission_Strength", 0.7f);
        CourRunning = null;
    }
    IEnumerator GlowDown()
    {
        float timer = 0;
        float oldVal = mat.GetFloat("_Emission_Strength");
        while (mat.GetFloat("_Emission_Strength") > 0)
        {
            timer += Time.deltaTime;
            mat.SetFloat("_Emission_Strength", Mathf.Lerp(oldVal, 0f, timer / 1));
            yield return null;
        }
        mat.SetFloat("_Emission_Strength", 0f);
        CourRunning = null;
    }
}
