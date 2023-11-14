using System.Collections;
using UnityEngine;
using UnityEngine.Events;

public class GhostWomen : MonoBehaviour
{
    [SerializeField]
    SkinnedMeshRenderer render;

    [SerializeField] Transform destination;

    [SerializeField] AudioSource source;
    [SerializeField]
    private bool isMoving;
    [SerializeField]
    private bool isPlaying;

    Animator animator;

    public UnityEvent eventTrigger;

    private void Start()
    {
        animator = GetComponent<Animator>();
    }
    public void MoveTrigger()
    {
        StartCoroutine(Wait());
        animator.SetBool("Idle", true);
        source.Play();
        isPlaying = true;


    }

    private void Update()
    {
        if(isMoving)
        {
            transform.position = Vector3.MoveTowards(transform.position,destination.position,Time.deltaTime * 0.6f);

            if (Vector3.Distance(transform.position, destination.position) <= 0.1f)
            {
                isMoving=false;
                render.enabled = false;
            }
        }

        if(isPlaying)
        {
            if(!source.isPlaying)
            {
                isPlaying = false;
                transform.gameObject.SetActive(false);
                eventTrigger?.Invoke();
            }
        }
    }

    IEnumerator Wait()
    {
        yield return new WaitForSeconds(4);
        isMoving = true;

    }
}
